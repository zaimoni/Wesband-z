local magic_types = {
	"dark",
	"devling",
	"faerie",
	"green",
	"have",
	"human",
	"minotaur",
	"runic",
	"swamp",
	"tribal",
	"troll",
	"warlock",
	"witch",
	"wood"
}

local function num_or(value, default)
	return value and tonumber(value) or (default and tonumber(default) or 0)
end

function eval_item(item)
	if not item then
		return {}
	end

	local ench = wml.get_child(item, "enchantments")
	local ret = {
		item		= item,
		ench		= ench,
		ench_stats	= ench and wml.get_child(ench, "stats") or nil,
		cat			= item.category or "(category missing)", -- can this ever happen now? TODO: emit a warning?
		desc		= item.description or item.name or "(description missing)",
		name		= item.name,
		icon		= item.icon,
		arch_cat	= nil,
		slot		= nil,
		terrain		= wml.get_child(item, "terrain"),
		resistance	= wml.get_child(item, "resistance") or {},
		magic_bonus = 0,
		adjust		= {
			magic	= num_or(item.magic_adjust),
			ranged	= num_or(item.ranged_adjust),
			evade	= num_or(item.evade_adjust),
			defense	= 0
		}
	}
-- 	std_print(dump_lua_value({resist = ret.resistance, item = item}, "wtf_" .. item.name))
	local i, j
	for i, j in pairs(magic_types) do
		local property_name = j .. "_magic_adjust"
		local value = num_or(item[property_name])
		ret.magic_bonus = ret.magic_bonus + value
		if value > 0 then
			ret.magic_type = j
		end
	end

	if ret.cat == "(category missing)" then
		if item.range == "melee" then
			ret.cat = "melee_weapon"
		elseif item.range == "ranged" then
			ret.cat = "ranged_weapon"
		elseif ret.name == "clothes" or ret.icon == "armor/tunic" then
			ret.cat = "torso_armor"
		elseif ret.name == "pants_shoes" or ret.name == "loincloth" or ret.icon == "armor/shoes" then
			ret.cat = "legs_armor"
		elseif ret.icon == "armor/head" or ret.icon == "armor/elf-head" or ret.icon == "armor/troll-head" then
			ret.cat = "head_armor"
		elseif ret.icon == "categories/armor-arms" then
			ret.cat = "shield"
		else
			std_print(dump_lua_value(item, "bad_item", "", "  ", 24) .. "\n")
			werr("category missing and could not determine from other properties")
		end
	end
-- 	std_print(wml.tostring(item))
-- 	std_print(dump_value(item, "item", "", "  ", 24) .. "\n<small><small>")

	if ret.cat == "shield" then
		ret.arch_cat	= "armor"
		ret.slot		= "shield"
	else
		ret.arch_cat	= ret.cat:split("_")[2]
		ret.slot		= ret.cat:split("_")[1]
	end

	local flat_terrain = ret.terrain and wml.get_child(ret.terrain, "flat") or nil
	ret.adjust.defense = num_or(item.terrain_recoup) - num_or(flat_terrain and flat_terrain.defense)

	if ret.arch_cat == "weapon" then
		ret.icon = "attacks/" .. item.icon
	end

-- 	std_print(dump_lua_value(ret, "item_info"))

	return ret
end

local function eval_equipment(unit)
	local variables = unit.variables or wml.get_child(unit, "variables") or nil
	if not variables then return {} end
	local equipment_slots	= wml.get_child(variables, "equipment_slots")
	local inventory			= wml.get_child(variables, "inventory")
	local weapons			= inventory and wml.get_child(inventory, "weapons") or nil
	local armor				= inventory and wml.get_child(inventory, "armor") or nil
	local slots = {
		{"melee_1",		weapons,	"melee"},
		{"melee_2",		weapons,	"melee"},
		{"melee_3",		weapons,	"melee"},
		{"ranged",		weapons,	"ranged"},
		{"torso_armor",	armor,		"torso"},
		{"head_armor",	armor,		"head"},
		{"leg_armor",	armor,		"legs"},
		{"shield",		armor,		"shield"}
	}

	local adjust = {}
	local i, k, v

	for i = 1, #slots do
		local slot = slots[i]
		local idx = num_or(equipment_slots[slot[1]])
		if idx == 0 and (slot[1] == "melee_2" or slot[1] == "melee_3") then
			-- skip melee_2 and melee_3 if nothing wielded. This could possibly
			-- be incorrect if stats were different on some races.
		else
			local item = wml.get_nth_child(slot[2], slot[3], tonumber(idx) + 1)
			if not item then
-- 				std_print("why not" .. slot[3] .. "?\n" .. dump_wml_value(slot[2]))
			else
				local info = eval_item(item)
				if slot[1] == "melee_1" then
					adjust.melee1_name = item.name
					adjust.melee1_user_name = item.name
					adjust.magic_type = info.magic_type
					adjust.magic_bonus = info.magic_bonus or 0
				end
				for k, v in pairs(info.adjust) do
					adjust[k] = num_or(adjust[k]) + v
				end
			end
		end
	end
-- 	std_print(dump_lua_value(adjust, "eval_equipment"))
	return adjust
end



local function dcp(parsed, aflag)
	local clone
	if aflag then
		clone = {}
		for i = 1, #parsed do
			table.insert(clone, dcp(parsed[i]))
		end
	else
		clone = { k = {}, c = {} }
		for k,v in pairs(parsed.k) do
			clone.k[k] = v
		end
		for k,a in pairs(parsed.c) do
			clone.c[k] = {}
			for i = 1, #a do
				table.insert(clone.c[k], a[i])
			end
		end
	end
	return clone
end

local function get_p(parsed, relative)
	local aflag, t, v = false, parsed
	if type(relative) ~= "nil" then
		for pn in string.gmatch(relative, "[^%.]+") do
			v = nil
			if aflag then
				t = t[1]
				aflag = false
			end
			if not t then break end
			local p, n = string.match(pn, "^([%a%d_]+)%[(%d+)%]$")
			if not p then
				p = string.match(pn, "^([%a%d_]+)$")
			end
			if n then
				local i = tonumber(n) + 1
				if t.c[p] and t.c[p][i] then
					t = t.c[p][i]
				else
					t = nil
				end
			elseif p then
				if type(t.k[p]) ~= "nil" then
					v = t.k[p]
				elseif t.c[p] then
					t = t.c[p]
					aflag = true
				else
					t = nil
				end
			else
				werr(string.format("malformed path segment: %s", pn))
			end
		end
	end
	if t and not v then
		t = dcp(t, aflag)
	end
	return v or t
end

local function get_n(parsed, relative, num)
	local p = get_p(parsed, relative)
	return tonumber(p) or tonumber(num) or 0
end

local function clear_p(parsed, relative)
	if type(relative) ~= "nil" then
		local p, n, np = string.match(relative, "^([%a%d_]+)%[(%d+)%]%.([%a%d%[%]%._]+)$")
		if p then
			local i = tonumber(n) + 1
			if parsed.c[p] and parsed.c[p][i] then
				clear_p(parsed.c[p][i], np)
			end
		else
			p, np = string.match(relative, "^([%a%d_]+)%.([%a%d%[%]%._]+)$")
			if p then
				if parsed.c[p] and parsed.c[p][1] then
					clear_p(parsed.c[p][1], np)
				end
			else
				p, n = string.match(relative, "^([%a%d_]+)%[(%d+)%]$")
				if p then
					local i = tonumber(n) + 1
					if parsed.c[p] and parsed.c[p][i] then
						table.remove(parsed.c[p], i)
					end
				else
					p = string.match(relative, "^([%a%d_]+)$")
					if p then
						if type(parsed.k[p]) ~= "nil" then
							parsed.k[p] = nil
						elseif parsed.c[p] then
							parsed.c[p] = nil
						end
					else
						werr(string.format("malformed path segment: %s", relative))
					end
				end
			end
		end
	else
		parsed = nil
	end
	return parsed
end

local function set_p(parsed, relative, value, pflag)
	if type(value) == "nil" then
		clear_p(parsed, relative)
	elseif type(relative) ~= "nil" then
		local p, n, np = string.match(relative, "^([%a%d_]+)%[(%d+)%]%.([%a%d%[%]%._]+)$")
		if p then
			local i = tonumber(n) + 1
			if not parsed.c[p] then
				parsed.c[p] = { { k = {}, c = {} } }
			end
			for j = #parsed.c[p] + 1, i do
				table.insert(parsed.c[p], { k = {}, c = {} })
			end
			set_p(parsed.c[p][i], np, value, pflag)
		else
			p, np = string.match(relative, "^([%a%d_]+)%.([%a%d%[%]%._]+)$")
			if p then
				if not (parsed.c[p] and parsed.c[p][1]) then
					parsed.c[p] = { { k = {}, c = {} } }
				end
				set_p(parsed.c[p][1], np, value, pflag)
			else
				p, n = string.match(relative, "^([%a%d_]+)%[(%d+)%]$")
				if p then
					local i = tonumber(n) + 1
					if type(value) == "table" then
						if not parsed.c[p] then
							parsed.c[p] = {}
						end
						if #parsed.c[p] < i then
							for j = #parsed.c[p] + 1, i - 1 do
								table.insert(parsed.c[p], { k = {}, c = {} })
							end
						else
							table.remove(parsed.c[p], i)
						end
						if pflag then
							table.insert(parsed.c[p], i, dcp(value))
						else
							table.insert(parsed.c[p], i, parse_container(value))
						end
					else
						werr(string.format("attempt to assign scalar value to array element: %s", relative))
					end
				else
					p = string.match(relative, "^([%a%d_]+)$")
					if p then
						if type(value) == "table" then
							parsed.c[p] = {}
							if pflag then
								table.insert(parsed.c[p], dcp(value))
							else
								table.insert(parsed.c[p], parse_container(value))
							end
						else
							parsed.k[p] = value
						end
					else
						werr(string.format("malformed path segment: %s", relative))
					end
				end
			end
		end
	elseif pflag then
		parsed = dcp(value)
	else
		parsed = parse_container(value)
	end
	return parsed
end

local function get_unit_equipment(unit)
	local equipment = {}
	equipment.head_armor = get_p(unit, string.format("variables.inventory.armor.head[%d]", math.max(0, get_n(unit, "variables.equipment_slots.head_armor"))))
	equipment.torso_armor = get_p(unit, string.format("variables.inventory.armor.torso[%d]", math.max(0, get_n(unit, "variables.equipment_slots.torso_armor"))))
	equipment.leg_armor = get_p(unit, string.format("variables.inventory.armor.legs[%d]", math.max(0, get_n(unit, "variables.equipment_slots.leg_armor"))))
	equipment.shield = get_p(unit, string.format("variables.inventory.armor.shield[%d]", math.max(0, get_n(unit, "variables.equipment_slots.shield"))))
	equipment.melee_1 = get_p(unit, string.format("variables.inventory.weapons.melee[%d]", math.max(0, get_n(unit, "variables.equipment_slots.melee_1"))))
	local wield_skill, block_wield = get_n(unit, "variables.abilities.wield"), get_n(equipment.shield, "block_wield")
	if wield_skill > 0 and block_wield < 2 then
		equipment.melee_2 = get_p(unit, string.format("variables.inventory.weapons.melee[%d]", math.max(0, get_n(unit, "variables.equipment_slots.melee_2"))))
		if wield_skill == 2 and block_wield == 0 then
			equipment.melee_3 = get_p(unit, string.format("variables.inventory.weapons.melee[%d]", math.max(0, get_n(unit, "variables.equipment_slots.melee_3"))))
		end
	end
	-- thrown[0] is a valid field. Keep it.
	equipment.thrown = get_p(equipment.melee_1, "thrown[0]")
	if get_n(equipment.shield, "block_ranged") == 0 and get_n(unit, "variables.npc_init.no_ranged") == 0 then
		equipment.ranged = get_p(unit, string.format("variables.inventory.weapons.ranged[%d]", math.max(0, get_n(unit, "variables.equipment_slots.ranged"))))
	end
	return equipment
end

local function get_attack_basics(unit, equipment, weapon)
	local attack = {
		description = get_p(weapon, "description"),
		name = get_p(weapon, "name"),
		user_name = get_p(weapon, "user_name"),
		type = get_p(weapon, "type"),
		icon = string.format("attacks/%s.png", get_p(weapon, "icon")),
		range = get_p(weapon, "range"),
		material = get_p(weapon, "material")
	}
	local percent_mult, skill_dam, skill_num = 1.0, 1, 0
	local weapon_class = get_p(weapon, "class")
	if weapon_class == "magical" or weapon_class == "spell" then
		skill_dam = get_n(unit, "variables.abilities.magic_casting.power") * get_n(weapon, "spell_power", 1)
		skill_num = get_n(unit, "variables.abilities.magic_casting.speed")
	else
		if get_n(weapon, "number") < 2 then
			skill_dam = 2
		end
		skill_dam = skill_dam * get_n(unit, string.format("variables.weapon_skills.%s.damage", weapon_class), 1)
		skill_num = get_n(unit, string.format("variables.weapon_skills.%s.attack", weapon_class))
	end
	local function add_stat_adjusts(stat)
		local stat_level = get_n(unit, "variables." .. stat)
		skill_dam = skill_dam + get_n(weapon, stat .. "_damage_rate") * stat_level * 0.01
		skill_num = skill_num + get_n(weapon, stat .. "_number_rate") * stat_level * 0.01
		local prereq = get_n(weapon, "prereq." .. stat)
		if prereq > stat_level then
			percent_mult = percent_mult * stat_level / prereq
		end
	end
	add_stat_adjusts("body")
	add_stat_adjusts("deft")
	add_stat_adjusts("mind")
	if weapon_class == "spell" then
		local spell_bonus_type = get_p(weapon, "bonus_type")
		local armor_penalty = get_n(equipment.shield, "magic_adjust") + get_n(equipment.head_armor, "magic_adjust") + get_n(equipment.torso_armor, "magic_adjust") + get_n(equipment.leg_armor, "magic_adjust")
		if spell_bonus_type == "runic_magic_adjust" then
			armor_penalty = armor_penalty * 0.5
			if get_p(equipment.melee_1, "user_name") == "hammer" then
				armor_penalty = math.min(0, armor_penalty + 3 * get_n(unit, "variables.abilities.magic_casting.focus"))
			end
		elseif get_p(weapon, "name") == "faerie fire" then
			if get_p(equipment.melee_1, "name") == "sword" then
				armor_penalty = math.min(0, armor_penalty + 3 * get_n(unit, "variables.abilities.magic_casting.focus"))
			end
		end
		percent_mult = percent_mult * math.max(0, 100 + get_n(equipment.melee_1, spell_bonus_type) + armor_penalty) * 0.01
	elseif attack.range == "ranged" then
		percent_mult = percent_mult * math.max(0, 100 + get_n(equipment.head_armor, "ranged_adjust") + get_n(equipment.shield, "ranged_adjust")) * 0.01
	end
	local unit_race = get_p(unit, "race")
	if unit_race == "elf" then
--                [weapon_skills]
--                    [race_adjust]
--                        [class]
--                            [bow]
--                                number_hard=1
--                            [/bow]
--                        [/class]
--                    [/race_adjust]
--                [/weapon_skills]
		if weapon_class == "bow" then
			skill_num = skill_num + 1
		end
	elseif unit_race == "dwarf" then
--                [weapon_skills]
--                    [race_adjust]
--                        [user_name]
--                            [axe]
--                                number_hard=1
--                                damage_percent=-20
--                            [/axe]
--                            [hammer]
--                                damage_percent=20
--                            [/hammer]
--                        [/user_name]
--                    [/race_adjust]
--                [/weapon_skills]
		local weapon_type = get_p(weapon, "user_name")
		if weapon_type == "axe" then
			skill_num = skill_num + 1
			percent_mult = percent_mult * 0.8
		elseif weapon_type == "hammer" then
			percent_mult = percent_mult * 1.2
		end
	elseif unit_race == "troll" then
--                [weapon_skills]
--                    [race_adjust]
--                        [class]
--                            [light_blade]
--                                damage_percent=-25
--                            [/light_blade]
--                            [heavy_blade]
--                                damage_percent=-25
--                            [/heavy_blade]
--                            [polearm]
--                                damage_percent=-25
--                            [/polearm]
--                            [thrown_light_blade]
--                                damage_percent=-25
--                            [/thrown_light_blade]
--                            [thrown_heavy_blade]
--                                damage_percent=-25
--                            [/thrown_heavy_blade]
--                            [bow]
--                                damage_percent=-25
--                            [/bow]
--                            [javelin]
--                                damage_percent=-25
--                            [/javelin]
--                            [crossbow]
--                                damage_percent=-25
--                            [/crossbow]
--                            [none]
--                                damage_percent=-25
--                            [/none]
--                        [/class]
--                    [/race_adjust]
--                [/weapon_skills]
		if weapon_class ~= "bludgeon" and weapon_class ~= "lob" then
			percent_mult = percent_mult * 0.75
		end
	elseif unit_race == "lizard" then
--                [weapon_skills]
--                    [race_adjust]
--                        [class]
--                            [polearm]
--                                number_hard=1
--                                damage_percent=-20
--                            [/polearm]
--                            [javelin]
--                                number_hard=1
--                                damage_percent=-20
--                            [/javelin]
--                        [/class]
--                    [/race_adjust]
--                [/weapon_skills]
		if weapon_class == "polearm" or weapon_class == "javelin" then
			skill_num = skill_num + 1
			percent_mult = percent_mult * 0.8
		end
	end
	attack.damage = math.max(1, math.floor(percent_mult * (get_n(weapon, "damage") + skill_dam)))
	attack.number = math.floor(get_n(weapon, "number") + skill_num)
	local target_level = get_n(unit, "variables.abilities.target")
	if target_level > 0 and get_n(weapon, "special_type.backstab") > 0 then
		attack.damage = math.ceil(attack.damage * 0.5 * (3 + target_level))
		attack.number = math.ceil(attack.number * 0.5)
	end
	if get_n(unit, "variables.abilities.witch_magic") == 4 then
		attack.damage = math.floor(attack.damage * 1.5 + 0.5)
	end
	if weapon_class == "light_blade" and get_n(unit, "variables.abilities.witchcraft") == 1 and get_n(unit, "variables.abilities.magic_casting.power") > 0 then
		attack.number = math.ceil(attack.number * 0.5)
	end
	if attack.user_name == "hammer" and get_n(unit, "variables.abilities.devling_spiker") > 0 then
		attack.description = "nail 'em"
		attack.damage = math.floor(attack.damage * attack.number + 0.5)
		attack.number = 1
	end
	if attack.user_name == "spike 'em" then
		attack.damage = math.floor(attack.damage * attack.number * 1.25 + 0.5)
		attack.number = 1
	end
	return attack, weapon_class
end

function child(obj, ...)
	local k, v
	local ret = obj
	for k, v in ipairs(table.pack(...)) do
		if not ret then return nil end
		ret = ret[v] or wml.get_child(ret, v) or nil
	end
	return ret
end

function nchild(obj, ...)
	local ret = child(obj, ...)
	return ret and tonumber(ret) or 0
end

function get_attack_basics_light(unit, weapon)
	-- use both a wml or a unit
-- 	local unit_variables = unit and unit.variables or wml.get_child(unit, "variables")
	local unit_variables = child(unit, "variables")
	if not unit_variables then return {} end
	local res = {
		damage		= 1,
		number		= 0,
		description	= weapon.description,
		name		= weapon.name,
		user_name	= weapon.user_name,
		type		= weapon.type,
		icon		= string.format("attacks/%s.png", weapon.icon),
		range		= weapon.range,
		material	= weapon.material,
		prereq		= wml.get_child(weapon, "prereq")
	}
	local percent_mult = 1.0
	local var_abilities = child(unit_variables, "abilities")
	local magic_casting = child(var_abilities, "magic_casting")
	local adjust = child(unit_variables, "adjust")
	local weapon_special_type = child(weapon, "special_type")
	if weapon.class == "magical" or weapon.class == "spell" then
		res.damage = nchild(magic_casting, "power") * num_or(weapon.spell_power, 1)
		res.number = nchild(magic_casting, "speed")

-- 		local spell_bonus_type = weapon.bonus_type
		local armor_penalty = num_or(adjust.magic)
		if weapon.runic_magic_adjust and armor_penalty < 0 then
			armor_penalty = armor_penalty * 0.5
		end
		if (weapon.runic_magic_adjust and adjust.melee1_user_name == "hammer") or
		   (weapon.name == "faerie fire" and adjust.melee1_name == "sword") then
			armor_penalty = math.min(0, armor_penalty + 3 * magic_casting.focus)
		end
		percent_mult = math.max(0, 100 + adjust.magic_bonus + armor_penalty) / 100
	else
		local weapon_skills = child(unit_variables, "weapon_skills")
		local skill = child(weapon_skills, weapon.class)
		if weapon.number < 2 then
			res.damage = 2
		end
		res.damage = res.damage * num_or(skill and skill.damage or nil, 1)
		res.number = num_or(skill and skill.attack or nil, 0)

		if res.range == "ranged" then
			percent_mult = math.max(0, 100 + adjust.ranged) / 100
		end
	end
	local function add_stat_adjusts(stat)
		local stat_level = nchild(unit_variables, stat)
		res.damage = res.damage + num_or(weapon[stat .. "_damage_rate"]) * stat_level / 100
		res.number = res.number + num_or(weapon[stat .. "_number_rate"]) * stat_level / 100
		local prereq = res.prereq and res.prereq[stat] or 0
		if prereq > stat_level then
			percent_mult = percent_mult * stat_level / prereq
		end
	end
	add_stat_adjusts("body")
	add_stat_adjusts("deft")
	add_stat_adjusts("mind")

	if unit.race == "elf" then
--                [weapon_skills]
--                    [race_adjust]
--                        [class]
--                            [bow]
--                                number_hard=1
--                            [/bow]
--                        [/class]
--                    [/race_adjust]
--                [/weapon_skills]
		if weapon.class == "bow" then
			res.number = res.number + 1
		end
	elseif unit.race == "dwarf" then
--                [weapon_skills]
--                    [race_adjust]
--                        [user_name]
--                            [axe]
--                                number_hard=1
--                                damage_percent=-20
--                            [/axe]
--                            [hammer]
--                                damage_percent=20
--                            [/hammer]
--                        [/user_name]
--                    [/race_adjust]
--                [/weapon_skills]
		if weapon.user_name == "axe" then
			res.number = res.number + 1
			percent_mult = percent_mult * 0.8
		elseif weapon.user_name == "hammer" then
			percent_mult = percent_mult * 1.2
		end
	elseif unit.race == "troll" then
--                [weapon_skills]
--                    [race_adjust]
--                        [class]
--                            [light_blade]
--                                damage_percent=-25
--                            [/light_blade]
--                            [heavy_blade]
--                                damage_percent=-25
--                            [/heavy_blade]
--                            [polearm]
--                                damage_percent=-25
--                            [/polearm]
--                            [thrown_light_blade]
--                                damage_percent=-25
--                            [/thrown_light_blade]
--                            [thrown_heavy_blade]
--                                damage_percent=-25
--                            [/thrown_heavy_blade]
--                            [bow]
--                                damage_percent=-25
--                            [/bow]
--                            [javelin]
--                                damage_percent=-25
--                            [/javelin]
--                            [crossbow]
--                                damage_percent=-25
--                            [/crossbow]
--                            [none]
--                                damage_percent=-25
--                            [/none]
--                        [/class]
--                    [/race_adjust]
--                [/weapon_skills]
		if weapon.class ~= "bludgeon" and weapon.class ~= "lob" then
			percent_mult = percent_mult * 0.75
		end
	elseif unit.race == "lizard" then
--                [weapon_skills]
--                    [race_adjust]
--                        [class]
--                            [polearm]
--                                number_hard=1
--                                damage_percent=-20
--                            [/polearm]
--                            [javelin]
--                                number_hard=1
--                                damage_percent=-20
--                            [/javelin]
--                        [/class]
--                    [/race_adjust]
--                [/weapon_skills]
		if weapon.class == "polearm" or weapon.class == "javelin" then
			res.number = res.number + 1
			percent_mult = percent_mult * 0.8
		end
	end
	res.damage = math.max(1, math.floor(percent_mult * (weapon.damage + res.damage)))
	res.number = math.floor(weapon.number + res.number)
	local target_level = var_abilities and num_or(var_abilities.target) or 0
	if target_level > 0 and nchild(weapon_special_type, "backstab") > 0 then
		res.damage = math.ceil(res.damage * 0.5 * (3 + target_level))
		res.number = math.ceil(res.number * 0.5)
	end
	if var_abilities and num_or(var_abilities.witch_magic) >= 4 then
		res.damage = math.floor(res.damage * 1.5 + 0.5)
	end
	if weapon.class == "light_blade" and
			nchild(var_abilities, "witchcraft") == 1 and
			nchild(magic_casting, "power") > 0 then
		res.number = math.ceil(res.number * 0.5)
	end
	if res.user_name == "hammer" and var_abilities and nchild(var_abilities, "devling_spiker") > 0 then
		res.description = "nail 'em"
		res.damage = mathx.round(res.damage * res.number)
		res.number = 1
	end
	if res.user_name == "spike 'em" then
		res.damage = mathx.round(res.damage * res.number * 1.25)
		res.number = 1
	end
	return res, weapon.class
end

function wesnoth.wml_actions.calculate_weapon_display(args)
	local unit_var = args.unit_variable or werr("[calculate_weapon_display] requires a unit_variable= key")
	local weapon_var = args.weapon_variable or werr("[calculate_weapon_display] requires a weapon_variable= key")
	local unit = parse_container(wml.variables[unit_var])
	local equipment = get_unit_equipment(unit)
	local weapon = parse_container(wml.variables[weapon_var])
	local attack = get_attack_basics(unit, equipment, weapon)
	wml.variables["display_damage"] = attack.damage
	wml.variables["display_number"] = attack.number
end

local function find_npc_value(unit, params)
	params = params or {}
	local modifiers = { -- any of these values can be overridden by the passed in parameters
		arcane = params.arcane_mod or 1.5,
		impact = params.impact_mod or 1.15,
		fire = params.fire_mod or 1.35,
		cold = params.cold_mod or 1.3,
		pierce = params.pierce_mod or 1.1,
		blade = params.blade_mod or 1,
		ranged = params.ranged_mod or 1.1,
		magical = params.magical_mod or 1.7,
		marksman = params.marksman_mod or 1.4,
		poison = params.poison_mod or 6,
		charge = params.charge_mod or 1.1,
		plague = params.plague_mod or 1.1,
		soultrap = params.soultrap_mod or 1.2,
		drains = params.drains_mod or 2.5,
		slow = params.slow_mod or 1.5,
		rage = params.rage_mod or 1.8,
		berserk = params.berserk_mod or 2.2,
		slashdash = params.slashdash_mod or 1.5,
		accuracy = params.accuracy_mod or 1.2,
		evasion = params.evasion_mod or 1.4,
		goliath = params.goliath_mod or 1.6,
		ensnare = params.ensnare_mod or 1.2,
		pointpike = params.pointpike_mod or 1.2,
		storm = params.storm_mod or 1.2,
		brutal = params.brutal_mod or 1.3,
		dread = params.dread_mod or 1.6,
		firststrike = params.firststrike_mod or 1.2,
		cleave = params.cleave_mod or 1.8,
		riposte = params.riposte_mod or 1.3,
		ammo = params.ammo_mod or 1.8,
		bloodlust = params.bloodlust_mod or 1.5,
		grace = params.grace_mod or 1.4,
		steadfast = params.steadfast_mod or 0.006,
		feeding = params.feeding_mod or 1.05,
		dash = params.dash_mod or 1.1,
		illuminates = params.illuminates_mod or 1.1,
		submerge = params.submerge_mod or 1.01,
		tutor = params.tutor_mod or 1.1,
		loner = params.loner_mod or 1.1,
		cold_aura = params.cold_aura_mod or 1.2,
		dark_aura = params.dark_aura_mod or 2,
		deadzone = params.deadzone_mod or 4,
		ambush_forest = params.ambush_forest_mod or 1.1,
		ambush_mountains = params.ambush_mountains_mod or 1.1,
		sneak = params.sneak_mod or 1.5,
		nightstalk = params.nightstalk_mod or 1.1,
		healthy = params.healthy_mod or 3,
		undead = params.undead_mod or 1.1,
		fearless = params.fearless_mod or 1.05,
		skirmisher = params.skirmisher_mod or 1.2
	}
	local function move_cost_modifer(terrain_type, base, multiplier, offset)
		return 1 + (offset or 0) + (multiplier or 0.7) * ((base or 2) - math.min(get_n(unit, "movement_costs." .. terrain_type), 5))
	end
	local function resist_value(damage_type, base)
		return math.max(0, (200 - base - get_n(unit, "resistance." .. damage_type)) / modifiers[damage_type])
	end
	local function defense_value(terrain_type, base, divisor)
		return (100 - base - get_n(unit, "defense." .. terrain_type)) / divisor
	end
	local values = { -- get basic values
		hp = get_n(unit, "max_hitpoints") * 1.1,
		moves = (get_n(unit, "max_moves") * 0.04 + 0.6) * move_cost_modifer("swamp_water", 3) * move_cost_modifer("shallow_water", 3) * move_cost_modifer("forest") * move_cost_modifer("frozen", 3, 0.04, -0.01) * move_cost_modifer("hills", 2, 0.1) * move_cost_modifer("mountains", 3, 0.05) * move_cost_modifer("cave", 2, 0.1, 0.05) * move_cost_modifer("fungus") * move_cost_modifer("sand"),
		resists = 1.35 * (resist_value("arcane", 50) + resist_value("blade", 50) + resist_value("cold", 50) + resist_value("fire", 50) + resist_value("impact", 50) + resist_value("pierce", 50)) / (1 / modifiers.arcane + 1 / modifiers.blade + 1 / modifiers.cold + 1 / modifiers.fire + 1 / modifiers.impact + 1 / modifiers.pierce) - 17.5, -- no idea the rationale behind this formula, but it seems to be what the WML version converts to
		defense = 50 + defense_value("flat", 50, 3) + defense_value("swamp_water", 20, 8) + defense_value("forest", 50, 4) + defense_value("hills", 50, 2) + defense_value("frozen", 20, 10) + defense_value("mountains", 60, 5) + defense_value("cave", 40, 3) + defense_value("sand", 30, 4),
		attacks = 0,
		melee = {},
		ranged = {}
	}
	-- apply ability modifiers
	if (get_p(unit, "abilities.skirmisher.id") or "none") == "skirmisher" then
		values.moves = values.moves * modifiers.skirmisher
	end
	local ability_array = get_p(unit, "abilities.resistance")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "steadfast" then
				if values.resists > 75 then
					values.resists = math.max(1, 100 - values.resists)
				else
					values.resists = math.max(1, values.resists - 50)
				end
			elseif ability_id == "deadzone" then
				values.defense = values.defense * modifiers.deadzone
			elseif ability_id == "coldaura" then
				values.defense = values.defense * modifiers.cold_aura
			end
		end
	end
	ability_array = get_p(unit, "abilities.regenerate")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "regenerates" then
				values.hp = values.hp + get_n(ability_array[i], "value")
			end
		end
	end
	ability_array = get_p(unit, "abilities.heals")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "healing" then
				values.defense = values.defense + 2 * get_n(ability_array[i], "value")
			end
		end
	end
	ability_array = get_p(unit, "abilities.leadership")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "leadership" then
				values.defense = values.defense + 5
			elseif ability_id == "loner" then
				values.defense = values.defense * modifiers.loner
			elseif ability_id == "darkaura" then
				values.defense = values.defense * modifiers.dark_aura
			end
		end
	end
	ability_array = get_p(unit, "abilities.dummy")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "wbd_feeding" then
				values.hp = values.hp * modifiers.feeding
			elseif ability_id == "dash" then
				values.defense = values.defense * modifiers.dash
			elseif ability_id == "battletutor" then
				values.defense = values.defense * modifiers.tutor
			end
		end
	end
	ability_array = get_p(unit, "abilities.illuminates")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "illumination" then
				values.defense = values.defense * modifiers.illuminates
			end
		end
	end
	ability_array = get_p(unit, "abilities.hides")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "submerge" then
				values.defense = values.defense * modifiers.submerge
			elseif ability_id == "ambush_forest" then
				values.defense = values.defense * modifiers.ambush_forest
			elseif ability_id == "ambush_mountains" then
				values.defense = values.defense * modifiers.ambush_mountains
			elseif ability_id == "sneak" then
				values.defense = values.defense * modifiers.sneak
			elseif ability_id == "nightstalk" then
				values.defense = values.defense * modifiers.nightstalk
			end
		end
	end
	ability_array = get_p(unit, "modifications.trait")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "healthy" then
				values.hp = values.hp + modifiers.healthy
			elseif ability_id == "undead" then
				values.defense = values.defense * modifiers.undead
			elseif ability_id == "fearless" then
				values.defense = values.defense * modifiers.fearless
			end
		end
	end

	-- evaluate attacks
	local attack_array = get_p(unit, "attack")
	local function process_attack_set(attack_set)
		local result = 0
		if #attack_set > 0 then
			table.sort(attack_set, function(a, b) return a.value > b.value end)
			result = attack_set[1].value
			for i = 2, #attack_set do
				if attack_set[i].specials and attack_set[1].type ~= attack_set[i].type then
					result = result * (1.05 + math.max(0, attack_set[i].value - 0.9 * attack_set[1].value))
				else
					result = result * 0.999
				end
			end
		end
		return result
	end
	if type(attack_array) == "table" then
		for i = 1, #attack_array do
			local attack_eval = {
				type = get_p(attack_array[i], "type"),
				specials = false
			}
			attack_eval.value = get_n(attack_array[i], "damage") * get_n(attack_array[i], "number") * modifiers[attack_eval.type]
			ability_array = get_p(attack_array[i], "specials.backstab")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "backstab" then
						attack_eval.value = attack_eval.value * math.max(1.05, values.moves)
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.charge")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "charge" then
						attack_eval.value = attack_eval.value * modifiers.charge
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.plague")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "plague" then
						attack_eval.value = attack_eval.value * modifiers.plague
						attack_eval.specials = true
					elseif ability_id == "plague_wbd" then
						attack_eval.value = attack_eval.value * modifiers.plague
						attack_eval.specials = true
					elseif ability_id == "soultrap" then
						attack_eval.value = attack_eval.value * modifiers.soultrap
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.drains")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "drains" then
						attack_eval.value = attack_eval.value * modifiers.drains
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.slow")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "slow" then
						attack_eval.value = attack_eval.value * modifiers.slow
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.berserk")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "rage" then
						attack_eval.value = attack_eval.value * modifiers.rage
						attack_eval.specials = true
					elseif ability_id == "berserk" then
						attack_eval.value = attack_eval.value * modifiers.berserk
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.damage")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "evasion" then
						attack_eval.value = attack_eval.value * modifiers.evasion
						attack_eval.specials = true
					elseif ability_id == "goliath_bane" then
						attack_eval.value = attack_eval.value * modifiers.goliath
						attack_eval.specials = true
					elseif ability_id == "dread" then
						attack_eval.value = attack_eval.value * modifiers.dread
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.attacks")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "storm" then
						attack_eval.value = attack_eval.value * modifiers.storm
						attack_eval.specials = true
					elseif ability_id == "brutal" then
						attack_eval.value = attack_eval.value * modifiers.brutal
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.firststrike")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "firststrike" then
						attack_eval.value = attack_eval.value * modifiers.firststrike
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.dummy")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "slashdash" then
						attack_eval.value = attack_eval.value * modifiers.slashdash
						attack_eval.specials = true
					elseif ability_id == "cleave" then
						attack_eval.value = attack_eval.value * modifiers.cleave
						attack_eval.specials = true
					elseif ability_id == "remaining_ammo" then
						attack_eval.value = attack_eval.value * modifiers.ammo
						attack_eval.specials = true
					elseif ability_id == "bloodlust" then
						attack_eval.value = attack_eval.value * modifiers.bloodlust
						attack_eval.specials = true
					elseif ability_id == "grace" then
						attack_eval.value = attack_eval.value * modifiers.grace
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.poison")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "poison" then
						attack_eval.value = attack_eval.value + modifiers.poison + get_n(attack_array[i], "number")
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.chance_to_hit")
			if type(ability_array) == "table" then
				for ii = 1, #ability_array do
					local ability_id = get_p(ability_array[ii], "id") or "none"
					if ability_id == "magical" then
						attack_eval.value = attack_eval.value * modifiers.magical
						attack_eval.specials = true
					elseif ability_id == "marksman" then
						attack_eval.value = attack_eval.value * modifiers.marksman
						attack_eval.specials = true
					elseif ability_id == "riposte" then
						attack_eval.value = attack_eval.value * modifiers.riposte
						attack_eval.specials = true
					elseif ability_id == "pointpike" then
						attack_eval.value = attack_eval.value * modifiers.pointpike
						attack_eval.specials = true
					elseif ability_id == "ensnare" then
						attack_eval.value = attack_eval.value * modifiers.ensnare
						attack_eval.specials = true
					elseif ability_id == "accuracy" then
						attack_eval.value = attack_eval.value * modifiers.accuracy
						attack_eval.specials = true
					end
				end
			end
			table.insert(values[get_p(attack_array[i], "range")], attack_eval)
		end
		local melee_val, ranged_val = process_attack_set(values.melee), process_attack_set(values.ranged)
		if melee_val > ranged_val then
			values.attacks = melee_val + ranged_val * 0.5
		else
			values.attacks = ranged_val + melee_val * 0.5
		end
	end
	return values.hp * (values.defense + values.resists) * values.moves * values.attacks / 3005.6
end

local function find_equipment_value(unit)
	local function total_type_value(equipment_type)
		local equipment_array, value = get_p(unit, "variables.inventory." .. equipment_type), 0
		if type(equipment_array) == "table" then
			for i = 1, #equipment_array do
				value = value + math.floor(get_n(equipment_array[i], "absolute_value") * 0.2 + 0.5)
			end
		end
		return value
	end
	return total_type_value("weapons.melee") + total_type_value("weapons.ranged") + total_type_value("armor.head") + total_type_value("armor.torso") + total_type_value("armor.legs") + total_type_value("armor.shield")
end

local function constructUnit(var, unstore)
	local unit = parse_container(wml.variables[var])
	--std_print("constructUnit type= " .. (get_p(unit, "type") or "") .. " side= " .. get_n(unit, "side") .. " name= " .. (get_p(unit, "name") or ""))
	local player = get_n(unit, "side") <= wml.variables["const.max_player_count"] and get_p(unit, "canrecruit")

	-- melee[0] is a valid field. Keep it. Replaces fists.
	if get_n(unit, "variables.abilities.faerie_touch") > 0 and get_p(unit, "variables.inventory.weapons.melee[0].user_name") ~= "faerie touch" then
		local faerie_touch = get_p(unit, "variables.inventory.weapons.melee[0]")
		set_p(faerie_touch, "special_type", { magical_to_hit = 1 })
		faerie_touch = unparse_container(faerie_touch)
		faerie_touch.icon = "touch-faerie"
		faerie_touch.user_name = "faerie touch"
		faerie_touch.description = "faerie touch"
		faerie_touch.class = "magical"
		faerie_touch.class_description = "Magical"
		if get_n(unit, "variables.abilities.faerie_touch") == 2 then
			faerie_touch.type = "arcane"
		end
		faerie_touch.body_damage_rate = 0
		faerie_touch.deft_damage_rate = 5
		faerie_touch.mind_damage_rate = 10
		faerie_touch.deft_number_rate = 5
		faerie_touch.mind_number_rate = 5
		set_p(unit, "variables.inventory.weapons.melee[0]", adjustWeaponDescription(faerie_touch))
	elseif get_n(unit, "variables.abilities.lich_touch") == 1 and get_p(unit, "variables.inventory.weapons.melee[0].user_name") ~= "lich touch" then
		local lich_touch = get_p(unit, "variables.inventory.weapons.melee[0]")
		set_p(lich_touch, "special_type", { spell_drains = 1 })
		lich_touch = unparse_container(lich_touch)
		lich_touch.icon = "touch-undead"
		lich_touch.user_name = "lich touch"
		lich_touch.description = "lich touch"
		lich_touch.class = "magical"
		lich_touch.class_description = "Magical"
		lich_touch.type = "arcane"
		lich_touch.body_damage_rate = 0
		lich_touch.deft_damage_rate = 5
		lich_touch.mind_damage_rate = 10
		lich_touch.deft_number_rate = 5
		lich_touch.mind_number_rate = 5
		set_p(unit, "variables.inventory.weapons.melee[0]", adjustWeaponDescription(lich_touch))
	end
	clear_p(unit, "variables.inventory.type")
	local weapon_list = get_p(unit, "variables.inventory.weapons.melee") or {}
	for i = 1, #weapon_list do
		local weapon_class_path = "variables.inventory.type." .. get_p(weapon_list[i], "class")
		set_p(unit, weapon_class_path, 1 + get_n(unit, weapon_class_path))
		local thrown = get_p(weapon_list[i], "thrown")
		if thrown then
			weapon_class_path = "variables.inventory.type." .. get_p(weapon_list[i], "thrown.class")
			set_p(unit, weapon_class_path, 1 + get_n(unit, weapon_class_path))
		end
	end
	weapon_list = get_p(unit, "variables.inventory.weapons.ranged") or {}
	for i = 1, #weapon_list do
		local weapon_class_path = "variables.inventory.type." .. get_p(weapon_list[i], "class")
		set_p(unit, weapon_class_path, 1 + get_n(unit, weapon_class_path))
		if weapon_class_path == "thunderstick" then
			local max_damage = get_n(weapon_list[i], "max_damage")
			if max_damage > get_n(weapon_list[i], "damage") and get_n(weapon_list[i], "ts_level") <= get_n(unit, "variables.abilities.thunderstick_tinker") then
				set_p(unit, string.format("variables.inventory.weapons.ranged[%d].damage", i - 1), max_damage)
			end
		end
	end

	local equipment = get_unit_equipment(unit)
	local evade = 3 * get_n(unit, "variables.evade_level") + get_n(equipment.head_armor, "evade_adjust") + get_n(equipment.torso_armor, "evade_adjust") + get_n(equipment.leg_armor, "evade_adjust") + get_n(equipment.shield, "evade_adjust") + get_n(equipment.melee_1, "evade_adjust")
	if equipment.melee_2 then
		evade = evade + get_n(equipment.melee_2, "evade_adjust")
		if equipment.melee_3 then
			evade = evade + get_n(equipment.melee_3, "evade_adjust")
		end
	end
	set_p(unit, "variables.mobility", math.max(0, math.min(2, math.floor(evade / 4))))
	set_p(unit, "variables.abstract_moves", get_n(unit, "variables.max_moves"))
	if (not player) and get_n(unit, "variables.abilities.minotaur_magic") == 2 then
		set_p(unit, "max_moves", 8)
	else
		set_p(unit, "max_moves", math.floor(get_n(unit, "variables.max_moves") * math.min(1, 1 + evade * 0.01)))
	end
	set_p(unit, "moves", math.min(get_n(unit, "moves"), get_n(unit, "max_moves")))

	local function calculate_vulnerability(damage_type)
		-- Additive threshold -- the percentage for a vulnerability value below which armor resists are added
		-- together, beyond which armor resists are logarithmically combined. From a resistance view, 1
		-- respresents 0% resist and 0.9 10% resist
		local add_thresh = 1
		local i
		local bonus, penalty, deduct = 0, 0, 0
		local vul = math.max(0, get_n(unit, "variables.resistance." .. damage_type, 100)) / 100
		local equip = {
			{mult = 1, pct = 0, value = get_n(equipment.melee_1,     "resistance." .. damage_type) / 100},
			{mult = 1, pct = 0, value = get_n(equipment.melee_2,     "resistance." .. damage_type) / 100},
			{mult = 1, pct = 0, value = get_n(equipment.melee_3,     "resistance." .. damage_type) / 100},
			{mult = 1, pct = 0, value = get_n(equipment.ranged,      "resistance." .. damage_type) / 100},
			{mult = 1, pct = 0, value = get_n(equipment.torso_armor, "resistance." .. damage_type) / 100},
			{mult = 1, pct = 0, value = get_n(equipment.head_armor,  "resistance." .. damage_type) / 100},
			{mult = 1, pct = 0, value = get_n(equipment.leg_armor,   "resistance." .. damage_type) / 100},
			{mult = 1, pct = 0, value = get_n(equipment.shield,      "resistance." .. damage_type) / 100},
		}
		for i = 1, #equip do
			if equip[i].value > 0 then
				bonus = bonus + equip[i].value
			else
				penalty = penalty + equip[i].value
			end
		end

		-- Add the penalty to the base vulnerability
		vul = vul - penalty

		-- If we don't get down to at least 100%,  (i.e., negative resistance) then just
		-- return with that value
		if vul - bonus >= 1 then
			return vul - bonus
		end

		-- If net vulnerability (after equipment penalties) is > 100%, then we split it up into
		-- a "deduct" value, which will be subtracted from resists, and set vulnerability to
		-- 100%, which will be fractionally mitigated by equipment resists.
		if vul > add_thresh then
			deduct = vul - add_thresh
			vul = add_thresh
		end

		-- Determine the percentage of the total bonus that each piece is contributing
		for i = 1, #equip do
			if equip[i].value > 0 then
				equip[i].pct = equip[i].value / bonus
			end
		end

		for i = 1, #equip do
			-- Note that we don't need to check for items with penalties, because those will have zero pct.

			-- This calculates how much this piece of armor will reduce vulnerability
			local multiplier = 1 - equip[i].value * add_thresh + deduct * equip[i].pct
			-- Any piece that ends up over 100% here means we are invulnerable
			if multiplier < (1 - add_thresh) then
				return 0
			end
			equip[i].mult = multiplier
			vul = vul * multiplier
		end
-- 		std_print(dump_lua_value({vul, bonus, penalty, deduct, equip}, damage_type))
		return vul
	end

	local function set_resist(damage_type)
		local value = calculate_vulnerability(damage_type) * 100
-- 		std_print(dump_lua_value(value, damage_type))
		set_p(unit, "resistance." .. damage_type, value)
	end

	set_resist("arcane")
	set_resist("blade")
	set_resist("cold")
	set_resist("fire")
	set_resist("impact")
	set_resist("pierce")

	if (not player) and get_n(unit, "variables.abilities.minotaur_magic") > 0 then
		set_p(unit, "resistance.fire", math.max(0, get_n(unit, "resistance.fire") - 20))
	end

	local shield_recoup = get_n(equipment.shield, "terrain_recoup")
	local function set_movetype(terrain)
		local function check_num(data)
			if type(data) ~= "number" then
				werr(tostring(data) .. "is not a number")
			end
		end
		set_p(unit, "defense." .. terrain, math.max(20, get_n(unit, string.format("variables.terrain.%s.defense", terrain)) - math.max(0, evade) + math.max(0, get_n(equipment.torso_armor, string.format("terrain.%s.defense", terrain)) + get_n(equipment.leg_armor, string.format("terrain.%s.defense", terrain)) - shield_recoup)))
		local fixed_move = get_n(unit, string.format("variables.terrain.%s.movement", terrain))
		if fixed_move == 0 then
			fixed_move = 99
		end
		set_p(unit, "movement_costs." .. terrain, fixed_move)
	end
	set_movetype("unwalkable")
	set_movetype("castle")
	set_movetype("village")
	set_movetype("shallow_water")
	set_movetype("deep_water")
	set_movetype("flat")
	set_movetype("forest")
	set_movetype("hills")
	set_movetype("mountains")
	set_movetype("swamp_water")
	set_movetype("sand")
	set_movetype("cave")
	set_movetype("impassable")
	set_movetype("frozen")
	set_movetype("fungus")
	set_movetype("reef")

	if get_n(unit, "variables.abilities.faerie_form") == 1 then
		set_p(unit, "resistance.impact", get_n(unit, "resistance.impact") + 10)
		set_p(unit, "movement_costs.shallow_water", 1)
		set_p(unit, "movement_costs.deep_water", 2)
		set_p(unit, "movement_costs.hills", 1)
		set_p(unit, "movement_costs.mountains", 2)
		set_p(unit, "movement_costs.swamp_water", 1)
		set_p(unit, "movement_costs.sand", 1)
		set_p(unit, "movement_costs.cave", 2)
		set_p(unit, "movement_costs.frozen", 1)
		set_p(unit, "movement_costs.reef", 1)
		set_p(unit, "defense.reef", math.max(20, get_n(unit, "defense.reef") - 20))
		set_p(unit, "defense.deep_water", math.max(20, get_n(unit, "defense.deep_water") - 10))
		set_p(unit, "defense.flat", math.max(20, get_n(unit, "defense.flat") - 10))
		set_p(unit, "defense.frozen", math.max(20, get_n(unit, "defense.frozen") - 10))
		set_p(unit, "defense.sand", math.max(20, get_n(unit, "defense.sand") - 10))
		set_p(unit, "defense.shallow_water", math.max(20, get_n(unit, "defense.shallow_water") - 10))
		set_p(unit, "defense.swamp_water", math.max(20, get_n(unit, "defense.swamp_water") - 10))
	elseif not player then
		if get_n(unit, "variables.abilities.minotaur_magic") == 2 then
			set_p(unit, "defense", {
				unwalkable = 70,
				castle = 50,
				village = 50,
				shallow_water = 80,
				deep_water = 90,
				flat = 70,
				forest = 40,
				hills = 50,
				mountains = 30,
				swamp_water = 80,
				sand = 70,
				cave = 50,
				impassable = 70,
				frozen = 70,
				fungus = 50,
				reef = 70
			})
			set_p(unit, "movement_costs", {
				unwalkable = 1,
				castle = 1,
				village = 1,
				shallow_water = 2,
				deep_water = 2,
				flat = 1,
				forest = 1,
				hills = 1,
				mountains = 1,
				swamp_water = 1,
				sand = 1,
				cave = 1,
				impassable = 99,
				frozen = 1,
				fungus = 1,
				reef = 2
			})
		elseif get_n(unit, "variables.abilities.devling_flyer") == 1 then
			set_p(unit, "defense", {
				unwalkable = 50,
				castle = 50,
				village = 50,
				shallow_water = 50,
				deep_water = 50,
				flat = 50,
				forest = 50,
				hills = 50,
				mountains = 50,
				swamp_water = 50,
				sand = 50,
				cave = 50,
				impassable = 50,
				frozen = 50,
				fungus = 50,
				reef = 50
			})
			set_p(unit, "movement_costs", {
				unwalkable = 1,
				castle = 1,
				village = 1,
				shallow_water = 1,
				deep_water = 1,
				flat = 1,
				forest = 1,
				hills = 1,
				mountains = 1,
				swamp_water = 1,
				sand = 1,
				cave = 1,
				impassable = 99,
				frozen = 1,
				fungus = 1,
				reef = 1
			})
		end
	end

	set_p(unit, "variables.firststrike_flag", 0)
	--set_p(unit, "variables.unpoisonable_flag", 0)

	if get_n(unit, "variables.unpoisonable_flag") > 0 then
		set_p(unit, "status.unpoisonable", "yes")
	else
		clear_p(unit, "status.unpoisonable")
	end
	if get_n(unit, "variables.undrainable_flag") > 0 then
		set_p(unit, "status.undrainable", "yes")
	else
		clear_p(unit, "status.undrainable")
	end
	if get_n(unit, "variables.unplagueable_flag") > 0 then
		set_p(unit, "status.unplagueable", "yes")
	else
		clear_p(unit, "status.unplagueable")
	end

	local old_traits, new_traits = get_p(unit, "modifications.trait"), {}
	if player then
		table.insert(new_traits, parse_container({
			id = "mana_counter",
			name = string.format("mana: %d/%d", get_n(unit, "variables.abilities.magic_casting.mana"), get_n(unit, "variables.abilities.magic_casting.max_mana")),
			description = " Available mana / maximum stored mana."
		}))
	end
	if type(old_traits) == "table" then
		for i = 1, #old_traits do
			local trait_id = get_p(old_traits[i], "id")
			if trait_id ~= "mana_counter" and trait_id ~= "healthy" and trait_id ~= "fearless" then
				table.insert(new_traits, old_traits[i])
			end
		end
	end
	if get_n(unit, "variables.abilities.healthy") > 0 then
		table.insert(new_traits, parse_container({
			id = "healthy",
			name = "healthy",
			description = "Can rest while moving, halves poison damage.",
			{ "effect", {
				apply_to = "healthy"
			} },
		}))
	end
	if get_n(unit, "variables.abilities.fearless") > 0 then
		table.insert(new_traits, parse_container({
			id = "fearless",
			name = "fearless",
			description = "Fight normally during unfavorable times of day/night.",
			{ "effect", {
				apply_to = "fearless"
			} },
		}))
	end
	clear_p(unit, "modifications.trait")
	for i = 1, #new_traits do
		set_p(unit, string.format("modifications.trait[%d]", i - 1), new_traits[i], true)
	end

	clear_p(unit, "halo")
	local abilities = {}
	if get_n(unit, "variables.abilities.illuminates") == 1 and get_p(unit, "alignment") == "lawful" then
		set_p(unit, "halo", "halo/illuminates-aura.png")
		table.insert(abilities, { "illuminates", {
			id = "illumination",
			value = 25,
			max_value = 25,
			cumulative = "no",
			name = "illuminates",
			description = "Illuminates:\nThis unit illuminates the surrounding area, making lawful units fight better, and chaotic units fight worse.\n\nAny units adjacent to this unit will fight as if it were dusk when it is night, and as if it were day when it is dusk.",
			affect_self = "yes"
		} })
	elseif get_n(unit, "variables.abilities.darkens") == 1 and get_p(unit, "alignment") == "chaotic" then
		set_p(unit, "halo", "halo/darkens-aura.png")
		table.insert(abilities, { "illuminates", {
			id = "darkens",
			value = -25,
			min_value = -25,
			cumulative = "no",
			name = "darkens",
			description = "Darkens:\nThis unit darkens the surrounding area, making chaotic units fight better, and lawful units fight worse.\n\nAny units adjacent to this unit will fight as if it were dusk when it is day, and as if it were night when it is dusk.",
			affect_self = "yes"
		} })
	elseif not player then
		local halo_level = get_n(unit, "variables.abilities.witch_magic")
		if halo_level == 2 then
			set_p(unit, "halo", "halo/coldaura.png")
			table.insert(abilities, { "resistance", {
				id = "coldaura",
				add = 50,
				max_value = 50,
				apply_to = "fire",
				name = "cold aura",
				description = "Cold Aura:\nAdjacent units receive a 50% bonus to fire resistance and a -25% bonus to cold resistance. All cold spells are very powerful here.",
				affect_self = "yes",
				affect_allies = "yes",
				affect_enemies = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
			table.insert(abilities, { "resistance", {
				id = "coldaura_2",
				add = -25,
				max_value = -25,
				apply_to = "cold",
				affect_self = "yes",
				affect_allies = "yes",
				affect_enemies = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
		elseif halo_level == 3 then
			set_p(unit, "halo", "halo/dark-cleric-aura.png")
			table.insert(abilities, { "leadership", {
				id = "darkaura",
				value = -25,
				cumulative = "no",
				name = "dark aura",
				description = "Dark aura makes all enemy units fight worse (-25% for attack).",
				affect_self = "no",
				affect_allies = "no",
				affect_enemies = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
		elseif halo_level == 4 then
			set_p(unit, "halo", "halo/deadzone.png")
			table.insert(abilities, { "resistance", {
				id = "deadzone",
				add = 99,
				max_value = 99,
				apply_to = "fire,cold,arcane",
				name = "deadzone",
				description = "Deadzone:\nAdjacent friendly units receive a 99% bonus to fire,cold and arcane resistance",
				affect_self = "yes",
				affect_allies = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
			table.insert(abilities, { "regenerate", {
				id = "regenerates",
				value = 8,
				name = "regenerates",
				female_name = "female^regenerates",
				description = "Regenerates:\nThe unit will heal itself 8 HP per turn. If it is poisoned, it will remove the poison instead of healing.",
				affect_self = "yes",
				poison = "cured"
			} })
		end
	end

	if not player then
		if get_n(unit, "variables.abilities.water") == 1 then
			table.insert(abilities, { "regenerate", {
				id = "regenerates",
				value = 6,
				name = "water",
				description = "Made of Water:\nThis unit is made of water. As a result, if it is standing in water, it will receive 6 hp. If it is poisoned, it will remove it instead of healing.",
				name_inactive = "water",
				description_inactive = "Made of Water:\nThis unit is made of water. As a result, if it is standing in water, it will receive 6 hp. If it is poisoned, it will remove it instead of healing.",
				affect_self = "yes",
				poison = "cured",
				{ "filter_self", {
					{ "filter_location", {
						terrain = "W*,S*"
					} }
				} }
			} })
		elseif get_n(unit, "variables.abilities.rock") == 1 then
			table.insert(abilities, { "regenerate", {
				id = "regenerates",
				value = 6,
				name = "rock",
				description = "Made of Rock:\nThis unit is made of rock. If it stands in loose rock, it will recive 6 hp. If it is poisoned, it will remove it instead of healing.",
				name_inactive = "rock",
				description_inactive = "Made of Rock:\nThis unit is made of rock. If it stands in loose rock, it will recive 6 hp. If it is poisoned, it will remove it instead of healing.",
				affect_self = "yes",
				poison = "cured",
				{ "filter_self", {
					{ "filter_location", {
						terrain = "Uh,*^Dr,M*"
					} }
				} }
			} })
		elseif get_n(unit, "variables.abilities.fire") == 1 then
			table.insert(abilities, { "regenerate", {
				id = "regenerates",
				value = 6,
				name = "fire",
				description = "Made of Fire:\nThis unit is made of fire. If it stands in lava, it will recive 6 hp. If it is poisoned, it will remove it instead of healing.",
				name_inactive = "fire",
				description_inactive = "Made of Fire:\nThis unit is made of fire. If it stands in lava, it will recive 6 hp. If it is poisoned, it will remove it instead of healing.",
				affect_self = "yes",
				poison = "cured",
				{ "filter_self", {
					{ "filter_location", {
						terrain = "Ql*"
					} }
				} }
			} })
		end
		local divine_health = get_n(unit, "variables.abilities.divine_health")
		if divine_health == 1 then
			table.insert(abilities, { "regenerate", {
				id = "divine_health",
				value = 3,
				name = "divine health",
				description = "Divine Health: Due to this unit's relationship with its deity it is granted a magical body in which the magic is manifested as the ability to self heal. Thus this unit will be healed by 3 HP per turn, poison will not be prolonged or cured...",
				affect_self = "yes",
			} })
		elseif divine_health == 2 then
			table.insert(abilities, { "regenerate", {
				id = "divine_health_enahanced",
				value = 6,
				name = "divine health en",
				description = "Divine Health: Due to this unit's relationship with its deity it is granted a magical body in which the magic is manifested as the ability to self heal. Thus this unit will be healed by 3 HP per turn, poison will not be prolonged or cured...",
				affect_self = "yes",
			} })
		end
		if get_n(unit, "variables.abilities.feeding") == 1 then
			table.insert(abilities, { "dummy", {
				id = "wbd_feeding",
				name = "feeding",
				female_name= "female^feeding",
				description="Feeding:\nThis unit gains 1 hitpoint added to its maximum whenever it kills a living unit."
			} })
		end
		local spell_power = get_n(unit, "variables.abilities.magic_casting.power")
		if get_n(unit, "variables.abilities.human_magic") == 3 then
			spell_power = spell_power * 3 + 2
		elseif get_n(unit, "variables.abilities.nature_heal") == 1 then
			spell_power = spell_power * 2 + 4
		elseif get_n(unit, "variables.abilities.swamp_magic") > 0 then
			if get_n(unit, "variables.abilities.benevolent") > 0 then
				spell_power = spell_power * 3
			end
			spell_power = spell_power + 4
		elseif get_n(unit, "variables.abilities.witchcraft") > 0 then
			spell_power = spell_power * 2 + 2
		elseif get_n(unit, "variables.abilities.minotaur_magic") == 3 then
			spell_power = spell_power * 2 + 6
		else
			spell_power = 0
		end
		if spell_power > 0 then
			if spell_power > 7 then
				table.insert(abilities, { "heals", {
					id = "curing",
					name = "cures",
					description = "Cures:\nA curer can cure a unit of poison, although that unit will receive no additional healing on the turn it is cured of the poison.",
					poison = "cured",
					affect_allies = "yes",
					affect_self = "yes",
					{ "affect_adjacent", {
						adjacent = "n,ne,se,s,sw,nw"
					} }
				} })
			end
			table.insert(abilities, { "heals", {
				id = "healing",
				value = spell_power,
				name = string.format("heals +%d", spell_power),
				description = string.format("Heals +%d:\nAllows the unit to heal adjacent allied units at the beginning of our turn.\n\nA unit cared for by this healer may heal up to %d HP per turn, or stop poison from taking effect for that turn.", spell_power, spell_power),
				poison = "slowed",
				affect_allies = "yes",
				affect_self = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
		end
	end
	local skill_level = get_n(unit, "variables.abilities.steadfast")
	if skill_level > 0 and get_n(equipment.shield, "special_type.steadfast") == 1 then
		local new_ability = {
			id = "steadfast",
			multiply = 2,
			apply_to = "blade,pierce,impact,fire,cold,arcane",
			name = "steadfast",
			affect_self = "yes",
			active_on = "defense",
			{ "filter_base_value", {
				greater_than = 0,
			} }
		}
		if player then
			new_ability.max_value = 30 + 10 * skill_level
			new_ability[1][2].less_than_equal_to = new_ability.max_value
			new_ability.description = string.format("Steadfast Level %d:\nThis unit's resistances are doubled, up to a maximum of %d%%, when defending. Vulnerabilities are not affected.", skill_level, new_ability.max_value)
		else
			new_ability.max_value = 50
			new_ability[1][2].less_than_equal_to = 50
			new_ability.description = "Steadfast:\nThis unit's resistances are doubled, up to a maximum of 50%, when defending. Vulnerabilities are not affected."
		end
		table.insert(abilities, { "resistance", new_ability })
	end
	skill_level = get_n(unit, "variables.abilities.leadership")
	if skill_level > 0 and get_n(unit, "variables.abilities.cruelty") == 1 then
		local chaotic = { "filter_wml", {
			alignment = "chaotic"
		} }
		local non_chaotic = { "not", {
			{ "filter_wml", {
				alignment = "chaotic"
			} }
		} }
		table.insert(abilities, { "leadership", {
			id = "leadership",
			name = "cruelty",
			affect_self = "no",
			affect_allies = "yes",
			cumulative = "no",
			description = string.format("Leadership Level %d:\nThis unit can lead friendly units that are next to it, making them fight better.\n\nAdjacent friendly units of lower level will do more damage in battle. When a unit adjacent to, of a lower level than, and on the same side as a unit with Leadership engages in combat, its attacks do 30%% more damage times the difference in their levels if chaotic, 20%% if non-chaotic.", skill_level),
			value = 30 * skill_level,
			{ "affect_adjacent", {
				adjacent = "n,ne,se,s,sw,nw",
				{ "filter", {
					level = 0,
					chaotic
				} }
			} }
		} })
		local new_ability = {
			id = "leadership",
			affect_self = "no",
			affect_allies = "yes",
			cumulative = "no",
			value = 20 * skill_level,
			{ "affect_adjacent", {
				adjacent = "n,ne,se,s,sw,nw",
				{ "filter", {
					level = 0,
					non_chaotic
				} }
			} }
		}
		table.insert(abilities, { "leadership", new_ability })
		for i = 1, skill_level - 1 do
			new_ability.value = 30 * (skill_level - i)
			new_ability[1][2][1][2] = {
				level = i,
				chaotic
			}
			table.insert(abilities, { "leadership", new_ability })
			new_ability.value = 20 * (skill_level - i)
			new_ability[1][2][1][2] = {
				level = i,
				non_chaotic
			}
			table.insert(abilities, { "leadership", new_ability })
		end
	elseif skill_level > 0 then
		table.insert(abilities, { "leadership", {
			id = "leadership",
			name = "leadership",
			affect_self = "no",
			affect_allies = "yes",
			cumulative = "no",
			description = string.format("Leadership Level %d:\nThis unit can lead friendly units that are next to it, making them fight better.\n\nAdjacent friendly units of lower level will do more damage in battle. When a unit adjacent to, of a lower level than, and on the same side as a unit with Leadership engages in combat, its attacks do 25%% more damage times the difference in their levels.", skill_level),
			value = 25 * skill_level,
			{ "affect_adjacent", {
				adjacent = "n,ne,se,s,sw,nw",
				{ "filter", {
					level = 0
				} }
			} }
		} })
		if skill_level > 1 then
			local new_ability = {
				id = "leadership",
				affect_self = "no",
				affect_allies = "yes",
				cumulative = "no",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw",
					{ "filter", {} }
				} }
			}
			for i = 1, skill_level - 1 do
				new_ability.value = 25 * (skill_level - i)
				new_ability[1][2][1][2].level = i
				table.insert(abilities, { "leadership", new_ability })
			end
		end
	end
	if not player then
		if get_n(unit, "variables.abilities.battle_tutor") == 1 then
			table.insert(abilities, { "dummy", {
				id = "battletutor",
				name = "battle tutor",
				description = "Battle Tutor:\nThis unit's ability to teach battle skills gives each adjacent allied unit a +1 to experience earned in battle."
			} })
		end
		if get_n(unit, "variables.npc_init.abilities.skeletal") == 1 then
			table.insert(abilities, { "hides", {
				id = "submerge",
				name = "submerge",
				female_name = "female^submerge",
				description = "Submerge:\nThis unit can hide in deep water, and remain undetected by its enemies.\n\nEnemy units cannot see this unit while it is in deep water, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
				name_inactive = "submerge",
				female_name_inactive = "female^submerge",
				description_inactive = "Submerge:\nThis unit can hide in deep water, and remain undetected by its enemies.\n\nEnemy units cannot see this unit while it is in deep water, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
				affect_self = "yes",
				{ "filter_self", {
					{ "filter_location", {
						terrain = "Wo*^*"
					} }
				} }
			} })
		end
	end
	if get_n(unit, "variables.abilities.loner") == 1 then
		table.insert(abilities, { "leadership", {
			id = "loner",
			name = "loner",
			affect_self = "yes",
			cumulative = "no",
			description = "Loner\nThis unit is 25% more effective in combat when not adjacent to any allied units.",
			value = 25,
			{ "filter", {
				{ "not", {
					{ "filter_adjacent", {
						is_enemy = "false"
					} }
				} }
			} }
		} })
	end
	local skirmisher_flag = false
	if (evade > 1 or get_p(unit, "race") == "undead") and get_n(unit, "variables.abilities.skirmisher") > 0 then
		skirmisher_flag = true
		table.insert(abilities, { "skirmisher", {
			id = "skirmisher",
			name = "skirmisher",
			affect_self = "yes",
			description = "Skirmisher: This unit is skilled in moving past enemies quickly, and ignores all enemy Zones of Control."
		} })
		if get_n(unit, "variables.abilities.distract") > 0 then
			table.insert(abilities, { "skirmisher", {
				id = "distract",
				name = "distract",
				affect_self = "no",
				affect_allies = "yes",
				description = "Distract:\nThis unit negates enemy Zones of Control around itself for allied units (but not for itself).",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
		end
	end
	local dash_flag = evade > 5 and get_n(unit, "variables.abilities.dash") > 0
	if dash_flag then
		table.insert(abilities, { "dummy", {
			id = "dash",
			name = "dash",
			description = "This unit can use remaining movement points after attacking."
		} })
		set_p(unit, "variables.status.dash", 1)
	else
		set_p(unit, "variables.status.dash", 0)
	end
	if (evade > 0 or get_p(unit, "race") == "undead") then
		if evade > 3 then
			if get_n(unit, "variables.abilities.ambush_forest") > 0 then
				table.insert(abilities, { "hides", {
					id = "ambush_forest",
					name = "ambush",
					name_inactive = "ambush",
					affect_self = "yes",
					description = "Ambush:\nThis unit can hide in forest if wearing only light armor.",
					description_inactive = "Ambush:\nThis unit can hide in forest if wearing only light armor.",
					{ "filter_self", {
						{ "filter_location", {
							terrain = "*^F*"
						} }
					} }
				} })
			end
			if get_n(unit, "variables.abilities.ambush_mountains") > 0 then
				table.insert(abilities, { "hides", {
					id = "ambush_mountains",
					name = "ambush",
					name_inactive = "ambush",
					affect_self = "yes",
					description = "Ambush:\nThis unit can hide in mountains if wearing only light armor.",
					description_inactive = "Ambush:\nThis unit can hide in mountains if wearing only light armor.",
					{ "filter_self", {
						{ "filter_location", {
							terrain = "M*,M*^*"
						} }
					} }
				} })
			end
			if evade > 7 and get_n(unit, "variables.abilities.sneak") > 0 then
				table.insert(abilities, { "hides", {
					id = "sneak",
					name = "sneak",
					name_inactive = "sneak",
					affect_self = "yes",
					description = "Sneak: This unit can hide from enemies if it has used no more than half of its movement points and light armor.",
					description_inactive = "Sneak: This unit can hide from enemies if it has used no more than half of its movement points and light armor.",
					{ "filter", {
						{ "filter_wml", {
							{ "variables", { stealthiness = 1 } }
						} }
					} }
				} })
				set_p(unit, "variables.stealthiness", math.min(1, 2 * get_n(unit, "moves") - get_n(unit, "max_moves") + 1))
				set_p(unit, "status.hidden", "yes")
			end
		end
		if ((not player) or get_p(unit, "race") == "undead") and get_n(unit, "variables.abilities.nightstalk") > 0 then
			table.insert(abilities, { "hides", {
				id = "nightstalk",
				name = "nightstalk",
				female_name = "nightstalk",
				name_inactive = "nightstalk",
				female_name_inactive = "nightstalk",
				affect_self = "yes",
				description = "Nightstalk:\nThe unit becomes invisible during night.\n\nEnemy units cannot see this unit at night, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
				description_inactive = "Nightstalk:\nThe unit becomes invisible during night.\n\nEnemy units cannot see this unit at night, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
				{ "filter_self", {
					{ "filter_location", {
						time_of_day = "chaotic"
					} }
				} }
			} })
		end
		if get_n(unit, "variables.abilities.concealment") > 0 then
			table.insert(abilities, { "hides", {
				id = "concealment",
				name = "concealment",
				female_name = "concealment",
				name_inactive = "concealment",
				female_name_inactive = "concealment",
				affect_self = "yes",
				description = "Concealment:\nThis unit can hide in villages (with the exception of water villages), and remain undetected by its enemies, except by those standing next to it.\n\nEnemy units cannot see this unit while it is in a village, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
				description_inactive = "Concealment:\nThis unit can hide in villages (with the exception of water villages), and remain undetected by its enemies, except by those standing next to it.\n\nEnemy units cannot see this unit while it is in a village, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
				{ "filter_self", {
					{ "filter_location", {
						terrain = "*^V*"
					} }
				} }
			} })
		end
	end
	if get_p(unit, "race") == "undead" and get_n(unit, "variables.abilities.wallpass") > 0 then
		table.insert(abilities, { "dummy", {
			id = "wallpass",
			name = "wall pass",
			description = "Wall Pass:\nThis unit can pass through solid objects with a cost of 2 movement points."
		} })
		set_p(unit, "movement_costs.impassable", 2)
	end
	skill_level = 2 * get_n(unit, "variables.abilities.regenerate")
	if skill_level > 0 then
		local new_ability = {
			id = "regenerates",
			name = string.format("regenerate +%d", skill_level),
			value = skill_level
		}
		if skill_level > 7 then
			new_ability.description = string.format("Regenerates:\nThe unit will heal itself %d HP per turn. If it is poisoned, it will remove the poison instead of healing.", skill_level)
			new_ability.poison = "cured"
		else
			new_ability.description = string.format("Regenerates:\nThe unit will heal itself %d HP per turn. If it is poisoned, it will slow the poison until cured.", skill_level)
			new_ability.poison = "slowed"
		end
		table.insert(abilities, { "regenerate", new_ability })
	end
	if get_n(unit, "variables.abilities.survivalist") > 0 then
		table.insert(abilities, { "regenerate", {
			id = "survivalist",
			name = "survivalist",
			value = 8,
			description = "Survivalist:\nThe unit will heal itself 8 HP per turn if in a forest. If it is poisoned, it will remove the poison instead of healing.",
			poison = "cured",
			{ "filter_self", {
				{ "filter_location", {
					terrain = "*^Fp,*^Fet,*^Ft,*^Fpa"
				} }
			} }
		} })
	end

	if player then
		local spell_list, spell_power = get_p(unit, "variables.inventory.spells"), get_n(unit, "variables.abilities.magic_casting.power")
		if type(spell_list) == "table" then
			for i = 1, #spell_list do
				local spell_name = get_p(spell_list[i], "user_name")
				if spell_name == "heals" then
					local heal_type, heal_power = get_p(spell_list[i], "command"), 0
					if heal_type == "green_healing" then
						heal_power = 2 * spell_power + 4
					elseif heal_type == "spirit_healing" and get_n(unit, "variables.abilities.benevolent") <= 0 then
						heal_power = spell_power + 4
					else
						heal_power = 3 * spell_power + 4
					end
					set_p(unit, string.format("variables.inventory.spells[%d].mana_cost", i - 1), math.floor(heal_power / 4) + 1)
					table.insert(abilities, { "heals", {
						id = "rpg_heals",
						name = "heals",
						description = string.format("Heals +%d:\n<small>This can heal %d hit points.</small>", heal_power, heal_power)
					} })
					if heal_power > 7 then
						table.insert(abilities, { "heals", {
							id = "rpg_cures",
							name = "cures",
							description = string.format("Heals +%d:\n<small>This can heal %d hit points.</small>", heal_power, heal_power)
						} })
						set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Heals +%d:\n<small>Heal %d hitpoints. Cure if the unit is poisoned.</small>", heal_power, heal_power))
					else
						set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Heal %d hitpoints.", heal_power))
					end
				elseif spell_name == "silver_teleport" then
					table.insert(abilities, { "teleport", {
						id = "rpg_teleport",
						name = "teleport",
						description = string.format("Teleport:\nThis unit may teleport %d hexes away granted it is an empty location that the unit can move to normally.", 2 * spell_power)
					} })
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Teleport:\n<small>Teleport %d hexes away.</small>", 2 * spell_power))
				elseif spell_name == "phoenix_fire" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Phoenix Fire:\n<small>Upon death, return to %d hitpoints. Amount decreases by 4 per turn.</small>", 4 * spell_power + 4))
					set_p(unit, string.format("variables.inventory.spells[%d].mana_cost", i - 1), "mana_cost", 2 * spell_power + 2)
				elseif spell_name == "mapping" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Magic Mapping:\n<small>Removes shroud within a radius of %d hexes.</small>", 5 * spell_power + 10))
				elseif spell_name == "detect_gold" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Detect Gold:\n<small>Shows gold within a radius of %d hexes.</small>", 4 * spell_power + 20))
				elseif spell_name == "detect_units" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Detect Units:\n<small>Shows units within a radius of %d hexes.</small>", 5 * spell_power + 15))
				elseif spell_name == "improved_detect_units" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Improved Detect Units:\n<small>Shows units within a radius of %d hexes.</small>", 4 * spell_power + 12))
				elseif spell_name == "summon_fire_elemental" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Summon Fire Elemental:\n<small>Summon a fire elemental with a max level of %d.</small>", math.min(3, spell_power)))
				elseif spell_name == "summon_water_elemental" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Summon Water Elemental:\n<small>Summon a water elemental with a max level of %d.</small>", math.min(3, spell_power)))
				elseif spell_name == "summon_earth_elemental" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Summon Earth Elemental:\n<small>Summon an earth elemental with a max level of %d.</small>", math.min(3, spell_power)))
				elseif spell_name == "summon_air_elemental" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Summon Air Elemental:\n<small>Summon an air elemental with a max level of %d.</small>", math.min(3, spell_power)))
				elseif spell_name == "protection_from_poison" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Protection from Poison:\n<small>Protects from poison for %d rounds.</small>", spell_power))
				elseif spell_name == "protection_from_slow" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Protection from Slow:\n<small>Protects from slowing for %d rounds.</small>", spell_power))
				elseif spell_name == "protection_armor_magic" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Magic Armor:\n<small>Grants %d%% resistance. Amount decreases by 5%% each round.</small>", 5 * spell_power))
				elseif spell_name == "protection_from_fire" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Protection from Fire:\n<small>Grants %d%% resistance to fire. Amount decreases by 10%% each round.</small>", 10 * spell_power))
				elseif spell_name == "metal_to_drain" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Metal to Drain:\n<small>Adds drain to first melee weapon, if metal, for %d rounds.</small>", spell_power))
				end
			end
		end
	end

	local spell_status = 5 * get_n(unit, "variables.status.protection_armor_magic")
	if spell_status > 0 then
		table.insert(abilities, { "resistance", {
			id = "protection_armor_magic",
			add = spell_status,
			max_value = 200
		} })
		table.insert(abilities, { "dummy", {
			id = "protection_armor_magic",
			name = "+",
			description = string.format("This unit is protected from damage by an extra %d%%. This value degrades by 5%% every round.", spell_status)
		} })
	end
	spell_status = 10 * get_n(unit, "variables.status.protection_from_fire")
	if spell_status > 0 then
		table.insert(abilities, { "resistance", {
			id = "protection_from_fire",
			add = spell_status,
			max_value = 200,
			apply_to = "fire"
		} })
		table.insert(abilities, { "dummy", {
			id = "protection_from_fire",
			name = "+",
			description = string.format("This unit is protected from fire damage by an extra %d%%. This value degrades by 10%% every round.", spell_status)
		} })
	end
	spell_status = get_n(unit, "variables.status.protection_from_poison")
	if spell_status > 0 then
		clear_p(unit, "status.poisoned")
		set_p(unit, "variables.unpoisonable_flag", 1)
		table.insert(abilities, { "dummy", {
			id = "protection_from_poison",
			name = "+",
			description = string.format("This unit is protected from poison for the next %d rounds.", spell_status)
		} })
	end
	spell_status = get_n(unit, "variables.status.protection_from_slow")
	if spell_status > 0 then
		clear_p(unit, "status.slowed")
		set_p(unit, "variables.unslowable_flag", 1)
		table.insert(abilities, { "dummy", {
			id = "protection_from_slow",
			name = "+",
			description = string.format("This unit is protected from slowing for the next %d rounds.", spell_status)
		} })
	end
	spell_status = get_n(unit, "variables.phoenix_fire")
	if spell_status > 0 then
		table.insert(abilities, { "dummy", {
			id = "phoenix_fire",
			name = "+",
			description = string.format("This unit is protected from death, and will return with %d health. This value degrades by 4 every round.", spell_status)
		} })
	end

	local is_wesband = get_n(unit, "variables.npc_init.wesband", 1)
	if is_wesband == 0 then
		--clear_p(unit, "abilities")
		--abilities = {}
		local base_abilities = get_p(unit, "variables.base_abilities")
		if base_abilities then
			for i = 1, #base_abilities do
				local ba = unparse_container(base_abilities[i])
				for _,f in pairs(ba) do
					table.insert(abilities, f)
				end
			end
		end
	end

	set_p(unit, "abilities", abilities)

	clear_p(unit, "attack")
	local attacks, variation, variation_strength = {}, "fist", 1
	local unblocked_counter, unblocked_class = 1 - get_n(unit, "variables.blocked_attacks"), get_p(unit, "variables.weapon_block_class")
	local blocked_flag = unblocked_counter == 0
	local function add_attack(weapon)
		local attack, weapon_class = get_attack_basics(unit, equipment, weapon)
		if attack.number > 0 then
			if player or get_p(unit, "type") == "Skeleton_MODRPG" then
				local attack_strength = attack.damage * attack.number
				if weapon_class ~= "spell" and (variation_strength < attack_strength) then
					variation = attack.name
					variation_strength = attack_strength
				end
			end
			if dash_flag then
				attack.movement_used = 0
			end
			local specials, new_special, special_level = {}, {}, 0
			local storm_allowed = true
			if #attacks == 0 and attack.range == "melee" then -- specials that only affect first melee weapon get handled here
				if get_n(unit, "variables.abilities.berserk") == 1 then
					table.insert(specials, { "berserk", {
						id = "berserk",
						name = "berserk",
						description = "Berserk:\nOn offense, combat length with this weapon triples. On defense, combat length with this weapon doubles.",
						value = 3,
						active_on = "offense"
					} })
					table.insert(specials, { "berserk", {
						id = "berserk",
						name = "berserk",
						value = 2,
						active_on = "defense"
					} })
					storm_allowed = false
				elseif get_n(unit, "variables.abilities.rage") == 1 then
					table.insert(specials, { "berserk", {
						id = "rage",
						name = "rage",
						description = "Rage:\nOn offense, combat length with this weapon doubles.",
						value = 2,
						active_on = "offense"
					} })
					storm_allowed = false
				end
				if attack.material == "metal" and get_n(unit, "variables.status.metal_to_drain") > 0 and get_n(weapon, "special_type.spell_drains") ~= 1 then
					set_p(weapon, "special_type.spell_drains", 2)
				end
			end
			special_level = get_n(unit, "variables.abilities.slashdash")
			if special_level > 0 then
				attack.slashdash = 1
				new_special = {
					slashdash = 1,
					id = "slashdash",
					name = "slash+dash",
				}
				if not player then
					new_special.description = "Slash+Dash:\nWhen used offensively, every two hits with this weapon grants 1 movement point."
				elseif special_level == 1 then
					new_special.description = "Slash+Dash Level 1:\nWhen used offensively, every two hits with this weapon grants 1 movement point."
				elseif special_level == 2 then
					new_special.description = "Slash+Dash Level 2:\nWhen used offensively, every hit with this weapon grants 1 movement point."
				else
					new_special.description = "Slash+Dash Level 3:\nWhen used offensively, every hit with this weapon grants 2 movement points."
				end
				table.insert(specials, { "dummy", new_special })
			end
			local marksman_offset
			if weapon_class == "thrown_light_blade" then
				special_level = get_n(unit, "variables.abilities.marksman_thrown_light_blade")
				marksman_offset = 45
			elseif get_n(weapon, "special_type.marksman") > 0 then
				special_level = get_n(unit, "variables.abilities.marksman")
				marksman_offset = 50
			elseif (not player) and attack.user_name == "chakram" then
				special_level = get_n(unit, "variables.abilities.marksman_chakram")
			else
				special_level = 0
			end
			if special_level > 0 then
				new_special = {
					id = "marksman",
					name = "marksman",
					cumulative = "yes",
					active_on = "offense"
				}
				if player then
					new_special.value = marksman_offset + 5 * special_level
					new_special.description = string.format("Marksman Level %d:\nWhen used offensively, this attack always has at least a %d%% chance to hit.", special_level, new_special.value)
				else
					new_special.value = 60
					new_special.description = "Marksman:\nWhen used offensively, this attack always has at least a 60% chance to hit."
				end
				table.insert(specials, { "chance_to_hit", new_special })
			end
			if not player then
				if weapon_class == "light_blade" and get_n(unit, "variables.abilities.accuracy_light_blade") > 0 then
					table.insert(specials, { "chance_to_hit", {
						id = "accuracy",
						name = "accuracy",
						cumulative = "yes",
						active_on = "offense",
						value = 50,
						description = "Accuracy:\nWhen used offensively, this attack always has at least a 50% chance to hit."
					} })
				end
				if weapon_class == "polearm" and get_n(unit, "variables.abilities.evasion_polearm") > 0 then
					table.insert(specials, { "damage", {
						id = "evasion",
						name = "evasion",
						name_inactive = "evasion",
						active_on = "offense",
						apply_to = "opponent",
						multiply = 0.66,
						description = "Evasion:\nWhen this attack is used offensively, this unit takes one third less damage in retaliation.",
						description_inactive = "Evasion:\nWhen this attack is used offensively, this unit takes one third less damage in retaliation."
					} })
				end
			end
			special_level = get_n(unit, "variables.abilities.goliath_bane")
			if special_level > 0 and get_n(weapon, "special_type.goliath_bane") > 0 then
				new_special = {
					id = "goliath_bane",
					active_on = "offense",
					{ "filter_opponent", {} }
				}
				if player then
					table.insert(specials, { "damage", {
						id = "goliath_bane",
						name = "goliath bane",
						description = string.format("Goliath Bane Level %d:\n%d%% damage bonus for each level of the enemy. Offense only.", special_level, 10 * special_level),
						multiply = 1 + 0.1 * special_level,
						active_on = "offense",
						{ "filter_opponent", {
							level = 1
						} }
					} })
					for i = 2, 9 do
						new_special.multiply = 1 + 0.1 * i * special_level
						new_special[1][2].level = i
						table.insert(specials, { "damage", new_special })
					end
				else
					table.insert(specials, { "damage", {
						id = "goliath_bane",
						name = "goliath bane",
						description = "Goliath Bane:\n20% damage bonus for each level of the enemy. Offense only.",
						multiply = 1.2,
						active_on = "offense",
						{ "filter_opponent", {
							level = 1
						} }
					} })
					for i = 2, 9 do
						new_special.multiply = 1 + 0.2 * i
						new_special[1][2].level = i
						table.insert(specials, { "damage", new_special })
					end
				end
			end
			if get_n(weapon, "special_type.ensnare") > 0 then
				special_level = get_n(unit, "variables.abilities.ensnare")
			elseif get_n(weapon, "special_type.vine_ensnare") > 0 then
				special_level = get_n(unit, "variables.abilities.vine_ensnare")
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.ensnare = 1
				new_special = {
					ensnare = 1,
					id = "ensnare",
					name = "ensnare",
					add = 0,
					cumulative = "yes",
					active_on = "offense",
				}
				if player then
					new_special.description = string.format("Ensnare:\nEach successful strike with this spell increases the chance to hit by %d%%. Active on offense.", 5 * special_level)
				else
					new_special.description = "Ensnare:\nEach successful strike with this spell increases the chance to hit by 10%. Active on offense."
				end
				table.insert(specials, { "chance_to_hit", new_special })
			end
			if get_n(weapon, "special_type.pointpike") > 0 then
				special_level = get_n(unit, "variables.abilities.pointpike")
			else
				special_level = 0
			end
			if special_level > 0 then
				table.insert(specials, { "chance_to_hit", {
					pointpike = 1,
					id = "pointpike",
					name = "point+pike",
					description = string.format("Point+Pike Level %d:\nEach miss with this weapon increases the chance to hit by %d%%, which is reset upon a successful hit. Active on offense.", special_level, 10 * special_level),
					add = 0,
					cumulative = "yes",
					active_on = "offense",
				} })
				new_special = {
					cumulative = "yes",
					active_on = "offense",
					{ "filter_self", {
						{ "filter_wml", {
							{ "variables", {
							} }
						} }
					} }
				}
				for i = 10 * special_level, 90, 10 * special_level do
					new_special.id = string.format("pointpike%d", i)
					new_special.add = i
					new_special[1][2][1][2][1][2].pointpike = i
					table.insert(specials, { "chance_to_hit", new_special })
				end
				new_special.id = "pointpike100"
				new_special.add = 100
				new_special[1][2][1][2][1][2].pointpike = 100
				table.insert(specials, { "chance_to_hit", new_special })
			end
			if storm_allowed and get_n(weapon, "special_type.storm") > 0 then
				special_level = get_n(unit, "variables.abilities.storm")
			else
				special_level = 0
			end
			if special_level > 0 then
				local storm_limit = attack.number
				if get_n(unit, "variables.abilities.brutal") > 0 then
					storm_limit = math.ceil(storm_limit * 0.5)
					table.insert(specials, { "damage", {
						id = "brutal_damage",
						name = "brutal assault",
						description = "Brutal Assault:\nWhen attacking, deal 60% more damage per strike, but get half as many strikes.",
						name_inactive = "brutal assault",
						description_inactive = "Brutal Assault:\nWhen attacking, deal 60% more damage per strike, but get half as many strikes.",
						value = math.floor(attack.damage * 1.6 + 0.5),
						cumulative = "no",
						active_on = "offense",
						apply_to = "self"
					} })
					table.insert(specials, { "attacks", {
						id = "brutal_number",
						value = storm_limit,
						cumulative = "no",
						active_on = "offense",
						apply_to = "self"
					} })
				end
				storm_limit = storm_limit + 2 - special_level
				new_special = {
					id = "storm",
					name = "storm",
					name_inactive = "storm",
					value = storm_limit,
					cumulative = "no",
					active_on = "offense",
					apply_to = "defender",
					{ "filter_base_value", {
						greater_than = storm_limit
					} }
				}
				if special_level == 1 then
					new_special.description = "Storm Level 1:\nEnemy strikes will stop 2 strikes after this weapon's last strike."
				elseif special_level == 2 then
					new_special.description = "Storm Level 2:\nEnemy strikes will stop 1 strike after this weapon's last strike."
				else
					new_special.description = "Storm Level 3:\nEnemy strikes will stop after this weapon's last strike."
				end
				new_special.description_inactive = new_special.description
				table.insert(specials, { "attacks", new_special })
				table.insert(specials, { "attacks", {
					id = "storm",
					value = storm_limit + 1,
					cumulative = "no",
					active_on = "offense",
					apply_to = "defender",
					{ "filter_defender", {
						{ "filter_weapon", {
							name = "spear"
						} },
						{ "filter_wml", {
							{ "variables", {
								firststrike_flag = 1
							} }
						} }
					} },
					{ "filter_base_value", {
						greater_than = storm_limit
					} }
				} })
			end
			if (get_n(weapon, "special_type.vine_slows") > 0 and get_n(unit, "variables.abilities.vine_slows") > 0) or
			   ((not player) and attack.user_name == "kusarigama" and attack.range == "ranged" and get_n(unit, "variables.abilities.kusarigama_slows") > 0) or get_n(weapon, "enchantments.slows") > 0 then
				table.insert(specials, { "slow", {
					id = "slow",
					name = "slows",
					description = "Slow:\nThis attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					name_inactive = "slows",
					description_inactive = "Slow:\nThis attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					{ "filter_opponent", {
						{ "not", {
							{ "filter_wml", {
								{ "variables", {
									unslowable_flag = 1
								} }
							} }
						} }
					} }
				} })
			end
			if get_n(weapon, "special_type.drains") > 0 and get_n(unit, "variables.abilities.drains") then
				table.insert(specials, { "drains", {
					id = "drains",
					name = "drains",
					description = "Drains:\nThis unit drains health from living units, healing itself for half the amount of damage it deals (rounded down).",
					name_inactive = "drains",
					description_inactive = "Drains:\nThis unit drains health from living units, healing itself for half the amount of damage it deals (rounded down).",
					{ "filter_opponent", {
						{ "not", {
							{ "filter_wml", {
								{ "variables", {
									undrainable_flag = 1
								} }
							} }
						} }
					} }
				} })
			end
			if get_n(weapon, "special_type.poison") > 0 or get_n(weapon, "special_type.natural_poison") > 0 or (weapon_class == "thrown_light_blade" and get_n(weapon, "special_type.allow_poison") > 0 and (get_n(unit, "variables.abilities.poison_thrown_light_blade") > 0 or get_n(unit, "variables.abilities.poison_thrown_light_blade_orc") > 0)) or (weapon_class == "light_blade" and get_n(unit, "variables.abilities.poison_light_blade") == 1) or ((not player) and ((attack.user_name == "kusarigama" and attack.range == "melee" and get_n(unit, "variables.abilities.kusarigama_poison") > 0) or (weapon_class == "light_blade" and get_n(unit, "variables.abilities.witchcraft") == 1 and get_n(unit, "variables.abilities.magic_casting.power") > 0))) then
				table.insert(specials, { "poison", {
					id = "poison",
					name = "poison",
					name_inactive = "poison",
					description = "Poison:\nThis attack poisons living targets. Poisoned units lose 8 HP every turn until they are cured or are reduced to 1 HP. Poison can not, of itself, kill a unit.",
					description_inactive = "Poison:\nThis attack poisons living targets. Poisoned units lose 8 HP every turn until they are cured or are reduced to 1 HP. Poison can not, of itself, kill a unit.",
					icon = "dagger-thrown-poison-human",
					{ "filter_opponent", {
						{ "not", {
							{ "filter_wml", {
								{ "variables", {
									unpoisonable_flag = 1
								} }
							} }
						} }
					} }
				} })
			end
			if get_n(unit, "variables.abilities.witch_magic") == 4 then
				special_level = 1
			else
				special_level = get_n(weapon, "special_type.spell_drains")
			end
			if special_level > 0 then
				new_special = {
					name = "drains",
					description = "Drain:\nThis unit drains health from living units, healing itself for half the amount of damage it deals (rounded down)."
				}
				if special_level == 2 then
					new_special.id = "metal_to_drain"
				else
					new_special.id = "drains"
				end
				table.insert(specials, { "drains", new_special })
			end
			if (not player) and attack.range == "melee" and attack.class == "bludgeon" and get_n(unit, "variables.abilities.dread") > 0 then
				table.insert(specials, { "damage", {
					id = "dread",
					name = "dread",
					name_inactive = "dread",
					description = "Dread:\nWhen this attack is used offensively, this unit takes one third less damage in retaliation.",
					description_inactive = "Dread:\nWhen this attack is used offensively, this unit takes one third less damage in retaliation.",
					active_on = "offense",
					apply_to = "opponent",
					multiply = 0.66
				} })
			end
			if get_n(unit, "variables.abilities.readied_bolt") > 0 and get_n(weapon, "special_type.readied_bolt") > 0 then
				table.insert(specials, { "firststrike", {
					id = "firststrike",
					name = "readied bolt",
					description = "Readied Bolt:\nThis attack always strikes first, even when defending."
				} })
			end
			if (not skirmisher_flag) and get_n(weapon, "special_type.firststrike") > 0 and get_n(unit, "variables.abilities.firststrike") > 0 then
				table.insert(specials, { "firststrike", {
					id = "firststrike",
					name = "firststrike",
					description = "First Strike:\nThis unit always strikes first with this attack, even if they are defending."
				} })
				set_p(unit, "variables.firststrike_flag", 1)
			end
			if get_n(weapon, "special_type.backstab") > 0 then
				special_level = get_n(unit, "variables.abilities.backstab")
			else
				special_level = 0
			end
			if special_level > 0 then
				new_special = {
					id = "backstab",
					name = "backstab",
					--backstab = "yes",
					active_on = "offense",
					{ "filter_opponent", {
						formula = "enemy_of(self, flanker) and not flanker.petrified where flanker = unit_at(direction_from(loc, other.facing))"
					} }
				}
				if player then
					new_special.description = string.format("Backstab Level %d:\nThis attack deals %d%% damage if there is an enemy of the target on the opposite side of the target, and that unit is not incapacitated (e.g. turned to stone). Active on offense.", special_level, 150 + special_level * 50)
					new_special.multiply = 1.5 + special_level * 0.5
				else
					new_special.description = "Backstab:\nThis attack deals double damage if there is an enemy of the target on the opposite side of the target, and that unit is not incapacitated (e.g. turned to stone). Active on offense."
					new_special.multiply = 2
				end
				table.insert(specials, { "damage", new_special })
			end
			if get_n(weapon, "special_type.backstab") > 0 then
				special_level = get_n(unit, "variables.abilities.target")
			else
				special_level = 0
			end
			if special_level > 0 then
				new_special = {
					id = "target",
					name = "target"
				}
				if player then
					new_special.description = string.format("Target Level %d:\nThis attack deals %d%% damage but strikes are reduced by half. Always active.", special_level, 150 + special_level * 50)
				else
					new_special.description = "Target:\nThis attack deals double damage but strikes are reduced by half. Always active."
				end
				table.insert(specials, { "dummy", new_special })
			end
			if get_n(weapon, "special_type.cleave") > 0 then
				special_level = get_n(unit, "variables.abilities.cleave")
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.cleave = 1
				new_special = {
					cleave = 1,
					id = "cleave",
					name = "cleave",
				}
				if player then
					new_special.description = string.format("Cleave Level %d:\nEnemy units adjacent to both units in attack with this weapon can take 1/%dth of this weapon's damage. Terrain defense and resistances apply, chance to hit reduced to %d/%d normal. Active on offense.", special_level, 10 - 2 * special_level, special_level, special_level + 1)
				else
					new_special.description = "Cleave:\nEnemy units adjacent to both units in attack with this weapon can take 1/8th of this weapon's damage. Terrain defense and resistances apply, chance to hit reduced to 1/2 normal. Active on offense."
				end
				table.insert(specials, { "dummy", new_special })
			end
			if get_n(weapon, "special_type.riposte") > 0 then
				special_level = get_n(unit, "variables.abilities.riposte")
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.riposte = 1
				new_special = {
					riposte = 1,
					id = "riposte",
					name = "riposte",
					name_inactive = "riposte",
					cumulative = "yes",
					active_on = "defense",
					{ "filter_self", {
						{ "filter_wml", {
							{ "variables", {
								right_of_way = 1
							} }
						} }
					} }
				}
				if player then
					new_special.value = 40 + 20 * special_level
					if special_level == 3 then
						new_special.description = "Riposte Level 3:\nIf an enemy misses versus this attack, the returning attack will automatically hit. Active on defense."
					else
						new_special.description = string.format("Riposte Level %d:\nIf an enemy misses versus this attack, the returning attack will have at least a %d%% chance to hit. Active on defense.", special_level, new_special.value)
					end
				else
					new_special.value = 80
					new_special.description = "Riposte:\nIf an enemy misses versus this attack, the returning attack will have at least a 80% chance to hit. Active on defense."
				end
				new_special.description_inactive = new_special.description
				table.insert(specials, { "chance_to_hit", new_special })
			end
			if (weapon_class == "bow" or weapon_class == "javelin" or weapon_class == "thrown_light_blade" or weapon_class == "thrown_heavy_blade") and get_n(weapon, "special_type.remaining_ammo_" .. weapon_class) > 0 then
				special_level = get_n(unit, "variables.abilities.remaining_ammo_" .. weapon_class)
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.remaining_ammo = 1
				new_special = {
					remaining_ammo = 1,
					class = weapon_class,
					id = "remaining_ammo",
					name = "remaining ammo",
				}
				if not player then
					new_special.description = "Remaining Ammo:\nIf any ammo remains after killing a unit with this attack, then it may be used in another attack."
				elseif special_level == 1 then
					new_special.description = "Remaining Ammo Level 1:\nIf any ammo remains after killing a unit with this attack, then it may be used in another attack, minus one strike."
				elseif special_level == 2 then
					new_special.description = "Remaining Ammo Level 2:\nIf any ammo remains after killing a unit with this attack, then it may be used in another attack."
				else
					new_special.description = "Remaining Ammo Level 3:\nIf any ammo remains after killing a unit with this attack, then it may be used in another attack, plus one strike."
				end
				table.insert(specials, { "dummy", new_special })
			end
			if get_n(weapon, "special_type.plague") > 0 and get_n(unit, "variables.abilities.plague") > 0 then
				table.insert(specials, { "plague", {
					id = "plague",
					name = "plague",
					description = "Plague:\nWhen a unit is killed by a Plague attack, that unit is replaced with a Walking Corpse on the same side as the unit with the Plague attack. This doesn't work on Undead.",
					type = "WBD Walking Corpse"
				} })
			end
			if get_n(weapon, "special_type.plague_wbd") > 0 and get_n(unit, "variables.abilities.plague") > 0 then
				table.insert(specials, { "plague", {
					id = "plague_wbd",
					name = "plague",
					description = "Plague:\nWhen a unit is killed by a Plague attack, that unit is replaced with a Walking Corpse on the same side as the unit with the Plague attack. This doesn't work on Undead.",
					type = "Walking Corpse_MODRPG"
				} })
			end
			if get_n(weapon, "special_type.soultrap") > 0 and get_n(unit, "variables.abilities.soultrap") > 0 then
				table.insert(specials, { "plague", {
					id = "soultrap",
					name = "soul trap",
					description = "Soul Trap:\nWhen a unit is killed with a dagger embued with the power of Soul Trap, its spirit doesn't ascend to the next world but instead is trapped to serve its new master.",
					type = "Trapped Spirit"
				} })
			end
			if attack.material == "metal" and attack.range == "melee" and get_n(unit, "variables.abilities.metal_to_arcane") > 0 then
				attack.type = "arcane"
			end
			if (not skirmisher_flag) and attack.range == "melee" then
				special_level = get_n(unit, "variables.abilities.bloodlust")
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.bloodlust = 1
				new_special = {
					bloodlust = 1,
					id = "bloodlust",
					name = "bloodlust",
				}
				if not player then
					new_special.description = "Bloodlust:\nIf this attack kills the target within two strikes, this unit can attack again.\nIf this attack kills the target on the first strike, this unit also recovers one movement point."
				elseif special_level == 1 then
					new_special.description = "Bloodlust Level 1:\nIf this attack kills the target on the first strike, this unit can attack again."
				elseif special_level == 2 then
					new_special.description = "Bloodlust Level 2:\nIf this attack kills the target within two strikes, this unit can attack again.\nIf this attack kills the target on the first strike, this unit also recovers one movement point."
				else
					new_special.description = "Bloodlust Level 3:\nIf this attack kills the target within three strikes, this unit can attack again.\nIf this attack kills the target within two strikes, this unit also recovers one movement point."
				end
				table.insert(specials, { "dummy", new_special })
			end
			if dash_flag and evade > 7 and attack.range == "melee" and get_n(unit, "variables.abilities.grace") > 0 then
				attack.grace = 1
				table.insert(specials, { "dummy", {
					grace = 1,
					id = "grace",
					name = "deadly grace",
					description = "Deadly Grace:\nIf this unit avoids all defending strikes while using this attack, it can attack again.\n\nNOTE: The defending unit must have the chance to strike at least one time for special to trigger."
				} })
			end
			if get_n(weapon, "special_type.magical_to_hit") > 0 or get_n(weapon, "special_type.magical") > 0 then
				table.insert(specials, { "chance_to_hit", {
					id = "magical",
					name = "magical",
					description = "Magical:\nThis attack always has a 70% chance to hit regardless of the defensive ability of the unit being attacked.",
					value = 70,
					cumulative = "no"
				} })
			end
			if get_n(weapon, "special_type.precision") > 0 then
				table.insert(specials, { "chance_to_hit", {
					id = "precision",
					name = "precision",
					description = "Precision:\nThis attack always has a 80% chance to hit",
					value = 80,
					cumulative = "no"
				} })
			end
			if get_n(weapon, "special_type.swarm") > 0 then
				table.insert(specials, { "swarm", {
					id = "swarm",
					name = "swarm",
					description = "Swarm:\nThe number of strikes of this attack decreases when the unit is wounded. The number of strikes is proportional to the percentage of its of maximum HP the unit has. For example a unit with 3/4 of its maximum HP will get 3/4 of the number of strikes."
				} })
			end
			if get_n(weapon, "special_type.charge") > 0 then
				table.insert(specials, { "damage", {
					id = "charge",
					name = "charge",
					description = "Charge:\nWhen used offensively, this attack deals double damage to the target. It also causes this unit to take double damage from the target’s counterattack.",
					multiply=2,
					apply_to="both",
					active_on="offense"
				} })
			end

			if blocked_flag then
				if weapon_class == unblocked_class or (attack[unblocked_class] or 0) > 0 then
					if get_n(unit, "variables.ammo_stored", -1) >= 0 then
						local available_ammo = get_n(unit, "variables.current_ammo")
						set_p(unit, "variables.base_ammo", attack.number)
						if available_ammo > attack.number then
							set_p(unit, "variables.current_ammo", attack.number)
						else
							attack.number = available_ammo
						end
						set_p(unit, "variables.ammo_stored", #attacks)
					end
					unblocked_counter = unblocked_counter + 1
				else
					attack.attack_weight = 0
				end
			end
			if #specials > 0 then
				table.insert(attack, { "specials", specials })
			end
			table.insert(attacks, attack)
			if attack.user_name == "hammer" and get_n(unit, "variables.abilities.devling_spiker") > 0 then
				local spikes = get_p(weapon)
				set_p(spikes, "type", "pierce")
				set_p(spikes, "description", "spike 'em")
				set_p(spikes, "user_name", "spike 'em")
				add_attack(spikes)
			end
			if (get_n(weapon, "special_type.fire_shot_bow") > 0 and get_n(unit, "variables.abilities.fire_shot_bow") > 0) or (get_n(weapon, "special_type.fire_shot_xbow") > 0 and get_n(unit, "variables.abilities.fire_shot_xbow") > 0) then
				local fire_shot = get_p(weapon)
				set_p(fire_shot, "type", "fire")
				set_p(fire_shot, "damage", get_n(weapon, "damage") + 2)
				set_p(fire_shot, "number", get_n(weapon, "number") - 1)
				set_p(fire_shot, "special_type.fire_shot_bow", 0)
				set_p(fire_shot, "special_type.fire_shot_xbow", 0)
				add_attack(fire_shot)
			end
			special_level = get_n(weapon, "enchantments.add_chance_to_hit")
			if (special_level > 0) then
				table.insert(specials, { "chance_to_hit", {
					id = "ench_chance_to_hit",
					name = "accurate",
					description = string.format("This enchanted weapon has a %d%% greater chance to hit", special_level),
					add = special_level,
					cumulative = "yes"
				} })
			end
			if (get_n(weapon, "enchantments.firststrike") > 0) then
				table.insert(specials, { "firststrike", {
					id = "ench_firststrike",
					name = "firststrike",
					description = "This enchanted weapon will react to any attacker, always striking first regardless of the oaf who wields it."
				} })
			end

		end
	end

	add_attack(equipment.melee_1)
	if equipment.melee_2 then
		add_attack(equipment.melee_2)
	end
	if equipment.melee_3 then
		add_attack(equipment.melee_3)
	end
	if equipment.thrown then
		add_attack(equipment.thrown)
	end
	if equipment.ranged then
		add_attack(equipment.ranged)
	end
	if get_n(unit, "variables.abilities.net") > 0 then
		table.insert(attacks, {
			name = "net",
			description = "net",
			icon = "net",
			range = "ranged",
			type = "impact",
			damage = 5,
			number = 2,
			{ "specials", {
				{ "slow", {
					id = "slow",
					name = "slows",
					description = "Slow:\nThis attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					name_inactive = "slows",
					description_inactive = "Slow:\nThis attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					{ "filter_opponent", {
						{ "not", {
							{ "filter_wml", {
								{ "variables", {
									unslowable_flag = 1
								} }
							} }
						} }
					} }
				} }
			} }
		})
	end
	local spells, magic_level = {}, 0
	magic_level = get_n(unit, "variables.abilities.human_magic")
	if magic_level > 0 then
		if magic_level == 2 then
			table.insert(spells, {
				description = "fireball",
				icon = "fireball",
				name = "fireball",
				damage = 3,
				number = 2,
				range = "ranged",
				type = "fire",
				class = "spell",
				spell_power = 2,
				bonus_type = "human_magic_adjust",
				mind_damage_rate = 35,
				{ "special_type", { magical_to_hit = 1 } }
			})
		elseif magic_level == 3 then
			table.insert(spells, {
				description = "lightbeam",
				icon = "lightbeam",
				name = "lightbeam",
				damage = 4,
				number = 1,
				range = "ranged",
				type = "arcane",
				class = "spell",
				spell_power = 2,
				bonus_type = "human_magic_adjust",
				mind_damage_rate = 25,
				{ "special_type", { magical_to_hit = 1 } }
			})
		elseif magic_level == 5 then
			table.insert(spells, {
				description = "lightning",
				icon = "lightning",
				name = "lightning",
				damage = 2,
				number = 1,
				range = "ranged",
				type = "fire",
				class = "spell",
				spell_power = 3,
				bonus_type = "human_magic_adjust",
				mind_damage_rate = 40,
				{ "special_type", { magical_to_hit = 1 } }
			})
		else
			table.insert(spells, {
				description = "magic missile",
				icon = "magic-missile",
				name = "magic missile",
				damage = 4,
				number = 2,
				range = "ranged",
				type = "fire",
				class = "spell",
				bonus_type = "human_magic_adjust",
				mind_damage_rate = 25,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
	end
	magic_level = get_n(unit, "variables.abilities.dark_magic")
	if magic_level > 0 then
		table.insert(spells, {
			description = "chill wave",
			icon = "iceball",
			name = "dark wave",
			damage = 8,
			number = 1,
			range = "ranged",
			type = "cold",
			class = "spell",
			spell_power = 2,
			bonus_type = "dark_magic_adjust",
			mind_damage_rate = 15,
			{ "special_type", { magical_to_hit = 1 } }
		})
		table.insert(spells, {
			description = "shadow wave",
			icon = "dark-missile",
			name = "dark wave",
			damage = 5,
			number = 1,
			range = "ranged",
			type = "arcane",
			class = "spell",
			spell_power = 2,
			bonus_type = "dark_magic_adjust",
			mind_damage_rate = 15,
			{ "special_type", { magical_to_hit = 1 } }
		})
	end
	magic_level = get_n(unit, "variables.abilities.runic_magic")
	if magic_level > 0 then
		table.insert(spells, {
			description = "lightning",
			icon = "lightning",
			name = "lightning",
			damage = 3,
			number = 1,
			range = "ranged",
			type = "fire",
			class = "spell",
			spell_power = 2,
			bonus_type = "runic_magic_adjust",
			mind_damage_rate = 30,
			{ "special_type", { magical_to_hit = 1 } }
		})
	end
	magic_level = get_n(unit, "variables.abilities.faerie_magic")
	if magic_level > 0 then
		table.insert(spells, {
			description = "faerie fire",
			icon = "faerie-fire",
			name = "faerie fire",
			damage = 2,
			number = 3,
			range = "ranged",
			type = "arcane",
			class = "spell",
			spell_power = 2,
			bonus_type = "faerie_magic_adjust",
			mind_damage_rate = 15,
			{ "special_type", { magical_to_hit = 1 } }
		})
	end
	magic_level = get_n(unit, "variables.abilities.wood_magic")
	if magic_level > 0 then
		table.insert(spells, 1, {
			description = "vines",
			icon = "entangle",
			name = "vines",
			damage = 1,
			number = 2,
			range = "ranged",
			type = "impact",
			class = "spell",
			bonus_type = "faerie_magic_adjust",
			mind_damage_rate = 30,
			{ "special_type", { vine_slows = 1, vine_ensnare = 1 } }
		})
		if get_n(unit, "variables.abilities.brambles") == 1 then
			spells[1].spell_power = 2
			table.insert(spells, {
				description = "thorns",
				icon = "thorns",
				name = "thorns",
				damage = 2,
				number = 2,
				range = "ranged",
				type = "pierce",
				class = "spell",
				spell_power = 2,
				bonus_type = "faerie_magic_adjust",
				mind_damage_rate = 30,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
	end
	magic_level = get_n(unit, "variables.abilities.troll_magic")
	if magic_level > 0 then
		table.insert(spells, {
			description = "flame blast",
			icon = "fireball",
			name = "flame blast",
			damage = 5,
			number = 2,
			range = "ranged",
			type = "fire",
			class = "spell",
			bonus_type = "spirit_magic_adjust",
			mind_damage_rate = 25,
			{ "special_type", { magical_to_hit = 1 } }
		})
	end
	magic_level = get_n(unit, "variables.abilities.swamp_magic")
	if magic_level > 0 then
		table.insert(spells, {
			description = "curse",
			icon = "curse",
			name = "curse",
			damage = 3,
			number = 2,
			range = "ranged",
			type = "cold",
			class = "spell",
			bonus_type = "spirit_magic_adjust",
			mind_damage_rate = 10,
			{ "special_type", { magical_to_hit = 1 } }
		})
		if get_n(unit, "variables.abilities.baleful") > 0 then
			spells[#spells].spell_power = 3
		end
	end
	magic_level = get_n(unit, "variables.abilities.tribal_magic")
	if magic_level > 0 then
		table.insert(spells, {
			description = "curse",
			icon = "curse",
			name = "curse",
			damage = 6,
			number = 1,
			range = "ranged",
			type = "pierce",
			class = "spell",
			spell_power = 2,
			bonus_type = "spirit_magic_adjust",
			mind_damage_rate = 30,
			{ "special_type", { spell_drains = 1 } }
		})
	end
	if not player then
		magic_level = get_n(unit, "variables.abilities.witchcraft")
		if magic_level > 0 then
			table.insert(spells, {
				description = "hex",
				icon = "curse",
				name = "curse",
				damage = 4,
				number = 0,
				range = "ranged",
				type = "cold",
				class = "spell",
				spell_power = 2,
				bonus_type = "spirit_magic_adjust",
				mind_damage_rate = 20,
				mind_number_rate = 7,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
		magic_level = get_n(unit, "variables.abilities.minotaur_magic")
		if magic_level > 0 then
			table.insert(spells, {
				description = "aura blast",
				icon = "aura-blast",
				name = "aura blast",
				damage = 6,
				number = 1,
				range = "ranged",
				type = "arcane",
				class = "spell",
				bonus_type = "spirit_magic_adjust",
				mind_damage_rate = 10,
				{ "special_type", { magical_to_hit = 1 } }
			})
			if magic_level == 3 then
				spells[#spells].spell_power = 2
				table.insert(spells, {
					description = "fireball",
					icon = "fireball",
					name = "fireball",
					damage = 6,
					number = 1,
					range = "ranged",
					type = "fire",
					class = "spell",
					bonus_type = "none",
					mind_damage_rate = 7,
					{ "special_type", { magical_to_hit = 1 } }
				})
			end
		end
		magic_level = get_n(unit, "variables.abilities.witch_magic")
		if magic_level > 0 and magic_level < 4 then
			local new_spell = {
				damage = 4,
				number = 2,
				range = "ranged",
				type = "fire",
				mind_number_rate = 10
			}
			if (get_n(equipment.shield, "magic_adjust") + get_n(equipment.head_armor, "magic_adjust") + get_n(equipment.torso_armor, "magic_adjust") + get_n(equipment.leg_armor, "magic_adjust")) > -5 then
				new_spell.description = "witch fire"
				new_spell.icon = "witch-fire"
				new_spell.name = "witch fire"
				table.insert(new_spell, { "special_type", { magical_to_hit = 1, spell_drains = 1 } })
				if magic_level == 2 then
					new_spell.type = "cold"
				end
			else
				if magic_level == 2 then
					new_spell.description = "cold fire"
					new_spell.icon = "iceball"
					new_spell.type = "cold"
				else
					new_spell.description = "fireball"
					new_spell.icon = "fireball"
				end
				new_spell.name = "fireball"
				table.insert(new_spell, { "special_type", { magical_to_hit = 1 } })
			end
		end
		magic_level = get_n(unit, "variables.abilities.warlock_magic")
		if magic_level > 0 then
			table.insert(spells, {
				description = "implosion",
				icon = "implosion",
				name = "implosion",
				damage = 6,
				number = 2,
				range = "ranged",
				type = "cold",
				class = "spell",
				spell_power = 2,
				bonus_type = "spirit_magic_adjust",
				mind_damage_rate = 25,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
		magic_level = get_n(unit, "variables.abilities.devling_flyer")
		if magic_level > 0 then
			table.insert(spells, {
				description = "breath",
				icon = "fireball",
				name = "breath",
				damage = 2,
				number = 2,
				range = "ranged",
				type = "fire",
				class = "none",
				deft_damage_rate = 75,
				deft_number_rate = 10
			})
		end
		magic_level = get_n(unit, "variables.abilities.devling_magic")
		if magic_level > 0 then
			table.insert(spells, {
				description = "wail",
				icon = "curse",
				name = "wail",
				damage = 5,
				number = 2,
				range = "ranged",
				type = "cold",
				class = "spell",
				bonus_type = "none",
				mind_damage_rate = 20,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
	end
	for i = 1, #spells do
		add_attack(parse_container(spells[i]))
	end
	for i = 1, #attacks do
		set_p(unit, string.format("attack[%d]", i - 1), attacks[i])
	end
	if unblocked_counter == 0 then
		set_p(unit, "attacks_left", 0)
	end

	if player or get_p(unit, "type") == "Skeleton_MODRPG" then
		set_p(unit, "variation", variation)
	end

	if not player then
		set_p(unit, "variables.absolute_value", find_npc_value(unit))
		set_p(unit, "variables.equipment_value", find_equipment_value(unit))
	end

	set_p(unit, "upkeep", 0)
	set_p(unit, "variables.dont_make_me_quick", "yes")
	set_p(unit, "status.construct_unit", "yes")
	local unparsed_unit = unparse_container(unit)

	-- Calculate and cache *_adjust stats
	local adjust = eval_equipment(unparsed_unit)
	local unit_variables = wml.get_child(unparsed_unit, "variables")
-- 	std_print(dump_lua_value(unparsed_unit.name, "unit_ref.name"))
-- 	std_print(dump_lua_value(adjust, "adjust"))
	wml.remove_child(unit_variables, "adjust")
	table.insert(unit_variables, {"adjust", adjust})

	wml.variables[var] = unparsed_unit
	if unstore then
		W.unstore_unit { variable = var }
-- 		local unit_x, unit_y = get_p(unit, "x"), get_p(unit, "y")
-- 		-- in 1.9 it might be possible to replace this w/ a call to wesnoth.select_hex()?
-- 		W.object {
-- 			silent = "yes",
-- 			{ "filter", {
-- 				x = unit_x,
-- 				y = unit_y
-- 			} },
-- 			{ "effect", {
-- 				apply_to = "status",
-- 				remove = "aids"
-- 			} }
-- 		}
	end

end
function wesnoth.wml_actions.construct_unit(cfg)
	local var = cfg.variable or werr("[construct_unit] requires a variable= key")
	local unstore = nil
	if type(cfg.unstore) ~= "boolean" then
		unstore = true
	else
		unstore = cfg.unstore
	end
	constructUnit(var, unstore)
end
function wesnoth.wml_actions.unit_npc_init(cfg)
	local var = cfg.variable or werr("[unit_npc_init] requires a variable= key")
	local unit = parse_container(wml.variables[var])
	--std_print("unit_npc_init = " .. var .. " Type = " .. get_p(unit, "type"))
	local tcfg = wesnoth.unit_types[string.format("%s", get_p(unit, "type"))].__cfg or {}
	--w_pt(tcfg)
	local hitpoints = tcfg.hitpoints
	local experience = tcfg.experience
	local level = tcfg.level
	local moves = tcfg.movement
	local body = 1 * (tcfg.level + 1)
	local deft = 1 * (tcfg.level + 1)
	local mind = 1 * (tcfg.level + 1)
	local npc_init = wml.get_child(tcfg, "npc_init") or { wesband = 0,
							likes_gold = 1,
							is_rpg_npc = 1,
							body = body,
							deft = deft,
							mind = mind,
							experience = experience,
							hitpoints = hitpoints,
							level = level,
							max_moves = moves,
								}
	wml.variables[string.format("%s.variables.npc_init", var)] = nil -- clear it
	wml.variables[string.format("%s.variables.npc_init", var)] = npc_init
end
function wesnoth.wml_actions.create_attack_weapon(cfg)
	local var = cfg.variable or werr("[create_attack_weapon] requires a variable= key")
	local attack = cfg.attack or werr("[create_attack_weapon] requires a attack= key")
	local at = parse_container(wml.variables[attack])
	local s = {}

	local droppable = {
			"axe",
			"battle axe",
			"bow",
			"chakram",
			"cleaver",
			"club",
			"crossbow",
			"dagger",
			"epee",
			"flail",
			"glaive",
			"greatsword",
			"halberd",
			"hammer",
			"hatchet",
			"javelin",
			"kusarigama",
			"lance",
			"longbow",
			"mace",
			"mace-spiked",
			"magestaff",
			"pike",
			"pitchfork",
			"plague staff",
			"saber",
			"scimitar",
			"scythe",
			"short sword",
			"sling",
			"spear",
			"staff",
			"sword",
			"throwing knives",
			"thrown-light-blade",
			"thunderstick",
			"trident",
			"whip",
		}

	local specials = get_p(at, "specials")
	local function deepdive(t)
		for i,k in pairs(t) do
			if type(i) == "string" and i == "id" then
				s[k] =  1
			end
			if type(k) == "table" then
				deepdive(t[i])
			end
		end
	end
	deepdive(specials or {})
	clear_p(at, "specials")
	set_p(at, "special_type", s)

	local name = get_p(at, "name")
	set_p(at, "user_name", name)

	local range = get_p(at, "range")
	set_p(at, "absolute_value", 0)
	set_p(at, "body_damage_rate", 0)
	set_p(at, "body_number_rate", 0)
	set_p(at, "category", range .. "_weapon")
	set_p(at, "class", "none")
	set_p(at, "class_description", "none")
	set_p(at, "dark_magic_adjust", 0)
	set_p(at, "deft_damage_rate", 0)
	set_p(at, "deft_number_rate", 0)
	set_p(at, "evade_adjust", 0)
	set_p(at, "faerie_magic_adjust", 0)
	set_p(at, "human_magic_adjust", 0)
	set_p(at, "material", "none")
	set_p(at, "runic_magic_adjust", 0)
	set_p(at, "spirit_magic_adjust", 0)
	set_p(at, "undroppable", 1)

	for i,k in ipairs(droppable) do
		if type(k) == "string" and k == name then
			set_p(at, "undroppable", 0)
		end
	end
	local icon = get_p(at, "icon")
	icon = string.gsub(icon, "attacks/","")
	icon = string.gsub(icon, ".png","")
	set_p(at, "icon", icon)
	set_p(at, "ground_icon", "dummy")
	wml.variables[var] = unparse_container(at)
end
function wesnoth.wml_actions.set_default_abilities(cfg)
	local var = cfg.variable or werr("[set_default_abilities] requires a variable= key")
	local ability = cfg.ability or werr("[set_default_abilities] requires a attack= key")
	local ab = parse_container(wml.variables[ability])
	local v = parse_container(wml.variables[var])

	local abtype = nil
	for i,k in pairs(ab['c']) do
		if type(i) == "string" then
			abtype = i
		end
	end
	if abtype then
		local id = get_p(ab, abtype .. ".id")
		local old_id = get_p(v, "variables.abilities." .. id)
		if not old_id then
			set_p(v, "variables.abilities." .. id, -1)
		end
		wml.variables[var] = unparse_container(v)
	end
end

-- Converts a simpler container of key/value pairs into the terrain object the rest of Wesband expects.
-- input:
--     [terrain]
--         flat=40,1
--     [/terrain]
-- output:
--     [terrain]
--         [flat]
--             defense=40
--             movemebnt=1
--         [/flat]
--     [/terrain]
function wesnoth.wml_actions.unit_init_terrain(cfg)
	local src_var = cfg.src
	local dest = cfg.dest or werr("[unit_init_terrain] requires a dest= key")
	local mode = cfg.mode or "replace"
	local result = {}
	local src, k, v

	for k,v in ipairs(wml.parsed(cfg)) do
		if type(v) == "table" and type(v[1]) == "string" and type(v[2]) == "table" and v[1] == "terrain" then
			src = v[2]
			break
		end
	end

	if src_var and src then
		werr("[unit_init_terrain] requires either a src= key or [terrain], but not both.")
	elseif not (src_var or src) then
		werr("[unit_init_terrain] requires either a src= key or [terrain].")
	elseif src_var then
		src = wml.variables[src_var]
	end

	for k,v in pairs(src) do
		local arr = tostring(v):split(",")
		local defense, movement = tonumber(arr[1]), tonumber(arr[2])
		table.insert(result, {k, {defense = defense, movement = movement}})
	end
	wml.variables[dest] = result
end
