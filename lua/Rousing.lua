
function checkSafety(x, y, radius, dist)
	radius = radius or 8
	dist = dist or 8
	local rouse_list = wml.variables["rouse_list"]
	local safety
	local query, enemies, i
	if rouse_list then
		query = {
			side = wml.variables['const.enemy_sides'],
			{ "filter_location", { x = x, y = y, radius = radius } },
			{ "and", {
				{ "not", {
					{ "filter_wml", {
						{ "status", { guardian = "yes" } }
					} }
				} },
				{ "or", {
					id = rouse_list
				} }
			} }
		}
	else
		query = {
			side = wml.variables['const.enemy_sides'],
			{ "filter_location", { x = x, y = y, radius = radius } },
			{ "not", {
				{ "filter_wml", {
					{ "status", { guardian = "yes" } }
				} }
			} }
		}
	end
	enemies = wesnoth.units.find_on_map(query)
	if not enemies or #enemies == 0 then
		return true
	end

	for i = 1, #enemies do
		local e = enemies[i]
		local path1, p1 = wesnoth.paths.find_path(e.x, e.y, x, y, { ignore_units = true, ignore_visibility = true })
		local path2, p2 = wesnoth.paths.find_path(x, y, e.x, e.y, { ignore_units = true, ignore_visibility = true })
		std_print(dump_lua_value({e = e.id, p1=p1, p2=p2}))
		local hidden = e.status.hidden
		local demeanor = e.variables.demeanor or "lookout"
		if p1 <= dist or p2 <= dist then
			if hidden and demeanor == "ambush" then
				-- TODO trigger ambush
				if p1 <= 2 or p2 <= 2 then
					return false
				end
			else
				std_print("unsafe triggered!")
				return false
			end
		end
	end

	return true
end

local function on_board_path(u, x, y)
	local path, cost = nil, 9e99
	if type(x) ~= "number" or type(y) ~= "number" then
		return path, cost
	end
	local w, h = wesnoth.get_map_size()
	if x >= 1 and y >= 1 and x <= w and y <= h then
		path, cost = wesnoth.paths.find_path(u, x, y, { ignore_units = true, ignore_visibility = true })
	end
	return path, cost
end

function wesnoth.wml_actions.rouse_units(cfg)
	local x, y = cfg.x or werr("[rouse_units] expects an x= attribute"), cfg.y or werr("[rouse_units] expects a y= attribute")
	local min_index = -1
	local hidden = false
	local rouse_enemies
	local u = wesnoth.units.get(x, y)
	if u then
		local v = u.variables.__cfg
		local a = wml.get_child(v, "abilities")
		if a then
			if a.sneak == 1 and v.mobility == 2 and 2 * u.moves >= u.max_moves then
				hidden = true
			elseif v.mobility >= 1 then
				if a.ambush_forest == 1 then
					hidden = wesnoth.eval_conditional {
						{ "have_location", {
							x = x,
							y = y,
							terrain = "*^F*"
						} }
					}
				end
				if a.ambush_mountain == 1 and not hidden then
					hidden = wesnoth.eval_conditional {
						{ "have_location", {
							x = x,
							y = y,
							terrain = "M*,M*^*"
						} }
					}
				end
			end
			if not hidden and v.mobility >= 0 and a.nightstalk == 1 then
				hidden = wesnoth.eval_conditional {
					{ "have_location", {
						x = x,
						y = y,
						time_of_day = "chaotic"
					} }
				}
			end
			if hidden then
				hidden = not wesnoth.eval_conditional {
					{ "have_unit", {
						side = wml.variables["const.enemy_sides"],
						{ "filter_adjacent", {
							x = x,
							y = y
						} }
					} }
				}
			end
		end
	end
	local rouse_list = wml.variables["rouse_list"]
	if not hidden then
		wesnoth.wml_actions.store_locations {
			variable = "rouse_temp_locs",
			x = x,
			y = y,
			radius = 12,
			{ "filter", {} }
		}
		if rouse_list then
			rouse_enemies = wesnoth.units.find_on_map( {
					side = wml.variables['const.enemy_sides'],
					{ "filter_location", { find_in = "rouse_temp_locs" } },
					{ "filter_wml", {
						{ "status", { guardian = "yes" } }
					} },
					{ "not", {
						id = rouse_list
					} }
				} )
		else
			rouse_enemies = wesnoth.units.find_on_map( {
					side = wml.variables['const.enemy_sides'],
					{ "filter_location", { find_in = "rouse_temp_locs" } },
					{ "filter_wml", {
						{ "status", { guardian = "yes" } }
					} }
				} )
		end
		local dist = 14
		local min_dist = 13
		for i, uu in ipairs(rouse_enemies) do
			dist = wesnoth.map.distance_between(x, y, uu.x, uu.y)
			if dist <= (uu.max_moves + 1) then
				local target_cost = uu.max_moves + wesnoth.unit_movement_cost(uu, wesnoth.get_terrain(x, y))
				local path, cost
				if target_cost > 99 then
					-- find_path gives unhelpful results if you're standing where the enemy can't be moved to
					-- so have to check each adjacent hex individually in that case
					target_cost = uu.max_moves
					path, cost = on_board_path(uu, x, y + 1)
					if cost > target_cost then
						path, cost = on_board_path(uu, x, y - 1)
						if cost > target_cost then
							path, cost = on_board_path(uu, x + 1, y - x % 2)
							if cost > target_cost then
								path, cost = on_board_path(uu, x - 1, y - x % 2)
								if cost > target_cost then
									path, cost = on_board_path(uu, x + 1, y + 1 - x % 2)
									if cost > target_cost then
										path, cost = on_board_path(uu, x - 1, y + 1 - x % 2)
									end
								end
							end
						end
					end
				else
					path, cost = on_board_path(uu, x, y)
				end
				if cost <= target_cost then
					if rouse_list then
						rouse_list = string.format("%s,%s", rouse_list, uu.id)
					else
						rouse_list = uu.id
					end
					wesnoth.wml_actions.store_locations {
						variable = "rouse_temp_locs",
						x = uu.x,
						y = uu.y,
						radius = uu.max_moves,
						{ "filter", {} }
					}
					local rouse_enemies_near = wesnoth.units.find_on_map( {
							side = uu.side,
							{ "filter_location", { find_in = "rouse_temp_locs" } },
							{ "filter_wml", {
								{ "status", { guardian = "yes" } }
							} },
							{ "not", {
								id = rouse_list
							} }
						} )
					for j, v in ipairs(rouse_enemies_near) do
						rouse_list = string.format("%s,%s", rouse_list, v.id)
					end
					if dist < min_dist then
						min_dist = dist
						min_index = i
					end
				end
			end
		end
	end
	if min_index > -1 then
		wml.variables["rouse_list"] = rouse_list
		local visible = wesnoth.units.find_on_map( {
				id = rouse_enemies[min_index].id,
				{ "filter_vision", { side = wml.variables['side_number'] } }
			} )
		if visible[1] then
			wesnoth.fire_event("spot", x, y, visible[1].x, visible[1].y)
		else
			wesnoth.fire_event("hear", x, y)
		end
	elseif cfg.refresh and u and checkSafety(x, y) and u.side == wesnoth.current.side and u.attacks_left > 0 and u.variables.simple_action and u.variables.simple_action > 0 then
		u.moves = u.max_moves
		-- Might not be multiplayer safe according to the wiki
		W.select_unit { x = u.x, y = u.y }
	end
	wml.variables["rouse_temp_locs"] = nil
end

function wesnoth.wml_actions.check_safety(cfg)
	local x = cfg.x or werr("[check_safety] expects an x= attribute")
	local y = cfg.y or werr("[check_safety] expects a y= attribute")
	local v = cfg.variable or werr("[check_safety] requires a variable= key")

	local safety = checkSafety(x, y)
	if not safety then
		wml.variables[v] = 0
	end
end

function wesnoth.wml_conditionals.is_safe(cfg)
	local x = cfg.x or werr("[is_safe] expects an x= attribute")
	local y = cfg.y or werr("[is_safe] expects a y= attribute")

	return checkSafety(x, y)
end

function continue_follow_path()
	std_print("continue_follow_path")
end


-- wml.array_access.get("variables.movehist", wesnoth.units.get("Character1"))\

function init_move_history_orig()
	local playerSides =  wesnoth.sides.find({controller = "human"})
	local i, j

	std_print(dump_lua_value(playerSides, "playerSides"))

	for i = 1, #playerSides do
		local units = wesnoth.units.find_on_map({side = playerSides[i].side_number})
		std_print(dump_lua_value(units, "units"))

		for j = 1, #units do
			local unit = wesnoth.units.get(units[j].id)
			std_print(dump_lua_value({id = units[j].id}, "unit"))
			wml.array_access.set("movehist", {{x = unit.x, y = unit.y}}, unit)
		end
	end
end

function init_move_history()
	local ignored, side, unit

	for ignored, side in ipairs(wesnoth.sides.find({controller = "human"})) do
		std_print(dump_lua_value({side_number = side.side_number}, "side"))

		for ignored, unit in ipairs(wesnoth.units.find_on_map({side = side.side_number})) do
			std_print(dump_lua_value({id = unit.id}, "unit"))
			wml.array_access.set("movehist", {{x = unit.x, y = unit.y}}, unit)
			wml.array_access.set("following", {}, unit)
		end
	end
end

function on_move(unit_id, x, y)
	update_loot_menu(x, y)
	local unit = wesnoth.units.get(unit_id)
	local movehist = wml.array_access.get("movehist", unit)
	table.insert(movehist, {x = x, y = y})
	wml.array_access.set("movehist", movehist, unit)
end

local function follow_find_leader(unit, leader, movehist, following)
	local leader_idx = nil
	local k, v, i

	-- Have we already started following this character since the last level load?
	for k, v in ipairs(following) do
		if v[2].id == leader.id then
			leader_idx = k
			break
		end
	end

	-- If not, then find a starting point in their move history. The goal is
	-- safe moves that don't rouse enemies or cause moves to stop refreshing.
	if not leader_idx then
		local min_dist
		local idx
		for k, v in ipairs(movehist) do
			local dist = wesnoth.map.distance_between({unit.x, unit.y}, {v.x, v.y})
-- 			std_print(dump_lua_value({
-- 				i = k,
-- 				dist = dist,
-- 				from = {x = unit.x, y = unit.y},
-- 				to   = {x = v.x,    y = v.y}
-- 			}))
			if not idx or dist < min_dist then
				idx = k
				min_dist = dist
			end
		end
		table.insert(following, {id = leader.id, idx = idx})
-- 		std_print(dump_lua_value({name = unit.name, value = {id = leader.id, idx = idx}}))
		leader_idx = #following
	end

-- 	local waypoints = {}
	local waypoint_idx = following[leader_idx].idx
-- 	for i = waypoint_idx, #movehist do
-- 		table.insert(waypoints, {idx = i, movehist[i]})
-- 	end
-- 	std_print(dump_lua_value({name = unit.name, waypoints = waypoints}, "follow_path"))
	wml.array_access.set("following", following , unit)

	return leader_idx, waypoint_idx
end

-- local path, cost = wesnoth.paths.find_path(x1, y2, x2, y2, {
--     calculate = function(x, y, current_cost)
--         local remaining_moves = max_moves - (current_cost % max_moves)
--         if remaining_moves < 3 then current_cost = current_cost + remaining_moves end
--         return current_cost + 3
--     end })
-- wesnoth.interface.add_chat_message(string.format("It would take %d turns.", math.ceil(cost / 3)))
--[[

local function follow_build_path(unit, leader, movehist, following)
	local leader_idx, waypoint_idx = follow_find_leader(unit, leader, movehist, following)

-- 	std_print(dump_lua_value(path, "path"))

	local x = tostring(unit.x)
	local y = tostring(unit.y)
	local i, j, k, v
	local skipped = 0
	local nodes = 0
	local lastWaypoint
	local path = {}

	for i = waypoint_idx, #movehist do
		local waypoint = movehist[i]
		local start = #path > 0 and path[#path] or {unit.x, unit.y}
		local saveLoc = {unit.x, unit.y}
		unit.x = start[1]
		unit.y = start[2]
		local leg = wesnoth.paths.find_path(
			start[1], start[2], waypoint.x, waypoint.y, {
				ignore_units = true,
				viewing_side = unit.side,
				ignore_teleport = true
			}
		)
		unit.x = saveLoc[1]
		unit.y = saveLoc[2]

		std_print(dump_lua_value({
			unit_id = unit.id,
			waypoint = waypoint,
			leg = leg,
			i = i
		}, "follow_leader"))

-- 		table.insert(path, start)
		for j = 1, #leg do
			local loc = leg[j]
			local dupe = false
			for k = 1, #path do
				if path[k][1] == loc[1] and path[k][2] == loc[2] then
					dupe = true
				end
			end
			if not dupe then
				table.insert(path, leg[j])
			end
		end
	end

	std_print(dump_lua_value({
		unit_id = unit.id,
		path = path
	}, "follow_leader"))

	for i = 1, #path do
		local loc = path[i]
-- 		std_print(dump_lua_value(loc, "elem"))
		if wesnoth.units.get(loc[1], loc[2]) then
			skipped = skipped + 1
		else
			nodes = nodes + 1
			x = x .. "," .. tostring(loc[1])
			y = y .. "," .. tostring(loc[2])
			skipped = 0
			lastWaypoint = i
		end
	end

-- 	if nodes > 1 then
-- 		break
-- 	end
--
-- 	if not lastWaypoint then
-- 		std_print("i == nil, darn")
-- 		return
-- 	end

	if nodes > 1 then
		local cmd = {from_side = unit.side, wml.tag.move {x = x, y = y, skip_sighted = "only_ally"}}
		std_print(dump_lua_value(cmd, "do_command"))
		wesnoth.wml_actions.do_command(cmd)
		waypoint_idx = lastWaypoint
		wml.array_access.get("following", unit)[leader_idx].idx = waypoint_idx
	end
end

]]


local function follow_leader(unit, leader, movehist, following)
	local leader_idx, waypoint_idx = follow_find_leader(unit, leader, movehist, following)

-- 	std_print(dump_lua_value(path, "path"))

	local x = tostring(unit.x)
	local y = tostring(unit.y)
	local i, j, k, v
	local skipped = 0
	local nodes = 0
	local lastWaypoint
	local path = {}

	for i = waypoint_idx, #movehist do
		local waypoint = movehist[i]
		local start = #path > 0 and path[#path] or {unit.x, unit.y}
		local saveLoc = {unit.x, unit.y}
		unit.x = start[1]
		unit.y = start[2]
		local leg = wesnoth.paths.find_path(
			start[1], start[2], waypoint.x, waypoint.y, {
				ignore_units = true,
				viewing_side = unit.side,
				ignore_teleport = true
			}
		)
		unit.x = saveLoc[1]
		unit.y = saveLoc[2]

		std_print(dump_lua_value({
			unit_id = unit.id,
			waypoint = waypoint,
			leg = leg,
			i = i
		}, "follow_leader"))

-- 		table.insert(path, start)
		for j = 1, #leg do
			local loc = leg[j]
			local dupe = false
			for k = 1, #path do
				if path[k][1] == loc[1] and path[k][2] == loc[2] then
					dupe = true
				end
			end
			if not dupe then
				table.insert(path, leg[j])
			end
		end
	end

	std_print(dump_lua_value({
		unit_id = unit.id,
		path = path
	}, "follow_leader"))

	for i = 1, #path do
		local loc = path[i]
-- 		std_print(dump_lua_value(loc, "elem"))
		if wesnoth.units.get(loc[1], loc[2]) then
			skipped = skipped + 1
		else
			nodes = nodes + 1
			x = x .. "," .. tostring(loc[1])
			y = y .. "," .. tostring(loc[2])
			skipped = 0
			lastWaypoint = i
		end
	end

-- 	if nodes > 1 then
-- 		break
-- 	end
--
-- 	if not lastWaypoint then
-- 		std_print("i == nil, darn")
-- 		return
-- 	end

	if nodes > 1 then
		local cmd = {from_side = unit.side, wml.tag.move {x = x, y = y, skip_sighted = "only_ally"}}
		std_print(dump_lua_value(cmd, "do_command"))
		wesnoth.wml_actions.do_command(cmd)
		waypoint_idx = lastWaypoint
		wml.array_access.get("following", unit)[leader_idx].idx = waypoint_idx
	end
end

function follow_me(unit_id, x, y)
	local leader = wesnoth.units.get(unit_id)
	local movehist = wml.array_access.get("movehist", leader)
	local followers = wesnoth.units.find_on_map({side = leader.side, {"not", {id = unit_id}}})
	local i

	wesnoth.interface.add_chat_message(string.format("%s says, \"Come here!\"", leader.name))

	for i = 1, #followers do
		local unit = followers[i]
		local dist = wesnoth.map.distance_between({unit.x, unit.y}, {leader.x, leader.y})
		if dist < 7 then
			wesnoth.interface.add_chat_message(string.format("%s says, \"I'm right here.\"", unit.name))
		else
			wesnoth.interface.add_chat_message(string.format("%s says, \"I'm coming!\"", unit.name))
			local following = wml.array_access.get("following", unit)
			follow_leader(unit, leader, movehist, following)
			return
		end
	end
end
