local _ = wesnoth.textdomain "wesnoth-Wesband"

weapon_data = {
	table = {
		axe = {
			names = {"axe", "battle axe"},
			category = "melee_weapon",
			range = "melee",
			name = "axe",
			user_name = "axe",
			description = _ "axe",
			icon = "axe",
			ground_icon = "axe",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 11,
			evade_adjust = -3,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "metal",
			special_type = {
				cleave = 1
			}
		},
		bow = {
			names = {"bow", "longbow"},
			category = "ranged_weapon",
			range = "ranged",
			name = "bow",
			user_name = "bow",
			description = _ "bow",
			icon = "bow",
			ground_icon = "bow",
			type = "pierce",
			class = "bow",
			class_description = "Bow",
			damage = 4,
			number = 2,
			deft_damage_rate = 20,
			deft_number_rate = 10,
			material = "wood",
			special_type = {
				marksman = 1,
				fire_shot_bow = 1,
				remaining_ammo_bow = 1
			}
		},
		lob = {
			names = {"chakram"},
			category = "ranged_weapon",
			range = "ranged",
			name = "lob",
			user_name = "chakram",
			description = _ "chakram",
			icon = "chakram",
			ground_icon = "hatchet",
			type = "blade",
			class = "thrown_heavy_blade",
			class_description = "Thrown Heavy Blade",
			damage = 5,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			body_number_rate = 5,
			material = "metal"
		},
		cleaver = {
			names = {"cleaver"},
			category = "melee_weapon",
			range = "melee",
			name = "axe",
			user_name = "cleaver",
			description = _ "cleaver",
			icon = "cleaver",
			ground_icon = "cleaver",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 5,
			number = 2,
			evade_adjust = -3,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			special_type = {
				cleave = 1
			}
		},
		club = {
			names = {"club"},
			category = "melee_weapon",
			range = "melee",
			name = "mace",
			user_name = "club",
			description = _ "club",
			icon = "club-small",
			ground_icon = "club",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 3,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "wood",
			special_type = {
				storm = 1
			}
		},
		crossbow = {
			names = {"crossbow"},
			category = "ranged_weapon",
			range = "ranged",
			name = "crossbow",
			user_name = "crossbow",
			description = _ "crossbow",
			icon = "crossbow-human",
			ground_icon = "crossbow",
			type = "pierce",
			class = "crossbow",
			class_description = "Crossbow",
			damage = 8,
			deft_damage_rate = 20,
			material = "wood",
			special_type = {
				readied_bolt = 1,
				fire_shot_xbow = 1
			}
		},
		dagger = {
			names = {"dagger"},
			category = "melee_weapon",
			range = "melee",
			name = "dagger",
			user_name = "dagger",
			description = _ "dagger",
			icon = "dagger-human",
			ground_icon = "dagger",
			type = "blade",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 4,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			special_type = {
				backstab = 1,
				soultrap = 1
			}
		},
		dart = {
			names = {"dart"},
			category = "ranged_weapon",
			range = "ranged",
			name = "thrown-light-blade",
			user_name = "dagger-thrown",
			description = _ "dart",
			icon = "dagger-thrown-human",
			ground_icon = "dagger",
			type = "pierce",
			class = "thrown_light_blade",
			class_description = "Thrown Light Blade",
			damage = 2,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			special_type = {
				allow_poison = 1,
				remaining_ammo_thrown_light_blade = 1
			}
		},
		epee = {
			names = {"epee"},
			category = "melee_weapon",
			range = "melee",
			name = "sword",
			user_name = "epee",
			description = _ "epee",
			icon = "saber-human",
			ground_icon = "saber",
			type = "pierce",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 4,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			special_type = {
				riposte = 1,
				slashdash = 1
			}
		},
		faerie_staff = {
			names = {"faerie_staff"},
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "magestaff",
			description = _ "faerie staff",
			icon = "staff-elven",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			faerie_magic_adjust = 10,
			special_type = {
				storm = 1
			}
		},
		glaive = {
			names = {"glaive"},
			category = "melee_weapon",
			range = "melee",
			name = "spear",
			user_name = "glaive",
			description = _ "glaive",
			icon = "spear",
			ground_icon = "spear-fancy",
			type = "blade",
			class = "polearm",
			class_description = "Polearm",
			damage = 7,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 10,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal"
		},
		hammer = {
			names = {"hammer"},
			category = "melee_weapon",
			range = "melee",
			name = "mace",
			user_name = "hammer",
			description = _ "hammer",
			icon = "hammer-dwarven",
			ground_icon = "hammer-runic",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 11,
			evade_adjust = -3,
			body_damage_rate = 25,
			deft_damage_rate = 15,
			body_number_rate = 5,
			material = "metal",
			special_type = {
				storm = 1
			}
		},
		hatchet = {
			names = {"hatchet"},
			category = "ranged_weapon",
			range = "ranged",
			name = "lob",
			user_name = "hatchet",
			description = _ "thrown hatchet",
			icon = "hatchet",
			ground_icon = "hatchet",
			type = "blade",
			class = "thrown_heavy_blade",
			class_description = "Thrown Heavy Blade",
			damage = 7,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			body_number_rate = 5,
			material = "metal",
			special_type = {
				remaining_ammo_thrown_heavy_blade = 1
			}
		},
		javelin = {
			names = {"javelin"},
			category = "ranged_weapon",
			range = "ranged",
			name = "javelin",
			user_name = "javelin",
			description = _ "javelin",
			icon = "javelin-human",
			ground_icon = "spear-fancy",
			type = "pierce",
			class = "javelin",
			class_description = "Javelin",
			damage = 7,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			deft_number_rate = 5,
			material = "metal",
			special_type = {
				remaining_ammo_javelin = 1
			}
		},
		kusarigama = {
			names = {"kusarigama"},
			category = "melee_weapon",
			range = "melee",
			name = "axe",
			user_name = "kusarigama",
			description = _ "kusarigama",
			icon = "scythe",
			ground_icon = "hatchet",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 2,
			number = 3,
			evade_adjust = -3,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			special_type = {
				allow_poison = 1,
				throwable = 1
			}
		},
		mace = {
			names = {"mace", "mace-spiked", "flail"},
			category = "melee_weapon",
			range = "melee",
			name = "mace",
			user_name = "mace",
			description = _ "mace",
			icon = "mace",
			ground_icon = "mace",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 11,
			evade_adjust = -3,
			body_damage_rate = 40,
			body_number_rate = 5,
			material = "metal",
			special_type = {
				storm = 1
			}
		},
		staff = {
			names = {"magestaff", "staff"},
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "magestaff",
			description = _ "magestaff",
			icon = "staff-magic",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			human_magic_adjust = 20,
			special_type = {
				storm = 1
			}
		},
		necrostaff = {
			names = {"necrostaff"},
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "necrostaff",
			description = _ "necromancer staff",
			icon = "staff-necromantic",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			dark_magic_adjust = 15,
			special_type = {
				plague_wbd = 1,
				storm = 1
			}
		},
		plague_staff = {
			names = {"plague staff"},
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "necrostaff",
			description = _ "necromancer staff",
			icon = "staff-necromantic",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			dark_magic_adjust = 15,
			special_type = {
				plague = 1,
				storm = 1
			}
		},
		pike = {
			names = {"pike", "halberd", "trident"},
			category = "melee_weapon",
			range = "melee",
			name = "spear",
			user_name = "pike",
			description = _ "pike",
			icon = "pike",
			ground_icon = "spear-fancy",
			type = "pierce",
			class = "polearm",
			class_description = "Polearm",
			damage = 9,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 10,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			special_type = {
				ensnare = 1,
				firststrike = 1,
				pointpike = 1
			}
		},
		pitchfork = {
			names = {"pitchfork"},
			category = "melee_weapon",
			range = "melee",
			name = "spear",
			user_name = "pitchfork",
			description = _ "pitchfork",
			icon = "pitchfork",
			ground_icon = "pitchfork",
			type = "pierce",
			class = "polearm",
			class_description = "Polearm",
			damage = 5,
			number = 2,
			evade_adjust = -1,
			body_damage_rate = 10,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			special_type = {
				throwable = 1,
				pointpike = 1
			}
		},
		runic_hammer = {
			names = {"runic_hammer"},
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "hammer",
			description = _ "runic hammer",
			icon = "hammer-dwarven-runic",
			ground_icon = "hammer-runic",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "metal",
			runic_magic_adjust = 20,
			special_type = {
				storm = 1
			}
		},
		saber = {
			names = {"saber"},
			category = "melee_weapon",
			range = "melee",
			name = "sword",
			user_name = "saber",
			description = _ "saber",
			icon = "saber-human",
			ground_icon = "saber",
			type = "blade",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 6,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			special_type = {
				riposte = 1,
				slashdash = 1
			}
		},
		scimitar = {
			names = {"scimitar"},
			category = "melee_weapon",
			range = "melee",
			name = "sword",
			user_name = "sword",
			description = _ "scimitar",
			icon = "sword-elven",
			ground_icon = "sword",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 7,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			special_type = {
				cleave = 1
			}
		},
		scythe = {
			names = {"scythe"},
			category = "melee_weapon",
			range = "melee",
			name = "axe",
			user_name = "scythe",
			description = _ "scythe",
			icon = "scythe",
			ground_icon = "hatchet",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 6,
			number = 2,
			evade_adjust = -3,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 10,
			material = "metal",
			special_type = {
				cleave = 1
			}
		},
		sling = {
			names = {"sling"},
			category = "ranged_weapon",
			range = "ranged",
			name = "sling",
			user_name = "sling",
			description = _ "sling",
			icon = "sling",
			ground_icon = "sling",
			type = "impact",
			class = "lob",
			class_description = "Lob",
			damage = 3,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			deft_number_rate = 5,
			material = "cloth",
			special_type = {
				goliath_bane = 1
			}
		},
		spear = {
			names = {"spear", "lance"},
			category = "melee_weapon",
			range = "melee",
			name = "spear",
			user_name = "spear",
			description = _ "spear",
			icon = "spear",
			ground_icon = "spear-fancy",
			type = "pierce",
			class = "polearm",
			class_description = "Polearm",
			damage = 7,
			number = 2,
			evade_adjust = -1,
			body_damage_rate = 10,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			special_type = {
				throwable = 1,
				firststrike = 1,
				pointpike = 1
			}
		},
		spiked_gauntlet = {
			names = {"spiked_gauntlet"},
			category = "melee_weapon",
			range = "melee",
			name = "fist",
			user_name = "spiked gauntlet",
			description = _ "spiked gauntlet",
			icon = "pike",
			ground_icon = "gauntlets",
			type = "pierce",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 5,
			number = 2,
			evade_adjust = -1,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 8,
			deft_number_rate = 2,
			material = "metal"
		},
		spirit_staff = {
			names = {"spirit_staff"},
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "spirit_staff",
			description = _ "spirit staff",
			icon = "staff-magic",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			spirit_magic_adjust = 20,
			special_type = {
				storm = 1
			}
		},
		sword = {
			names = {"sword", "longsword", "greatsword", "short sword"},
			category = "melee_weapon",
			range = "melee",
			name = "sword",
			user_name = "sword",
			description = _ "sword",
			icon = "sword-human",
			ground_icon = "sword",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 7,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			special_type = {
				cleave = 1
			}
		},
		thrown_dagger = {
			names = {"thrown_dagger", "throwing knives"},
			category = "ranged_weapon",
			range = "ranged",
			name = "thrown-light-blade",
			user_name = "dagger_thrown",
			description = _ "thrown dagger",
			icon = "dagger-thrown-human",
			ground_icon = "dagger",
			type = "blade",
			class = "thrown_light_blade",
			class_description = "Thrown Light Blade",
			damage = 2,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			special_type = {
				allow_poison = 1,
				remaining_ammo_thrown_light_blade = 1
			}
		},
		thunderstick = {
			names = {"thunderstick"},
			category = "ranged_weapon",
			range = "ranged",
			name = "thunderstick",
			user_name = "thunderstick",
			description = _ "thunderstick",
			icon = "thunderstick",
			ground_icon = "thunderstick",
			type = "pierce",
			class = "thunderstick",
			class_description = "Thunderstick",
			damage = 22,
			max_damage = 22,
			ts_level = 1,
			material = "composite"
		},
		whip = {
			names = {"whip"},
			category = "melee_weapon",
			range = "melee",
			name = "fist",
			user_name = "whip",
			description = _ "whip",
			icon = "whip",
			ground_icon = "sling",
			type = "blade",
			class = "none",
			class_description = "Lash",
			damage = 4,
			number = 2,
			evade_adjust = -1,
			body_damage_rate = 5,
			deft_damage_rate = 5,
			deft_number_rate = 20,
			material = "cloth"
		},
		fist = {
			names = {"fist"},
			category = "melee_weapon",
			range = "melee",
			undroppable = 1,
			name = "fist",
			user_name = "fist",
			description = _ "fist",
			icon = "fist-human",
			ground_icon = "fist",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 1,
			number = 1,
			evade_adjust = 0,
			body_damage_rate = 20,
			deft_damage_rate = 10,
			body_number_rate = 0,
			deft_number_rate = 10,
			human_magic_adjust = 0,
			dark_magic_adjust = 0,
			faerie_magic_adjust = 0,
			runic_magic_adjust = 0,
			spirit_magic_adjust = 0,
			material = "cloth"
		},
		claws = {
			names = {"claws"},
			category = "melee_weapon",
			range = "melee",
			undroppable = 1,
			name = "fist",
			user_name = "claws",
			description = _ "claws",
			icon = "claws",
			ground_icon = "claws",
			type = "blade",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 2,
			number = 1,
			evade_adjust = 0,
			body_damage_rate = 10,
			deft_damage_rate = 15,
			body_number_rate = 0,
			deft_number_rate = 15,
			human_magic_adjust = 0,
			dark_magic_adjust = 0,
			faerie_magic_adjust = 0,
			runic_magic_adjust = 0,
			spirit_magic_adjust = 0,
			material = "cloth",
			special_type = {
				backstab = 1
			}
		},
		bite = {
			names = {"bite"},
			category = "melee_weapon",
			range = "melee",
			undroppable = 1,
			name = "fist",
			user_name = "bite",
			description = _ "bite",
			icon = "bite",
			ground_icon = "bite",
			type = "blade",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 2,
			number = 1,
			evade_adjust = 0,
			body_damage_rate = 10,
			deft_damage_rate = 15,
			body_number_rate = 0,
			deft_number_rate = 15,
			human_magic_adjust = 0,
			dark_magic_adjust = 0,
			faerie_magic_adjust = 0,
			runic_magic_adjust = 0,
			spirit_magic_adjust = 0,
			material = "cloth",
			special_type = {
				drains = 1
			}
		},
		rock_thrown = {
			names = {"lob"},
			category = "ranged_weapon",
			range = "ranged",
			undroppable = 1,
			name = "lob",
			user_name = "lob",
			description = _ "thrown rock",
			icon = "rock_thrown",
			ground_icon = "rock_thrown",
			type = "impact",
			class = "lob",
			class_description = "Lob",
			damage = 1,
			number = 1,
			body_damage_rate = 20,
			body_number_rate = 0,
			deft_damage_rate = 10,
			deft_number_rate = 0,
			human_magic_adjust = 0,
			dark_magic_adjust = 0,
			faerie_magic_adjust = 0,
			runic_magic_adjust = 0,
			spirit_magic_adjust = 0,
			material = "cloth"
		}
	},
	throwable = {
		pitchfork = {
			category = "ranged_weapon",
			range = "ranged",
			name = "javelin",
			user_name = "javelin",
			description = _ "pitchfork",
			icon = "pitchfork",
			type = "pierce",
			class = "javelin",
			class_description = "Javelin",
			damage = 4,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			body_number_rate = 5,
			special_type = {
				remaining_ammo_javelin = 1
			}
		},
		spear = {
			category = "ranged_weapon",
			range = "ranged",
			name = "javelin",
			user_name = "javelin",
			description = _ "thrown spear",
			icon = "javelin-human",
			type = "pierce",
			class = "javelin",
			class_description = "Javelin",
			damage = 5,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			body_number_rate = 5,
			special_type = {
				remaining_ammo_javelin = 1
			}
		},
		kusarigama = {
			category = "ranged_weapon",
			range = "ranged",
			name = "lob",
			user_name = "kusarigama",
			description = _ "kusarigama",
			icon = "scythe",
			type = "blade",
			class = "thrown_heavy_blade",
			class_description = "Thrown Heavy Blade",
			damage = 3,
			number = 1,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 0,
			special_type = {
				slow = 1
			}
		}
	},
	aliases = {
		["axe"]				= "axe",
		["battle axe"]		= "axe",
		["bow"]				= "bow",
		["longbow"]			= "bow",
		["chakram"]			= "lob",
		["cleaver"]			= "cleaver",
		["club"]			= "club",
		["crossbow"]		= "crossbow",
		["dagger"]			= "dagger",
		["dart"]			= "dart",
		["epee"]			= "epee",
		["faerie_staff"]	= "faerie_staff",
		["glaive"]			= "glaive",
		["hammer"]			= "hammer",
		["hatchet"]			= "hatchet",
		["javelin"]			= "javelin",
		["kusarigama"]		= "kusarigama",
		["mace"]			= "mace",
		["mace-spiked"]		= "mace",
		["flail"]			= "mace",
		["magestaff"]		= "staff",
		["staff"]			= "staff",
		["necrostaff"]		= "necrostaff",
		["plague staff"]	= "plague_staff",
		["pike"]			= "pike",
		["halberd"]			= "pike",
		["trident"]			= "pike",
		["pitchfork"]		= "pitchfork",
		["runic_hammer"]	= "runic_hammer",
		["saber"]			= "saber",
		["scimitar"]		= "scimitar",
		["scythe"]			= "scythe",
		["sling"]			= "sling",
		["spear"]			= "spear",
		["lance"]			= "spear",
		["spiked_gauntlet"]	= "spiked_gauntlet",
		["spirit_staff"]	= "spirit_staff",
		["sword"]			= "sword",
		["longsword"]		= "sword",
		["greatsword"]		= "sword",
		["short sword"]		= "sword",
		["thrown_dagger"]	= "thrown_dagger",
		["throwing knives"]	= "thrown_dagger",
		["thunderstick"]	= "thunderstick",
		["whip"]			= "whip",
		["fist"]			= "fist",
		["claws"]			= "claws",
		["bite"]			= "bite",
		["lob"]				= "rock_thrown"
	},
	conditions = {
		"rusty,unbalanced,none,none,none,none,none,none,heavy,sharp,light,balanced"
	},
	specials = {
		"allow_poison",
		"backstab",
		"cleave",
		"drains",
		"ensnare",
		"fire_shot_bow",
		"fire_shot_xbow",
		"firststrike",
		"goliath_bane",
		"marksman",
		"plague",
		"plague_wbd",
		"pointpike",
		"readied_bolt",
		"remaining_ammo_bow",
		"remaining_ammo_javelin",
		"remaining_ammo_thrown_heavy_blade",
		"remaining_ammo_thrown_light_blade",
		"riposte",
		"slashdash",
		"soultrap",
		"storm",
		"throwable"
	},
	fields = {
		"name",
		"category",
		"range",
		"user_name",
		"description",
		"icon",
		"ground_icon",
		"type",
		"class",
		"class_description",
		"damage",
		"evade_adjust",
		"body_damage_rate",
		"deft_damage_rate",
		"body_number_rate",
		"deft_number_rate",
		"material",
		"number",
		"undroppable",
		"human_magic_adjust",
		"dark_magic_adjust",
		"faerie_magic_adjust",
		"runic_magic_adjust",
		"spirit_magic_adjust"
	},

	attributes = {
		rusty = {
			damage		 = 0.7,
			ench		 = 0.25,
		},
		unbalanced = {
			damage		 = 0.8,
			number		 = -1,
			evade_adjust = -1,
			ench		 = 0.375,
		},
		heavy = {
			damage		 = 1.7,
			number		 = -1,
			evade_adjust = -1,
			ench		 = 1.02,
		},
		light = {
			damage		 = 0.5,
			number		 = 1,
			evade_adjust = 1,
			ench		 = 1.02,
		},
		sharp = {
			damage		 = 1.3,
			ench		 = 1.0625,
		},
		balanced = {
			damage		 = 0.8,
			number		 = 1,
			evade_adjust = 1,
			ench		 = 1.0625,
		},
		none = {}
	},

	ench = {
		arcane = {
			adj  = _"mystic,arcane",
			ego  = _"of arcane power",
			add  = 250,
			mult = 1.25,
		},
		cold = {
			adj  = _"frozen,frosted,chilling",
			ego  = _"of frost",
			add  = 250,
			mult = 1
		},
		fire = {
			adj  = _"firey,burning",
			ego  = _"of fire",
			add  = 250,
			mult = 1
		},
		chance_to_hit = {
			attr = _"seeker,training",
			ego  = _"of accuracy",
			add  = 5,
			mult = 1/12
		},
		firststrike = {
			attr = _"vigilant,twitching,eager",
			ego  = _"of firststrike",
			add  = 200,
			mult = 0.5
		},
		poison = {
			attr = _"venonous",
			ego  = nil,
			add  = 250,
			mult = 0.5
		},
		slow = {
			attr = _"entangling,ensnaring",
			ego  = nil,
			add  = 750,
			mult = 1,
		},
		magical = {
			attr = _"magical",
			ego  = nil,
			add  = 575,
			mult = 0.5
		},
		drains = {
			attr = _"ravenous,hungry,vampyric",
			ego  = _"of draining",
			add  = 500,
			mult = 1.75
		},
		damage = {
			attr = nil,
			ego  = _"of pain",
			add  = 7.5,
			mult = 1/32,
		},
		number = {
			attr = nil,
			ego  = nil,
			add  = 125,
			mult = 1/8,
		},
		evade_adjust = {
			attr = nil,
			ego  = _"of lithe",
			add  = 750,
			mult = 0.25,
		},
		magic_adjust = {
			attr = _"enchanted",
			ego  = nil,
			add  = 150,
			mult = 1/24,
		}
	}
}

magic_types = {
	"human",
	"dark",
	"faerie",
	"runic",
	"spirit"
}

armor_data = {
	shield_attributes = {
		thick = {
			p_mult	= 1.25,
			r_mult	= 1.25,
			ench	= 1.02,
		},
		light = {
			p_mult	= 0.8,
			r_mult	= 0.8,
			ench	= 1.02,
		},
		polished = {
			p_mult	= 0.8,
			ench	= 1.0625,
		},
		rusty = {
			p_mult	= 1.25,
			ench	= 0.375,
		},
		new = {
			r_mult	= 1.25,
			ench	= 1.03125,
		},
		battered = {
			r_mult	= 0.8,
			ench	= 0.75,
		},
		none = {
		}
	},

	attributes = {
		thick = {
			p_mult	= 1.25,
			d_mult	= 1.2,
			r_mult	= 1.2,
			ench	= 1.02,
		},
		light = {
			p_mult	= 0.75,
			d_mult	= 0.8,
			r_mult	= 0.8,
			ench	= 1.02,
		},
		polished = {
			p_mult	= 0.6,
			d_mult	= 0.6,
			ench	= 1.0625,
		},
		rusty = {
			p_mult	= 1.5,
			d_mult	= 1.3,
			ench	= 0.375,
		},
		new = {
			r_mult	= 1.2,
			ench	= 1.03125,
		},
		battered = {
			r_mult	= 0.8,
			ench	= 0.75,
		},
		none = {
		}
	}
}

function dump_weapon_table()
	local t = {}

	local i, j
	local s = ""
	std_print(dump_lua_value(t, "weapons"))
	std_print(dump_lua_value(fields, "fields"))
	for i = 1, 4 do
		s = s .. "alias" .. tostring(i) .. "\t"
	end
	for i = 1, #fields do
		s = s .. fields[i] .. "\t"
	end
	for i = 1, #specials do
		s = s .. specials[i] .. "\t"
	end
	std_print(s)
	for i = 1, #t do
		s = ""
		for j = 1, 4 do
			s = s .. (t[i].names[j] or "") .. "\t"
		end
		for j = 1, #fields do
			s = s .. (t[i][fields[j]] or "") .. "\t"
		end
		for j = 1, #specials do
			s = s .. (t[i].special_type and t[i].special_type[specials[j]] or "") .. "\t"
		end
		std_print(s)
	end
end

function enchantItem(item, level)
	wml.variables["item_temp"] = item
	wml.variables["menu"] = nil
	wml.variables["menu.enchant.level"] = level
	wml.variables["menu.item_path"] = "item_temp"
	wml.variables["current_unit"] = nil
	if wesnoth.current_version() < wesnoth.version(1, 17, 0) then
		wesnoth.fire_event("wbd enchant weapon")
	else
		wesnoth.game_events.fire("wbd enchant weapon")
	end
-- 	std_print(dump_wml_value(item, "item_before"))
	item = wml.variables["item_temp"]
	std_print(dump_lua_value({
		item = item,
-- 		stats = item.enchantments.stats,
	}, "item_after"))
	return item
end

local function lappend(l, st)
	local res = ""
	if #st > 0 then
		res = l .. st
	end
	return res
end

local function sappend(st1, s, st2)
	local res
	if #st2 > 0 then
		if #st1 > 0 then
			res = st1 .. s .. st2
		else
			res = st2
		end
	else
		res = st1
	end
	return res
end

local function cappend(st1, st2)
	return sappend(st1, ", ", st2)
end

function adjustWeaponDescription(wt)
-- 	local ench = wt.enchantments and wt.enchantments[1] or nil
	if wt.evade_adjust and wt.evade_adjust ~= 0 then
		wt.evade_description = string.format(", Evade Adjust: %s%d", (wt.evade_adjust > 0 and "+" or ""), wt.evade_adjust)
	end
	local st1, st2, st3 = "", "", ""
	if wt.class == "thunderstick" then
		st1 = "requires thunderstick tinker for upkeep and upgrade"
	end

	local sp = wml.get_child(wt, "special_type")
	if sp then
		if sp.throwable and sp.throwable == 1 then
			st1 = cappend(st1, "throwable")
		end
		if sp.firststrike and sp.firststrike == 1 then
			st1 = cappend(st1, "allows firststrike")
		end
		if sp.allow_poison and sp.allow_poison == 1 then
			st1 = cappend(st1, "allows poisoning")
		end
		if sp.marksman and sp.marksman == 1 then
			st1 = cappend(st1, "allows marksman")
		end
		if sp.backstab and sp.backstab == 1 then
			st1 = cappend(st1, "allows backstab")
		end
		if (sp.fire_shot_bow and sp.fire_shot_bow == 1) or (sp.fire_shot_xbow and sp.fire_shot_xbow == 1) then
			st1 = cappend(st1, "allows fire shot")
		end
		if sp.goliath_bane and sp.goliath_bane == 1 then
			st1 = cappend(st1, "allows goliath bane")
		end
		if (sp.remaining_ammo_thrown_heavy_blade and sp.remaining_ammo_thrown_heavy_blade == 1) or (sp.remaining_ammo_thrown_light_blade and sp.remaining_ammo_thrown_light_blade == 1) or (sp.remaining_ammo_javelin and sp.remaining_ammo_javelin == 1) or (sp.remaining_ammo_bow and sp.remaining_ammo_bow == 1) then
			st1 = cappend(st1, "allows remaining ammo")
		end
		if sp.readied_bolt and sp.readied_bolt == 1 then
			st1 = cappend(st1, "allows readied bolt")
		end
		if sp.ensnare and sp.ensnare == 1 then
			st1 = cappend(st1, "allows ensnare")
		end
		if sp.slashdash and sp.slashdash == 1 then
			st1 = cappend(st1, "allows slash+dash")
		end
		if sp.riposte and sp.riposte == 1 then
			st1 = cappend(st1, "allows riposte")
		end
		if sp.storm and sp.storm == 1 then
			st1 = cappend(st1, "allows storm")
		end
		if sp.cleave and sp.cleave == 1 then
			st1 = cappend(st1, "allows cleave")
		end
		if sp.charge and sp.charge == 1 then
			st1 = cappend(st1, "allows charge")
		end
		if sp.poison and sp.poison == 1 then
			st1 = cappend(st1, "allows poisoning")
		end
	end
	if wt.human_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to human magic", wt.human_magic_adjust))
	end
	if wt.dark_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to dark magic", wt.dark_magic_adjust))
	end
	if wt.faerie_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to faerie magic", wt.faerie_magic_adjust))
	end
	if wt.runic_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to runic magic", wt.runic_magic_adjust))
	end
	if wt.spirit_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to spirit magic", wt.spirit_magic_adjust))
	end
	if wt.body_damage_rate and wt.body_damage_rate > 0 then
		st2 = string.format("%d%% body", wt.body_damage_rate)
	end
	if wt.deft_damage_rate and wt.deft_damage_rate > 0 then
		st2 = cappend(st2, string.format("%d%% deft", wt.deft_damage_rate))
	end
	if wt.mind_damage_rate and wt.mind_damage_rate > 0 then
		st2 = cappend(st2, string.format("%d%% mind", wt.mind_damage_rate))
	end
	st2 = lappend("Damage: ", st2)
	if wt.body_number_rate and wt.body_number_rate > 0 then
		st3 = string.format("%d%% body", wt.body_number_rate)
	end
	if wt.deft_number_rate and wt.deft_number_rate > 0 then
		st3 = cappend(st3, string.format("%d%% deft", wt.deft_number_rate))
	end
	if wt.mind_number_rate and wt.mind_number_rate > 0 then
		st3 = cappend(st3, string.format("%d%% mind", wt.mind_number_rate))
	end
	st3 = lappend("Strikes: ", st3)
	st2 = sappend(st2, "; ", st3)
	st1 = sappend(st1, "\n", st2)
	st2 = ""
	local pr = wml.get_child(wt, "prereq")
	if pr then
		if pr.body and pr.body > 0 then
			st2 = string.format("%d body", pr.body)
		end
		if pr.deft and pr.deft > 0 then
			st2 = cappend(st2, string.format("%d deft", pr.deft))
		end
		if pr.mind and pr.mind > 0 then
			st2 = cappend(st2, string.format("%d mind", pr.mind))
		end
	end
	st2 = lappend("Requires: ", st2)
	if wt.class == "polearm" then
		st1 = sappend(st1, "\n", st2)
	else
		st1 = sappend(st1, "; ", st2)
	end
	wt.special = st1
	return wt
end
function wesnoth.wml_actions.adjust_weapon_description(args)
	local var = string.match(args.variable, "[^%s]+") or H.wml_error("[adjust_weapon_description] requires a variable= key")
	wml.variables[var] = adjustWeaponDescription(wml.variables[var])
end

local function adjustArmorDescription(at)
	at.special = ""
	if at.block_wield then
		if at.block_wield == 1 then
			at.special = "disallows triple wield"
		elseif at.block_wield == 2 then
			at.special = "disallows dual wield"
		end
	end
	if at.block_ranged and at.block_ranged == 1 then
		at.special = cappend(at.special, "disallows ranged weapon")
	end
	local sp = wml.get_child(at, "special_type")
	if sp and sp.steadfast and sp.steadfast == 1 then
		at.special = cappend(at.special, "allows steadfast")
	end
	return at
end
function wesnoth.wml_actions.adjust_armor_description(args)
	local var = string.match(args.variable, "[^%s]+") or H.wml_error("[adjust_armor_description] requires a variable= key")
	wml.variables[var] = adjustArmorDescription(wml.variables[var])
end

local function createWeapon(wtype, level, attr, var)
	if attr == "random" then
		attr = mathx.random_choice("rusty,unbalanced,none,none,none,none,none,none,heavy,sharp,light,balanced")
	end

	local ench_chance = mathx.random(1000) + level * 2
	local rank = level * 5 / 12

	local function addMagicAdjust(school, wt)
		local amount = wt[school]
		if amount then
			local rank_frac = 1 + level * 0.1

			local aa
			if attr == "rusty" then
				aa = math.floor(rank_frac * amount * 0.7 + 0.5)
			elseif attr == "sharp" then
				aa = math.floor(rank_frac * amount * 1.3 + 0.5)
			else
				aa = math.floor(rank_frac * amount + 0.5)
			end

			wt[school] = aa
			wt.absolute_value = wt.absolute_value + 2.5 * aa
		end
		return wt
	end

	local function adjustCoreStats(wt)
		if wt.range == "melee" then
			wt.category = "melee_weapon"
		end
		if wt.range == "ranged" then
			wt.category = "ranged_weapon"
		end
		wt.category = wt.category or "melee_weapon"
		if wt.category == "melee_weapon" then
			wt.range = wt.range or "melee"
			wt.evade_adjust = wt.evade_adjust or 0
		else
			wt.range = wt.range or "ranged"
		end

		if wt.number == 0 then
			wt.damage = mathx.round(wt.damage + 2 * rank)
		elseif wt.number == 1 then
			wt.damage = wt.damage + mathx.round(rank)
		else
			wt.number = mathx.round(wt.number + rank * 0.25)
			wt.damage = mathx.round(wt.damage + rank * 0.75)
		end

		local attr_mods = weapon_data.attributes[attr]
		if not attr_mods then
			werr(string.format("invalid attribute= key in [create_weapon]: %s", attr))
		end

		-- Apply attribute modifiers
		if attr_mods.damage then
			wt.damage = mathx.round(wt.damage * attr_mods.damage)
		end
		if attr_mods.number then
			wt.number = wt.number + attr_mods.number
		end
		if attr_mods.evade_adjust and wt.evade_adjust then
			wt.evade_adjust = wt.evade_adjust + attr_mods.evade_adjust
		end
		if attr_mods.ench then
			ench_chance = ench_chance * attr_mods.ench
		end

		wt.body_damage_rate = wt.body_damage_rate or 0
		wt.deft_damage_rate = wt.deft_damage_rate or 0
		wt.body_number_rate = wt.body_number_rate or 0
		wt.deft_number_rate = wt.deft_number_rate or 0
		if not (wt.class == "crossbow" or wt.class == "thunderstick") then
			if wt.number < 2 then
				if (wt.body_damage_rate + wt.deft_damage_rate) < 25 then
					wt.body_damage_rate = 2 * wt.body_damage_rate
					wt.deft_damage_rate = 2 * wt.deft_damage_rate
					wt.body_number_rate = math.floor(wt.body_number_rate / 2)
					wt.deft_number_rate = math.floor(wt.deft_number_rate / 2)
					if (wt.body_number_rate + wt.deft_number_rate) < 5 then
						wt.deft_number_rate = 5 - wt.body_number_rate
					end
				end
			elseif (wt.body_damage_rate + wt.deft_damage_rate) > 25 then
				wt.body_number_rate = 2 * wt.body_number_rate
				wt.deft_number_rate = 2 * wt.deft_number_rate
				wt.body_damage_rate = math.floor(wt.body_damage_rate / 2)
				wt.deft_damage_rate = math.floor(wt.deft_damage_rate / 2)
				if (wt.body_damage_rate + wt.deft_damage_rate) < 20 then
					wt.body_damage_rate = 20 - wt.deft_damage_rate
				end
			end
		end

		table.insert(wt, { "prereq", {} })
		if wt.class == "light_blade" or wt.class == "thrown_light_blade" or wt.class == "lash" then
			wt[#wt][2].deft = wt.damage
		elseif wt.class == "lob" or wt.class == "thrown_heavy_blade" then
			wt[#wt][2].body = math.floor(1.5 * wt.damage)
		elseif wt.class == "polearm" then
			wt[#wt][2].body = math.floor(0.7 * wt.damage)
			wt[#wt][2].deft = wt[#wt][2].body
		elseif not (wt.class == "crossbow" or wt.class == "thunderstick") then
			wt[#wt][2].body = wt.damage
		end

		-- backfill vghetto adjust magic power here
		addMagicAdjust("human_magic_adjust", wt)
		addMagicAdjust("dark_magic_adjust", wt)
		addMagicAdjust("faerie_magic_adjust", wt)
		addMagicAdjust("runic_magic_adjust", wt)
		addMagicAdjust("spirit_magic_adjust", wt)

		-- If we get over 995, then the weapon is enchanted
		if ench_chance >= 995 then
			local power = 1.0 + (ench_chance - 995) * level / 95
-- 			local power = 1.0 + (ench_chance - 195) / 3 * level / 95
			std_print(string.format("ench power = %f", power))
			wt = enchantItem(wt, mathx.round(power))
		end

		return wt
	end

	local function adjustStats(wt)
		-- this is static
		wt.prob_name			= wtype
		wt.human_magic_adjust	= wt.human_magic_adjust or 0
		wt.dark_magic_adjust	= wt.dark_magic_adjust or 0
		wt.faerie_magic_adjust	= wt.faerie_magic_adjust or 0
		wt.runic_magic_adjust	= wt.runic_magic_adjust or 0
		wt.spirit_magic_adjust	= wt.spirit_magic_adjust or 0
		wt.absolute_value 		= wt.absolute_value or 0
		wt.rank					= mathx.round(rank)
		wt.level				= level
		wt.number				= wt.number or 1

		return adjustCoreStats(wt)
	end

	local function adjustName(nm)
		local at, name
		if attr == "none" then
			name = tostring(nm)
		else
			if attr == "rusty" then
				if wtype == "club" or wtype == "magestaff" or wtype == "necrostaff" or wtype == "faerie_staff" or wtype == "spirit_staff" then
					at = _ "rotten "
				elseif wtype == "bow" or wtype == "crossbow" then
					at = _ "cracked "
				elseif wtype == "sling" then
					at = _ "worn "
				else
					at = _ "rusty "
				end
			elseif attr == "unbalanced" then
				if wtype == "bow" or wtype == "crossbow" then
					at = _ "rigid "
				elseif wtype == "sling" then
					at = _ "loose "
				else
					at = _ "unbalanced "
				end
			elseif attr == "heavy" then
				if wtype == "bow" then
					at = _ "long"
				elseif wtype == "sword" then
					at = _ "great"
				elseif wtype == "scimitar" then
					at = _ "great "
				else
					at = _ "heavy "
				end
			elseif attr == "light" then
				if wtype == "sword" or wtype == "saber"  then
					at = _ "short "
				elseif wtype == "bow" then
					at = _ "short"
				else
					at = _ "light "
				end
			elseif attr == "sharp" then
				if wtype == "club" then
					at = _ "crafted "
				elseif wtype == "bow" or wtype == "crossbow" then
					at = _ "recurve "
				elseif wtype == "sling" then
					at = _ "woven "
				elseif wtype == "magestaff" or wtype == "necrostaff" or wtype == "faerie_staff" or wtype == "spirit_staff" then
					at = _ "ebony "
				else
					at = _ "sharp "
				end
			elseif attr == "balanced" then
				if wtype == "bow" then
					at = _ "flexible "
				elseif wtype == "crossbow" then
					at = _ "geared "
				elseif wtype == "sling" then
					at = _ "knotted "
				else
					at = _ "balanced "
				end
			else
				H.wml_error(string.format("invalid attribute= key in [create_weapon]: %s", attr))
			end
			name = string.format("%s%s", tostring(at), tostring(nm))
		end
		return name
	end

	local function finalAdjust(wt)
		local bc = wt.damage * wt.number
		local cm = 0.78125
		if wt.class == "ranged" then
			cm = cm * 1.25
		end
		wt.absolute_value = math.max(2, math.floor(cm * bc * (bc + 1) + 3.75 * (wt.evade_adjust or 0) + wt.absolute_value + 0.5))
		local k, v
		local ench, ench_stats
		for k, v in ipairs(wt) do
			if type(v) == "table" and type(v[1]) == "string" and v[1] == "enchantments" then
				ench = v[2]
				break
			end
		end

		if ench then
-- 			std_print("found [enchantments]")
			for k, v in ipairs(ench) do
				if type(v) == "table" and type(v[1]) == "string" and v[1] == "stats" then
					ench_stats = v[2]
					break
				end
			end
		end

		if ench_stats then
-- 			std_print("found [enchantments][stats]")
			local mult = 1
			local k, v
			for k, v in pairs(weapon_data.ench) do
				if ench_stats[k] then
					wt.absolute_value = wt.absolute_value + v.add * ench_stats[k] * (1 + level / 15)
					mult = mult + v.mult * ench_stats[k]
				end
			end

			wt.absolute_value = mathx.round(wt.absolute_value * mult)
-- 			std_print("Enchanted pricing: " .. mult)
		else
-- 			·std_print("NO ENCHANTMENTS " .. tostring(wt.name))
		end

		wt.description = adjustName(wt.description)
		return adjustWeaponDescription(wt)
	end

	-- NOTE: This isn't a true "arch-type" until we distill our weapons table and utilize proper
	-- polymorphism to reduce it's size and eliminate data duplication. But for now, we'll call
	-- call it an arch-type anyway
	local arch_type = weapon_data.aliases[wtype] or H.wml_error(string.format("invalid type= key in [create_weapon] (%s)", wtype))
	local weapon = {}
	-- copy weapon data
	for k, v in pairs(weapon_data.table[arch_type]) do
		if k ~= "names" then
			weapon[k] = v
		end
	end

	if weapon_data.throwable[arch_type] then
		weapon.thrown = weapon_data.throwable[arch_type]
	end

	weapon = noarr_lua_table2wml(weapon)
-- 	std_print(dump_lua_value(weapon, "weapon"))
	weapon = adjustStats(weapon)
	if weapon.thrown then
		weapon.thrown = adjustCoreStats(weapon.thrown)
	end
	wml.variables[var] = finalAdjust(weapon)
end

function wesnoth.wml_actions.create_weapon(args)
	local wtype = string.match(args.type, "[^%s]+") or H.wml_error("[create_weapon] requires a type= key")
	local level = args.rank or 0
	local attr = string.match(args.attribute or "none", "[^%s]+")
	local var = string.match(args.variable, "[^%s]+") or H.wml_error("[create_weapon] requires a variable= key")

	createWeapon(wtype, level, attr, var)
end

local function createArmor(atype, rank, attr, var)
	if attr == "random" then
		attr =  mathx.random_choice("thick,light,polished,rusty,new,battered,none,none,none,none,none,none")
	end

-- 	if ench_chance >= 995 then
-- 		local power = 1 + (ench_chance - 995) * level / 75
-- 		std_print(string.format("ench power = %d", power))
-- 	end

	local rank_frac =  rank * 0.1 + 1

	local function adjustName(nm, mat)
		local at, name
		if attr == "none" then
			name = tostring(nm)
		else
			if attr == "light" then
				if mat == "cloth" then
					at = _ "thin "
				else
					at = _ "light "
				end
			elseif attr == "thick" then
				at = _ "thick "
			elseif attr == "polished" then
				if mat == "leather" then
					at = _ "oiled "
				elseif mat == "cloth" then
					at = _ "fine "
				else
					at = _ "polished "
				end
			elseif attr == "rusty" then
				if mat == "cloth" or mat == "leather"  then
					at = _ "stiff "
				else
					at = _ "rusty "
				end
			elseif attr == "new" then
				at = _ "new "
			elseif attr == "battered" then
				if mat == "leather" then
					at = _ "worn "
				elseif mat == "cloth" then
					at = _ "tattered "
				else
					at = _ "battered "
				end
			else
				H.wml_error("invalid attribute= key in [create_armor]")
			end
			name = string.format("%s%s", tostring(at), tostring(nm))
		end
		return name
	end

	local function adjustShield(at)
		local p_mult, r_mult = 1, 1
		if attr == "thick" then
			p_mult = 1.25
			r_mult = 1.25
		elseif attr == "light" then
			p_mult = 0.8
			r_mult = 0.8
		elseif attr == "polished" then
			p_mult = 0.8
		elseif attr == "rusty" then
			p_mult = 1.25
		elseif attr == "new" then
			r_mult = 1.25
		elseif attr == "battered" then
			r_mult = 0.8
		elseif not (attr == "none") then
			H.wml_error("invalid attribute= key in [create_armor]")
		end
		at.terrain_recoup = math.floor(at.terrain_recoup * rank_frac * r_mult + 0.5)
		at.ranged_adjust = math.ceil((at.ranged_adjust or 0) * p_mult - 0.5)
		at.magic_adjust = math.ceil((at.magic_adjust or 0) * p_mult - 0.5)
		at.evade_adjust = math.ceil((at.evade_adjust or 0) * p_mult - 0.5)

		at.category = "shield"
		at.block_wield = at.block_wield or 0
		at.block_ranged = at.block_ranged or 0
		return at
	end

	local function adjustArmor(at)
		local p_mult, d_mult, r_mult = 1, 1, 1
		if attr == "thick" then
			p_mult = 1.25
			d_mult = 1.2
			r_mult = 1.2
		elseif attr == "light" then
			p_mult = 0.75
			d_mult = 0.8
			r_mult = 0.8
		elseif attr == "polished" then
			p_mult = 0.6
			d_mult = 0.6
		elseif attr == "rusty" then
			p_mult = 1.5
			d_mult = 1.3
		elseif attr == "new" then
			r_mult = 1.2
		elseif attr == "battered" then
			r_mult = 0.8
		elseif not (attr == "none") then
			H.wml_error("invalid attribute= key in [create_armor]")
		end

		local function adjustResists(rt)
			-- don't want "extra resist" to feel like it needs avoiding when event-hacking
			r_mult = r_mult * rank_frac

			if 0 == mathx.random_choice("0..3") then
				local extra_resist = mathx.random_choice("arcane,blade,cold,fire,impact,pierce")
				rt[extra_resist] = (rt[extra_resist] or 0) + rank
			end

			if not rt.arcane then
				rt.arcane = 0
			elseif rt.arcane > 0 then
				rt.arcane = math.floor(rt.arcane * r_mult + 0.5)
			end
			if not rt.blade then
				rt.blade = 0
			elseif rt.blade > 0 then
				rt.blade = math.floor(rt.blade * r_mult + 0.5)
			end
			if not rt.cold then
				rt.cold = 0
			elseif rt.cold > 0 then
				rt.cold = math.floor(rt.cold * r_mult + 0.5)
			end
			if not rt.fire then
				rt.fire = 0
			elseif rt.fire > 0 then
				rt.fire = math.floor(rt.fire * r_mult + 0.5)
			end
			if not rt.impact then
				rt.impact = 0
			elseif rt.impact > 0 then
				rt.impact = math.floor(rt.impact * r_mult + 0.5)
			end
			if not rt.pierce then
				rt.pierce = 0
			elseif rt.pierce > 0 then
				rt.pierce = math.floor(rt.pierce * r_mult + 0.5)
			end
			return rt
		end
		local function adjustMovetype(mt)
			local tt = {
				{ "castle", { defense = 0, movement = 0 } },
				{ "cave", { defense = 0, movement = 0 } },
				{ "deep_water", { defense = 0, movement = 0 } },
				{ "flat", { defense = 0, movement = 0 } },
				{ "forest", { defense = 0, movement = 0 } },
				{ "frozen", { defense = 0, movement = 0 } },
				{ "fungus", { defense = 0, movement = 0 } },
				{ "hills", { defense = 0, movement = 0 } },
				{ "impassable", { defense = 0, movement = 0 } },
				{ "mountains", { defense = 0, movement = 0 } },
				{ "reef", { defense = 0, movement = 0 } },
				{ "sand", { defense = 0, movement = 0 } },
				{ "shallow_water", { defense = 0, movement = 0 } },
				{ "swamp_water", { defense = 0, movement = 0 } },
				{ "unwalkable", { defense = 0, movement = 0 } },
				{ "village", { defense = 0, movement = 0 } }
			}
			local it = {
				castle = 1,
				cave = 2,
				deep_water = 3,
				flat = 4,
				forest = 5,
				frozen = 6,
				fungus = 7,
				hills = 8,
				impassable = 9,
				mountains = 10,
				reef = 11,
				sand = 12,
				shallow_water = 13,
				swamp_water = 14,
				unwalkable = 15,
				village = 16
			}
			for j = 1, #mt do
				local i = it[mt[j][1]]
				tt[i][2].defense = math.floor((mt[j][2].defense or 0) * d_mult + 0.5)
				tt[i][2].movement = mt[j][2].movement or 0
			end
			return tt
		end

		at.category = at.category or "torso_armor"

		at.magic_adjust = math.ceil((at.magic_adjust or 0) * p_mult - 0.5)
		at.evade_adjust = math.ceil((at.evade_adjust or 0) * p_mult - 0.5)
		if at.category == "head_armor" then
			at.ranged_adjust = math.ceil((at.ranged_adjust or 0) * p_mult - 0.5)
		end

		local r_flag, t_flag, b_flag = false, at.category == "head_armor", at.category ~= "torso_armor"
		for i = 1, #at do
			if at[i] and at[i][1] then
				if at[i][1] == "resistance" then
					at[i][2] = adjustResists(at[i][2])
					r_flag = true
				elseif at[i][1] == "terrain" then
					at[i][2] = adjustMovetype(at[i][2])
					t_flag = true
				elseif at[i][1] == "restricts" then
					at[i][2].head = at[i][2].head or 0
					at[i][2].arms = at[i][2].arms or 0
					at[i][2].legs = at[i][2].legs or 0
					at[i][2].shield = at[i][2].shield or 0
					b_flag = true
				end
				if r_flag and t_flag and b_flag then
					break
				end
			end
		end
		if not r_flag then
			table.insert(at, { "resistance", adjustResists({}) })
		end
		if not t_flag then
			table.insert(at, { "terrain", adjustMovetype({}) })
		end
		if not b_flag then
			table.insert(at, { "restricts", { head = 0, arms = 0, legs = 0, shield = 0 } })
		end

		return at
	end

	local function finalAdjust(at)
		if at.category == "shield" then
			at.absolute_value = math.max(2, math.floor(10 * at.terrain_recoup + 0.25 * (at.magic_adjust + at.ranged_adjust) + 3.75 * at.evade_adjust + 0.5))
		else
			local d_val, r_val, b_val = 0
			local r_flag, t_flag = false, at.category == "head_armor"
			for i = 1, #at do
				if at[i] and at[i][1] then
					if at[i][1] == "resistance" then
						r_val = at[i][2].blade + at[i][2].cold + at[i][2].fire + at[i][2].impact + at[i][2].pierce
						r_flag = true
					elseif at[i][1] == "terrain" then
						d_val = at[i][2][4][2].defense
						t_flag = true
					end
					if r_flag and t_flag then
						break
					end
				end
			end
			b_val = r_val + 0.2 * at.magic_adjust + 0.6 * at.evade_adjust - d_val
			at.absolute_value = math.max(2, math.floor(0.125 * b_val * (b_val + 1) + 0.5))
		end

		at.prob_name = atype
		at.description = adjustName(at.description, at.material)
		at.rank = rank
		at.level = rank
		return adjustArmorDescription(at)
	end

	local armor
	if atype == "buckler" then
		armor = adjustShield {
			name = "buckler",
			description = _ "buckler",
			icon = "armor/buckler",
			ground_icon = "buckler",
			material = "metal",
			terrain_recoup = 4,
			evade_adjust = -2,
			magic_adjust = -30,
			ranged_adjust = -10
		}
	elseif atype == "iron_greaves" then
		armor = adjustArmor {
			category = "legs_armor",
			name = "iron_greaves",
			description = _ "iron greaves",
			icon = "icons/greaves",
			ground_icon = "greaves",
			material = "metal",
			evade_adjust = -5,
			magic_adjust = -10,
			{ "resistance", {
				blade = 27,
				cold = -5,
				fire = -5,
				impact = 8,
				pierce = 30
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 7 } },
				{ "castle", { defense = 10 } },
				{ "village", { defense = 7 } },
				{ "shallow_water", { defense = 7 } },
				{ "deep_water", { defense = 7 } },
				{ "flat", { defense = 10 } },
				{ "forest", { defense = 7 } },
				{ "hills", { defense = 10 } },
				{ "mountains", { defense = 7 } },
				{ "swamp_water", { defense = 7 } },
				{ "fungus", { defense = 10 } }
			} }
		}
	elseif atype == "iron_helm" then
		armor = adjustArmor {
			category = "head_armor",
			name = "iron_helm",
			description = _ "iron helm",
			icon = "icons/helmet_corinthian",
			ground_icon = "helmet",
			material = "metal",
			evade_adjust = -3,
			ranged_adjust = -30,
			{ "resistance", {
				blade = 13,
				impact = 11
			} }
		}
	elseif atype == "iron_plate" then
		armor = adjustArmor {
			name = "iron_plate",
			description = _ "iron plate",
			icon = "icons/breastplate",
			ground_icon = "armor",
			material = "metal",
			evade_adjust = -10,
			magic_adjust = -40,
			{ "resistance", {
				blade = 40,
				fire = -5,
				cold = -5,
				impact = 11,
				pierce = 30
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 7 } },
				{ "castle", { defense = 10 } },
				{ "village", { defense = 7 } },
				{ "shallow_water", { defense = 7 } },
				{ "deep_water", { defense = 7 } },
				{ "flat", { defense = 10 } },
				{ "forest", { defense = 7 } },
				{ "hills", { defense = 10 } },
				{ "mountains", { defense = 10 } },
				{ "swamp_water", { defense = 10 } },
				{ "fungus", { defense = 10 } }
			} }
		}
	elseif atype == "full_helm" then
		armor = adjustArmor {
			category = "head_armor",
			name = "full_helm",
			description = _ "full helm",
			icon = "icons/helmet_crested",
			ground_icon = "helmet",
			material = "metal",
			evade_adjust = -3,
			ranged_adjust = -10,
			{ "resistance", {
				blade = 7,
				impact = 15
			} }
		}
	elseif atype == "leather_cap" then
		armor = adjustArmor {
			category = "head_armor",
			name = "leather_cap",
			description = _ "leather cap",
			icon = "armor/leather-cap",
			ground_icon = "cap",
			material = "leather",
			evade_adjust = -1,
			{ "resistance", {
				blade = 5,
				impact = 7
			} }
		}
	elseif atype == "leather_leggings" then
		armor = adjustArmor {
			category = "legs_armor",
			name = "leather_leggings",
			description = _ "leather leggings",
			icon = "icons/boots_elven",
			ground_icon = "boots",
			material = "leather",
			evade_adjust = -2,
			{ "resistance", {
				blade = 10,
				impact = 5,
				pierce = 10
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 2 } },
				{ "shallow_water", { defense = 2 } },
				{ "deep_water", { defense = 2 } },
				{ "flat", { defense = 2 } },
				{ "forest", { defense = 2 } },
				{ "hills", { defense = 2 } },
				{ "swamp_water", { defense = 2 } },
				{ "frozen", { defense = 2 } },
				{ "fungus", { defense = 2 } }
			} }
		}
	elseif atype == "mage_robe" then
		armor = adjustArmor {
			name = "mage_robe",
			description = _ "mage robe",
			icon = "icons/cloak_leather_brown",
			ground_icon = "robe",
			material = "cloth",
			evade_adjust = -14,
			{ "restricts", {
				head = 1,
				legs = 1
			} },
			{ "resistance", {
				blade = 25,
				impact = 17,
				pierce = 17
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 10 } },
				{ "shallow_water", { defense = 10 } },
				{ "deep_water", { defense = 10 } },
				{ "flat", { defense = 10 } },
				{ "forest", { defense = 10 } },
				{ "hills", { defense = 10 } },
				{ "swamp_water", { defense = 10 } },
				{ "frozen", { defense = 10 } },
				{ "fungus", { defense = 10 } }
			} }
		}
	elseif atype == "mail_greaves" then
		armor = adjustArmor {
			category = "legs_armor",
			name = "mail_greaves",
			description = _ "mail greaves",
			icon = "icons/greaves",
			ground_icon = "greaves",
			material = "metal",
			evade_adjust = -4,
			magic_adjust = -10,
			{ "resistance", {
				blade = 18,
				impact = 10,
				pierce = 15
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 5 } },
				{ "shallow_water", { defense = 5 } },
				{ "deep_water", { defense = 5 } },
				{ "flat", { defense = 5 } },
				{ "forest", { defense = 5 } },
				{ "hills", { defense = 5 } },
				{ "swamp_water", { defense = 5 } },
				{ "frozen", { defense = 5 } },
				{ "fungus", { defense = 5 } }
			} }
		}
	elseif atype == "round_shield" then
		armor = adjustShield {
			name = "shield_round",
			description = _ "round shield",
			icon = "icons/shield_wooden",
			ground_icon = "buckler",
			material = "metal",
			terrain_recoup = 8,
			evade_adjust = -5,
			magic_adjust = -60,
			ranged_adjust = -15,
			block_wield = 1
		}
	elseif atype == "scale_mail" then
		armor = adjustArmor {
			name = "scale_mail",
			description = _ "scale mail",
			icon = "icons/cuirass_muscled",
			ground_icon = "armor",
			material = "metal",
			evade_adjust = -6,
			magic_adjust = -25,
			{ "resistance", {
				blade = 25,
				impact = 15,
				pierce = 15
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 5 } },
				{ "shallow_water", { defense = 5 } },
				{ "deep_water", { defense = 5 } },
				{ "flat", { defense = 5 } },
				{ "forest", { defense = 5 } },
				{ "hills", { defense = 5 } },
				{ "swamp_water", { defense = 5 } },
				{ "frozen", { defense = 5 } },
				{ "fungus", { defense = 5 } }
			} }
		}
	elseif atype == "studded_leather" then
		armor = adjustArmor {
			name = "studded_leather",
			description = _ "studded leather",
			icon = "icons/cuirass_leather_studded",
			ground_icon = "armor",
			material = "leather",
			evade_adjust = -4,
			magic_adjust = -20,
			{ "resistance", {
				blade = 15,
				impact = 8,
				pierce = 10
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 3 } },
				{ "shallow_water", { defense = 3 } },
				{ "deep_water", { defense = 3 } },
				{ "flat", { defense = 3 } },
				{ "forest", { defense = 3 } },
				{ "hills", { defense = 3 } },
				{ "swamp_water", { defense = 3 } },
				{ "frozen", { defense = 3 } },
				{ "fungus", { defense = 3 } }
			} }
		}
	elseif atype == "tempered_plate" then
		armor = adjustArmor {
			name = "tempered_plate",
			description = _ "tempered plate",
			icon = "armor/plate-tempered",
			ground_icon = "armor",
			material = "metal",
			evade_adjust = -8,
			magic_adjust = -40,
			{ "resistance", {
				blade = 15,
				impact = 7,
				pierce = 45
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 5 } },
				{ "shallow_water", { defense = 5 } },
				{ "deep_water", { defense = 5 } },
				{ "flat", { defense = 5 } },
				{ "forest", { defense = 5 } },
				{ "hills", { defense = 5 } },
				{ "swamp_water", { defense = 5 } },
				{ "frozen", { defense = 5 } },
				{ "fungus", { defense = 5 } }
			} }
		}
	elseif atype == "tower_shield" then
		armor = adjustShield {
			name = "shield_tower",
			description = _ "tower shield",
			icon = "icons/shield_tower",
			ground_icon = "buckler",
			material = "metal",
			terrain_recoup = 18,
			evade_adjust = -8,
			magic_adjust = -80,
			ranged_adjust = -20,
			block_wield = 2,
			block_ranged = 1,
			{ "special_type", {
				steadfast = 1
			} }
		}
	else
		H.wml_error(string.format("invalid type= key in [create_armor] (%s)", atype))
	end
	wml.variables[var] = finalAdjust(armor)
end

function wesnoth.wml_actions.create_armor(args)
	local atype = string.match(args.type, "[^%s]+") or H.wml_error("[create_armor] requires a type= key")
	local rank = args.rank or 0
	local attr = string.match(args.attribute or "none", "[^%s]+")
	local var = string.match(args.variable, "[^%s]+") or H.wml_error("[create_armor] requires a variable= key")

	createArmor(atype, rank, attr, var)
end

function wesnoth.wml_actions.drop_item(cfg)
	local x = cfg.x or H.wml_error("[drop_item] requires an x= key")
	local y = cfg.y or H.wml_error("[drop_item] requires a y= key")
	local var = cfg.from_variable
	local item_data
	if var then
		item_data = wml.variables[var]
	else
		item_data = wml.get_child(cfg, "item") or H.wml_error("[drop_item] requires either a from_variable= key or an [item] subtag")
		item_data = item_data.__shallow_parsed
	end

	if not item_data.undroppable or item_data.undroppable ~= 1 then
		local i = wml.variables[string.format("ground.x%d.y%d.items.length", x, y)]
		if item_data.category == "gold" then
		item_data.amount = tonumber(item_data.amount) or 0
		if item_data.amount > 0 then
			for j = 0, i - 1 do
				if wml.variables[string.format("ground.x%d.y%d.items[%d].category", x, y, j)] == "gold" then
					local old_image = wml.variables[string.format("ground.x%d.y%d.items[%d].ground_icon", x, y, j)]
					item_data.amount = item_data.amount + wml.variables[string.format("ground.x%d.y%d.items[%d].amount", x, y, j)]
					wml.fire("remove_item", {
						x = x,
						y = y,
						image = string.format("items/%s.png", old_image)
					})
					wml.variables[string.format("ground.x%d.y%d.items[%d]", x, y, j)] = nil
					break
				end
			end
			if item_data.amount < 26 then
				item_data.ground_icon = "gold-coins-small"
				item_data.icon = "icons/gold-small"
			elseif item_data.amount < 76 then
				item_data.ground_icon = "gold-coins-medium"
				item_data.icon = "icons/gold-medium"
			else
				item_data.ground_icon = "gold-coins-large"
				item_data.icon = "icons/gold-large"
			end
			item_data.description = string.format("%d gold", item_data.amount)
		end
		end
		if item_data.ground_icon then
			wml.fire("item", {
				x = x,
				y = y,
				image = string.format("items/%s.png", item_data.ground_icon),
				visible_in_fog = "no"
			})
			wml.variables[string.format("ground.x%d.y%d.items[%d]", x, y, i)] = item_data
		end
	end
end

function wesnoth.wml_actions.item_cleanup(cfg)
	local x = cfg.x or H.wml_error("[item_cleanup] requires an x= key")
	local y = cfg.y or H.wml_error("[item_cleanup] requires a y= key")
	local ix = cfg.index
	x = tonumber(x)
	y = tonumber(y)
	if type(ix) ~= "number" then
		ix = -1
	end
	if ix == -1 then
		wml.variables[string.format("ground.x%d.y%d.items", x, y)] = nil
	else
		wml.variables[string.format("ground.x%d.y%d.items[%d]", x, y, ix)] = nil
	end
	wml.fire("remove_item", {
		x = x,
		y = y
	})
	local e = wml.variables[string.format("ground.x%d.y%d.exit.image", x, y)]
	if e then
		wml.fire("item", {
			x = x,
			y = y,
			image = e,
			visible_in_fog = "yes"
		})
	end
	local g = wml.variables[string.format("ground.x%d.y%d", x, y)]
	if g and g[1] then
		for i = 1, #g do
			if g[i][1] == "items" and g[i][2].ground_icon then
				wml.fire("item", {
					x = x,
					y = y,
					image = string.format("items/%s.png", g[i][2].ground_icon),
					visible_in_fog = "no"
				})
			end
		end
	else
		wml.variables[string.format("ground.x%d.y%d", x, y)] = nil
		g = wml.variables[string.format("ground.x%d", x)]
		if g and not g[1] then
			wml.variables[string.format("ground.x%d", x)] = nil
		end
	end
end

local function ench_stat(ench, stat)
	if ench then
		return "<span color='#11d116'>" .. stat .."</span>"
	else
		return stat
	end
end

local function array_contains(arr, val)
	local i
	for i = 1, #arr do
		if arr[i] == val then
			return true
		end
	end
	return false
end

-- [describe_item]
--     item - name of the variable containing the item
--     dest - name a variable to store the result in
--     unit - for weapons, calculate adjusted damage/strikes for unit
--     mode - either "replace" or "append", as with [set_variables], but does
--            not support insert or merge. Default value is "replace".
-- [/describe_item]
-- TODO: call eval_item() now instaed of looking up the information ourselves?
function wesnoth.wml_actions.describe_item(cfg)
	local item_var = cfg.item or H.wml_error("[describe_item] requires an item= key")
	local dest  = cfg.dest or H.wml_error("[describe_item] requires a dest= key")
	local unit_var = cfg.unit
	local mode = cfg.mode or "replace"
	local wml_item = wesnoth.get_variable(item_var) or H.wml_error("cannot find variable " .. item_var)
	local item = wml2lua_table(wml_item)
-- 	local ench = wesnoth.get_variable(item_var .. ".enchantments")
	local ench = item.enchantments and item.enchantments[1]
	local ench_stats = ench and item.enchantments[1].stats and item.enchantments[1].stats[1] or nil --  wesnoth.get_variable(item_var .. ".enchantments.stats")
	local cat  = item.category or "(category missing)" -- this is the case for some items (undroppable only?)
	local desc = item.description or item.name or "(description missing)"
	local name = item.name
	local icon = item.icon
	local arch_cat, slot
	local i, j
	local tranditional_stats = wesnoth.get_variable("opts.trad_stats")
	if tranditional_stats == nil then tranditional_stats = true end

	desc = ench_stat(ench and ench.power > 0, desc)

	if cat == "(category missing)" then
		if item.range == "melee" then
			cat = "melee_weapon"
		elseif item.range == "ranged" then
			cat = "ranged_weapon"
		elseif name == "clothes" or icon == "armor/tunic" then
			cat = "torso_armor"
		elseif name == "pants_shoes" or name == "loincloth" or icon == "armor/shoes" then
			cat = "legs_armor"
		elseif icon == "armor/head" or icon == "armor/elf-head" or icon == "armor/troll-head" then
			cat = "head_armor"
		elseif icon == "categories/armor-arms" then
			cat = "shield"
		else
			std_print(dump_value(wml_item, "bad_item", "", "  ", 24) .. "\n")
			H.wml_error("category missing and could not determine from other properties")
		end
	end
-- 	std_print(wml.tostring(item))
-- 	std_print(dump_value(item, "item", "", "  ", 24) .. "\n<small><small>")

	if cat == "shield" then
		arch_cat = "armor"
		slot     = "shield"
	else
		arch_cat = cat:split("_")[2]
		slot     = cat:split("_")[1]
	end

	local futile = {
		arcane	= 0,
		blade	= 0,
		fire	= 0,
		cold	= 0,
		impact	= 0,
		pierce	= 0
	}

	local defense_adjust = item.terrain and item.terrain[1].flat and item.terrain[1].flat[1].defense or 0
-- 	local resistance = wesnoth.get_variable(item_var .. ".resistance") or futile
	local resistance = item.resistance and item.resistance[1] or futile

-- 	local function ench_stat(stat_name, stat)
-- 		stat = stat or item[stat_name]
-- 		if ench and ench[stat_name] and ench[stat_name] ~= 0 and ench[stat_name] ~= "" then
-- 			return "<span foreground='#11d116'>" .. stat .."</span>"
-- 		else
-- 			return stat
-- 		end
-- 	end

	local function item_ench_stat(stat_name, stat)
		stat = stat or item[stat_name]
		if ench_stats then
			local ench_val = ench_stats[stat_name]
			if ench_val and not (ench_val == 0 or ench_val == "") then
				return ench_stat(true, stat)
			end
		end
		return tostring(stat)
	end

	if arch_cat == "weapon" then
		icon = "attacks/" .. item.icon
		local adjusted = ""

		if unit_var then
			local unit = wesnoth.units.get(wml.variables[unit_var .. ".id"]) or wml.variables[unit_var] or
						 H.wml_error("[describe_item] can't find unit " .. unit_var)
			local attack = get_attack_basics_light(unit, wml_item)
			adjusted = string.format(", Adjusted: (%d-%d)", attack.damage, attack.number)
		end

		local specials = ""
		if ench_stats then
			local i
			local ignore = {
				"arcane", "cold", "fire", "damage", "number"
			}
			local delim = false
			for k, v in pairs(ench_stats) do
				if not array_contains(ignore, k) then
					local str = k
					if str == "chance_to_hit" then
						str = "+" .. tostring(v) .. " to hit"
					elseif v ~= 1 then
						str = "+" .. tostring(v) .. " " .. str
					end
					specials = specials .. (delim and ", " or "") .. ench_stat(true, str)
					delim = true
				end
			end
		end

		local level_rank = ""
		if item.rank then
			-- we don't save these for undroppable
			level_rank = string.format("(%s/%s)", item.rank, item.level)
		end

		desc = string.format(
			"%s <small><small>%s\n" ..
			"Class: %s%s</small>\n" ..
			"Base: (%s-%s)%s %s\n" ..
			"<small>%s%s%s</small></small>",
			desc, level_rank,
			item.class_description, (item.evade_description or ""),
			item_ench_stat("damage"), item_ench_stat("number"),
			adjusted, ench_stat(ench and ench.branded, item.type),
			specials, (specials ~= "" and item.special ~= "" and ", " or ""), item.special
		)


	elseif arch_cat == "armor" then
		desc = desc .. "<small><small>\n"

-- 		std_print(dump_value(cfg, "describe_item"))
-- 		std_print(dump_value(resistance, "item.resistance", "", "  ", 24) .. "\n")
-- 		std_print(dump_value(resistance.blade, "item.resistance.blade", "", "  ", 24) .. "\n")

		-- text - translatable text
		-- name - common variable name
		-- val_cont - the value or a container that has it by name
		local function gen(text, name, val_cont)
			local value
			if val_cont == nil then
				value = 0
			elseif type(val_cont) == "table" then
				value = val_cont[name] or 0
				if type(value) == "table" then
					std_print("\n" .. dump_lua_value({name, val_cont, value}, "whoops"))
					H.wml_error("whoops")
				end
			else
				value = tonumber(val_cont) or 0
			end

			return {
				text,
				value,
				ench_stats and ench_stats[name] or 0,
				name
			}
		end

-- 		local flat_terrain = item.terrain and item.terrain[1].flat and item.terrain[1].flat[1] or nil
		local defense_adjust = item.terrain and item.terrain[1].flat and
			  item.terrain[1].flat[1] and -item.terrain[1].flat[1].defense or 0
		local stats = {
			gen(_"arcane",		"arcane",			resistance),
			gen(_"blade",		"blade",			resistance),
			gen(_"fire",		"fire",				resistance),
			gen(_"cold",		"cold",				resistance),
			gen(_"impact",		"impact",			resistance),
			gen(_"pierce",		"pierce",			resistance),
			gen(_"magic adj",	"magic_adjust",		item),
			gen(_"ranged adj",	"ranged_adjust",	item),
			gen(_"evade adj",	"evade_adjust",		item),
			gen(_"def adj",		"defense_adjust",	defense_adjust + (item.terrain_recoup or 0))
-- 			gen(_"def adj",		"terrain_recoup",	item)
		}

		-- Encoding of what is tranditionally displayed for each item type,
		-- matching what an item can have by default. Since item enchantment,
		-- however, this can be changed now. Still we'll only a stat for an
		-- armor slot that's non-tranditional if it's been magically modified.
		local nomrally_show_stat = {
			-- Slot		show	show	show	show	show	show
			--			res		magic	ranged	evade	defense	terrain
			--					adjust	adjust	adjust	adjust	recoup
			melee	 = {0,		0,		0,		1,		0,		0},
			ranged	 = {0,		0,		0,		0,		0,		0},
			shield	 = {0,		1,		1,		1,		0,		1},
			head	 = {1,		0,		1,		1,		0,		0},
			torso	 = {1,		1,		0,		1,		1,		0},
			legs	 = {1,		1,		0,		1,		1,		0},
		}

-- 		-- Convert to boolean
-- 		for k, v in pairs(nomrally_show_stat) do
-- 			for i = 1, #nomrally_show_stat[k] do
-- 				nomrally_show_stat[k][i] = nomrally_show_stat[k][i] == 1
-- 			end
-- 		end
-- 		local traditional_order = {
-- 			-- Slot		magic	ranged	evade	defense	terrain
-- 			--			adjust	adjust	adjust	adjust	recoup
-- 			shield	 = {1,		1,		1,		0,		1},
-- 			head	 = {0,		1,		1,		0,		0},
-- 			torso	 = {1,		0,		1,		1,		0},
-- 			legs	 = {1,		0,		1,		1,		0},
-- 		}
-- 		if slot == "torso" then
-- 			std_print("\n" .. dump_lua_value({
-- 				item_var		= item_var,
-- 				cat				= cat,
-- 				arch_cat		= arch_cat,
-- 				slot			= slot,
-- 				nomrally_show	= nomrally_show_stat[slot],
-- 				item			= item,
-- 				stats			= stats,
-- 				tests = {
-- 					type(item.terrain),
-- 					item.terrain or "no",
-- 					type(item.terrain[1]),
-- 					item.terrain[1] or "no",
-- 					item.terrain[1] and item.terrain[1].flat or "no",
-- 					item.terrain and item.terrain[1].flat and item.terrain[1].flat[1].defense or "no"
-- 				}
-- 			}, "debug_stuff") .. "\n")
-- 		end

-- 		local fuck =
		local delimit = false
		local needcr = false
		for i = 1, #stats do
			-- We lump all resistances together into stat category 1
			local stat_cat = i < 7 and 1 or i - 5
			local normally_show = nomrally_show_stat[slot][stat_cat] > 0 and tranditional_stats
			local have_stat = stats[i][2] and stats[i][2] ~= 0
			local show = normally_show or have_stat

			if slot == "torso" then
-- 				std_print(dump_lua_value({
-- 					stat			= i,
-- 					slot			= slot,
-- 					stat_cat		= stat_cat,
-- 					stat_name		= tostring(stats[i][1]),
-- 					show_from_table = nomrally_show_stat[slot][stat_cat],
-- 					inverted		= not nomrally_show_stat[slot][stat_cat],
-- 					table_again		= nomrally_show_stat[slot],
-- 					normally_show	= normally_show,
-- 					have_stat		= have_stat,
-- 					show			= show,
-- 					defense_adjust	= defense_adjust
-- 				}, "stuff", "  "))
			end

			if show then
				local stat
				-- These stats are clasically either negative or zero, but this can change after
				-- enchantment.
				if have_stat then
					stat = (i > 6 and stats[i][2] > 0 and "+" or "") .. tostring(stats[i][2]) .. "% "
				else
					stat = "0% "
				end
				-- If this stat was enchanted, then make it purdy
				stat = ench_stat(stats[i][3] and stats[i][3] ~= 0, stat)
				if needcr then
					desc = desc .. "\n"
					needcr = false
					delimit = false
				end
				desc = desc .. (delimit and ", " or "") .. stat .. stats[i][1]
				delimit = true
			end
			if i == 6 and delimit then
				needcr = true
			end
		end
		desc = desc .. "</small></small>"
	else
		-- For other items there _should_ be nothing else to do...
	end
	local result = wml.parsed(cfg)
	result.item = nil
	result.name = nil
	result.mode = nil
	result.image = icon .. ".png"
	result.label = desc

	if mode == "replace" then
		wesnoth.set_variable(dest, result)
	elseif mode == "append" then
		local value = wml.array_access.get(dest) or {}
		table.insert(value, result)
		wml.array_access.set(dest, value)
	else
		H.wml_error("[describe_item] invalid mode; must be either 'replace' or 'append'")
	end
end

function wesnoth.wml_conditionals.is_near_loot(cfg)
	local x = cfg.x or H.wml_error("[is_near_loot] expects an x= attribute")
	local y = cfg.y or H.wml_error("[is_near_loot] expects a y= attribute")
	local r = cfg.radius and tonumber(cfg.radius) or 1
	local locs = wesnoth.map.get_hexes_in_radius(x, y, r) or {}
	table.insert(locs, {x, y})

	for i,loc in ipairs(locs) do
		local var = string.format("ground.x%d.y%d.items.length", loc[1], loc[2])
		local items = wml.variables[var]
		if items and items > 0 then
			return true
		end
-- 		std_print("var = " .. var .. ", #items = " .. (items and tostring(#items) or "nil") .. (items and dump_lua_value(items, "items") or "items = nil"))
	end
	return false
end

loot_menu = {
	show	= false,
	x		= 0,
	y		= 0,
	unit_id	= nil,
	radius	= 0
}


local loot_msgs = constipate({
	_"",
	_"",
	_"Pick up %d gold",
	_"Pick up %d gold nearby",
	_"Pick up %d items",
	_"Pick up %d items nearby",
	_"Pick up %d gold and %d items",
	_"Pick up %d gold and %d items nearby",
	_"Pick up %s",
	_"Pick up %s nearby",
	_"Pick up %d gold and %s",
	_"Pick up %d gold and %s nearby"
})

function wesnoth.wml_conditionals.show_loot_menu(cfg)
	local x = cfg.x or werr("[show_loot_menu] requires x attribute")
	local y = cfg.y or werr("[show_loot_menu] requires y attribute")
-- 	local id = cfg.x or werr("[show_loot_menu] requires id attribute")

	if not (loot_menu.show and loot_menu.x == x and loot_menu.y == y) then
-- 		std_print(dump_lua_value({
-- 				loot_menu	= loot_menu,
-- 				x			= x,
-- 				y			= y,
-- 				result		= false,
-- 			},
-- 			"show_loot_menu"
-- 		))
		return false
	end

	local unit = wesnoth.units.get(x, y)
	if unit.id ~= loot_menu.unit_id then
		std_print(string.format("Exepcted unit %s at x, y, found %s"), loot_menu.unit_id, x, y, unit.id)
		return false
	end
-- 	std_print(dump_lua_value({
-- 			loot_menu	= loot_menu,
-- 			x			= x,
-- 			y			= y,
-- 			unit_id		= unit.id,
-- 			result		= true,
-- 		},
-- 		"show_loot_menu"
-- 	))
	return true
end

function update_loot_menu(x, y)
	loot_menu.show = false

	local unit = wesnoth.units.get(x, y)
	if not unit then
-- 		std_print(string.format("hide none, %d, %d", x, y))
		return
	end

	if unit.type == "WBD Unknown Adventurer" then
-- 		std_print(string.format("hide chrysalis, %d, %d", x, y))
		return
	end

-- 	std_print(string.format("hide %s checking... %d, %d", unit.name, x, y))
	local total_actions = tonumber(unit.attacks_left) + tonumber(unit.variables.simple_action)
-- 	tonumber(unit.moves)
	if total_actions == 0 then
-- 		std_print(string.format("hide %s no actions %d, %d", unit.name, x, y))
		return
	end

	local i, j, loc
	local nearby_items
	local is_safe = checkSafety(x, y) and
					unit.moves >= unit.max_moves and
					total_actions > 1
	loot_menu = {
		show	= false,
		x		= x,
		y		= y,
		unit_id	= unit.id,
		radius	= is_safe and 1 or 0
	}

	local gold, nitems = 0, 0
	local nearby = false
	local last_item

	if x < 1 or y < 1 or x > 500 or y > 500 then return end
-- 	std_print(dump_lua_value(unit, "unit"))
-- 	if not unit or not unit.canrecruit then return end
	local locs = {}
	if is_safe then
		locs = wesnoth.map.get_hexes_in_radius(x, y, loot_menu.radius)
	end

	table.insert(locs, {x, y})
-- 	std_print(dump_lua_value(locs, "locs"))

	for i,loc in ipairs(locs) do
		local items_var = string.format("ground.x%d.y%d.items", loc[1], loc[2])
		local count = wml.variables[items_var .. ".length"]
		local items = wml.array_access.get(items_var)
		local underfoot = x == loc[1] and y == loc[2]
		if count and count > 0 then
-- 			std_print(dump_lua_value({items_var = items_var, count = count, items = items}, "item_info"))
			for k, v in pairs(items) do
				local item = v
-- 				std_print(dump_lua_value({k = k, v = v, cat = v.category}))
-- 				local var = items .. "[" .. tostring(j) .. "]"
-- 				local item = wml.parsed(wml.variables[var])
-- 				local item = items[j]
-- 				std_print(dump_lua_value(item, items_var .. "[" .. tostring(j) .. "]"))
				if item and item.category then
					if not underfoot then
						nearby = true
					end
					if item.category == "gold" then
						gold = gold + item.amount
-- 						std_print(dump_lua_value(gold, "gold"))
					else
						nitems = nitems + 1
						last_item = item
-- 						std_print(dump_lua_value(nitems, "nitems"))
					end
				end
			end
		end
-- 		std_print("var = " .. var .. ", #items = " .. (items and tostring(#items) or "nil") .. (items and dump_lua_value(items, "items") or "items = nil"))
	end

	if gold + nitems == 0 then
-- 		std_print(string.format("hide %s nothing in range (%d) %d, %d",
-- 				  unit.name, loot_menu.radius, x, y))
		return
	end
-- 	std_print(string.format("show %s (%d) %d, %d", unit.name, loot_menu.radius, x, y))
	loot_menu.show = true
-- 	wml.variables["show_loot_menu"] = true

	local msgs_index = 1 +
					   (nearby and 1 or 0) +
					   (gold > 0 and 2 or 0) +
					   (nitems == 0 and 0 or nitems > 1 and 4 or 8)
	local fmt = loot_msgs[msgs_index]

	if msgs_index < 5 then
		nearby_items = string.format(fmt, gold)
	elseif msgs_index < 7 then
		nearby_items = string.format(fmt, nitems)
	elseif msgs_index < 9 then
		nearby_items = string.format(fmt, gold, nitems)
	else
		-- goddamn usables
		local desc = last_item.description:split("\n")[1]
		if string.sub(desc, -1) == ":" then
			desc = string.sub(desc, 1, -2)
		end

		if msgs_index < 11 then
			nearby_items = string.format(fmt, desc)
		else
			nearby_items = string.format(fmt, gold, desc)
		end
	end
-- 	std_print("nearby_items: " .. nearby_items)
-- 	std_print(dump_lua_value(nearby_items, "nearby_items"))

	if nearby_items then
		wml.variables.menu = {}
		wml.variables.loot_radius = loot_menu.radius
		wml.variables.nearby_items = nearby_items
		wesnoth.fire_event("setup_loot_menu", {x, y})
		-- Wesnoth 1.17?
-- 		wesnoth.game_events.fire("setup_loot_menu", {x, y})
	end
end

if wesnoth.current_version() < wesnoth.version(1, 17, 22) then
	wesnoth.game_events.on_mouse_move = function(x, y)
-- 		std_print(dump_lua_value({x = x, y = y}, "on_mouse_move"))
		update_loot_menu(x, y)
	end
else
	wesnoth.game_events.on_mouse_button = function(x, y, button, event)
		-- std_print(string.format("on_mouse_button %d,%d %s %s", x, y, button, event))
		if button == "right" and event == "click" then
			update_loot_menu(x, y)
		end
		return false
	end
end
