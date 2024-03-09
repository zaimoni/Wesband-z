function wesnoth.wml_actions.generate_dungeon_level(cfg)
	local width = H.rand("40,50,50,50,60")
	local height = 100 - width
	local w, h = wesnoth.get_map_size()
	if width ~= w or height ~= h then
		wml.fire("replace_map", {
			map = wesnoth.dofile(string.format("~add-ons/Wesband-z/maps/dungeon_template_%dx%d.lua", width, height)),
			expand = "yes",
			shrink = "yes"
		})
	end
	wml.variables["current_dungeon_template.x"] = width
	wml.variables["current_dungeon_template.y"] = height
	wesnoth.dofile("~add-ons/Wesband-z/lua/DungeonUpdate.lua")
	wesnoth.dofile("~add-ons/Wesband-z/lua/DungeonArchitecture.lua")
	wesnoth.dofile("~add-ons/Wesband-z/lua/DungeonThemes.lua")
	wesnoth.dofile("~add-ons/Wesband-z/lua/DungeonTerrain.lua")
end

function wesnoth.wml_actions.restore_map(cfg)
	local var = cfg.variable or werr("[restore_map] requires a variable= key")
	local clear = cfg.clear

	local data = wml.variables[var]
	wml.fire("replace_map", {
		map = data.map,
		expand = "yes",
		shrink = "yes"
	})

	for i = 1, #data do
		local s = data[i][2]
		if s.id == "exit" then
			wml.fire("create_exit", {
				x = s.x,
				y = s.y,
				destination = s.destination,
				image = s.image,
				label = s.label
			})
		elseif s.id == "item" then
			wml.fire("drop_item", {
				x = s.x,
				y = s.y,
				s[1]
			})
		end
	end

	local j = 0
	local first_enemy = wml.variables["const.max_player_count"] + 1
	local last_enemy = first_enemy + wml.variables[string.format("%s.sides.length", var)] - 1
	for i = first_enemy, last_enemy do
		wesnoth.sides[i].team_name = wml.variables[string.format("%s.sides[%d].team_name", var, j)]
		wesnoth.sides[i].user_team_name = wml.variables[string.format("%s.sides[%d].user_team_name", var, j)]
		j = j + 1
	end

	if clear then
		wml.variables[var] = nil
	end
end

function wesnoth.wml_actions.save_map(cfg)
	local var = cfg.variable or werr("[save_map] requires a variable= key")

	local w, h, b = wesnoth.get_map_size()
	local t, s = {}, {}
	for y = 1 - b, h + b do
		local r = {}
		for x = 1 - b, w + b do
			r[x + b] = wesnoth.get_terrain(x, y)
			local exit_data = wml.variables[string.format("ground.x%d.y%d.exit", x, y)]
			if exit_data then
				table.insert(s, { id = "exit", x = x, y = y, destination = exit_data.destination, image = exit_data.image, label = exit_data.label })
			end
			for i = 0, wml.variables[string.format("ground.x%d.y%d.items.length", x, y)] - 1 do
				table.insert(s, { id = "item", x = x, y = y, { "item", wml.variables[string.format("ground.x%d.y%d.items[%d]", x, y, i)] } })
			end
		end
		t[y + b] = table.concat(r, ',')
	end
	wml.variables[var .. ".map"] = string.format("border_size=%d\nusage=map\n\n%s", b, table.concat(t, '\n'))
	if #s > 0 then
		wml.array_access.set(var .. ".special", s)
	end

	local j = 0
	local first_enemy = wml.variables["const.max_player_count"] + 1
	local last_enemy = first_enemy
	if wml.variables["in_dungeon"] == 1 then
		last_enemy = last_enemy + wml.variables["const.max_enemy_count"] - 1
	end
	for i = first_enemy, last_enemy do
		wml.variables[string.format("%s.sides[%d].team_name", var, j)] = wesnoth.sides[i].team_name
		wml.variables[string.format("%s.sides[%d].user_team_name", var, j)] = wesnoth.sides[i].user_team_name
		j = j + 1
	end
end

function wesnoth.wml_actions.create_exit(cfg)
	local x = cfg.x or werr("[create_exit] requires an x= key")
	local y = cfg.y or werr("[create_exit] requires a y= key")
	local dest = cfg.destination or werr("[create_exit] requires a destination= key")
	local image = cfg.image or werr("[create_exit] requires an image= key")
	local label = cfg.label or werr("[create_exit] requires a label= key")

	wml.variables[string.format("ground.x%d.y%d.exit.destination", x, y)] = dest
	wml.variables[string.format("ground.x%d.y%d.exit.image", x, y)] = image
	wml.variables[string.format("ground.x%d.y%d.exit.label", x, y)] = label
	wml.fire("item", {
		x = x,
		y = y,
		image = image,
		visible_in_fog = "yes"
	})
	wml.fire("label", {
		x = x,
		y = y,
		text = label,
		visible_in_fog = "yes",
		immutable = "yes"
	})
end
