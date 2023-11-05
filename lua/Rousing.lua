
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
		path, cost = wesnoth.find_path(u, x, y, { ignore_units = true, ignore_visibility = true })
	end
	return path, cost
end

function wesnoth.wml_actions.rouse_units(cfg)
	local x, y = cfg.x or werr("[rouse_units] expects an x= attribute"), cfg.y or werr("[rouse_units] expects a y= attribute")
	local min_index = -1
	local hidden = false
	local rouse_enemies
	local u = wesnoth.get_unit(x, y)
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
			rouse_enemies = wesnoth.get_units( {
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
			rouse_enemies = wesnoth.get_units( {
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
					local rouse_enemies_near = wesnoth.get_units( {
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
		local visible = wesnoth.get_units( {
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
