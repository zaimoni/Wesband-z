local function process_entries(tname)
	local tlength = wml.variables[string.format("dungeon_creation.updates.%s.length", tname)]
	local tstart, tcount
	for i = tlength - 1, 0, -1 do
		tstart = wml.variables[string.format("dungeon_creation.updates.%s[%i].start_level", tname, i)]
		if wml.variables['dungeon_level.current'] < tstart then break else
			tcount = wml.variables[string.format("dungeon_creation.updates.%s[%i].up_count", tname, i)]
			if tcount > 0 then
				wesnoth.wml_actions.set_prob({
					name = string.format("dungeon_creation.%s", tname),
					item = wml.variables[string.format("dungeon_creation.updates.%s[%i].type", tname, i)],
					weight = wml.variables[string.format("dungeon_creation.updates.%s[%i].up_rate", tname, i)],
					op = "add"
				})
				wml.variables[string.format("dungeon_creation.updates.%s[%i].up_count", tname, i)] = tcount - 1
				if tcount == 1 then
					tcount = wml.variables[string.format("dungeon_creation.updates.%s[%i].down_count", tname, i)]
				end
			else
				tcount = wml.variables[string.format("dungeon_creation.updates.%s[%i].down_count", tname, i)]
				if tcount > 0 then
					wesnoth.wml_actions.set_prob({
						name = string.format("dungeon_creation.%s", tname),
						item = wml.variables[string.format("dungeon_creation.updates.%s[%i].type", tname, i)],
						weight = wml.variables[string.format("dungeon_creation.updates.%s[%i].down_rate", tname, i)],
						op = "sub"
					})
					tcount = tcount - 1
					wml.variables[string.format("dungeon_creation.updates.%s[%i].down_count", tname, i)] = tcount
				end
			end
			if tcount == 0 then
				wml.variables[string.format("dungeon_creation.updates.%s[%i]", tname, i)] = nil
			end
		end
	end
end

local function process_theme(tname)
	process_entries(string.format("%s.boss", tname))
	process_entries(string.format("%s.tough", tname))
	process_entries(string.format("%s.mook", tname))
	process_entries(string.format("%s.loner", tname))
end

process_entries("terrains")
process_entries("cluster_themes")
process_entries("loner_themes")
process_theme("outlaws")
process_theme("orcs")
process_theme("undead")
process_theme("water")
process_theme("planar")
process_theme("saurian")
process_theme("slime")
process_theme("cave")
process_theme("dark")
process_entries("naga.loner")
