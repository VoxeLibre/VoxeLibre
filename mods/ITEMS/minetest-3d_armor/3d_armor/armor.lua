ARMOR_INIT_DELAY = 1
ARMOR_INIT_TIMES = 1
ARMOR_BONES_DELAY = 1
ARMOR_UPDATE_TIME = 1
ARMOR_DROP = minetest.get_modpath("bones") ~= nil
ARMOR_DESTROY = false
ARMOR_LEVEL_MULTIPLIER = 1
ARMOR_HEAL_MULTIPLIER = 1
ARMOR_RADIATION_MULTIPLIER = 1
ARMOR_MATERIALS = {
	wood = "group:wood",
	cactus = "mcl_core:cactus",
	iron = "mcl_core:iron_ingot",
	bronze = "mcl_core:bronze_ingot",
	diamond = "mcl_core:diamond",
	gold = "mcl_core:gold_ingot",
	mithril = "moreores:mithril_ingot",
	crystal = "ethereal:crystal_ingot",
}
ARMOR_FIRE_PROTECT = minetest.get_modpath("ethereal") ~= nil
ARMOR_FIRE_NODES = {
	{"mcl_core:lava_source",     5, 8},
	{"mcl_core:lava_flowing",    5, 8},
	{"fire:basic_flame",        3, 4},
	{"fire:permanent_flame",    3, 4},
	{"ethereal:crystal_spike",  2, 1},
	{"ethereal:fire_flower",    2, 1},
	{"mcl_torches:torch",       1, 1},
}

local skin_mod = nil

local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()
local input = io.open(modpath.."/armor.conf", "r")
if input then
	dofile(modpath.."/armor.conf")
	input:close()
	input = nil
end
input = io.open(worldpath.."/armor.conf", "r")
if input then
	dofile(worldpath.."/armor.conf")
	input:close()
	input = nil
end
if not minetest.get_modpath("moreores") then
	ARMOR_MATERIALS.mithril = nil
end
if not minetest.get_modpath("ethereal") then
	ARMOR_MATERIALS.crystal = nil
end

armor = {
	timer = 0,
	elements = {"head", "torso", "legs", "feet"},
	physics = {"jump","speed","gravity"},
	formspec = "size[8,8.5]image[2,0.75;2,4;armor_preview]"
		.."list[current_player;main;0,4.5;8,4;]"
		.."list[current_player;craft;4,1;3,3;]"
		.."list[current_player;craftpreview;7,2;1,1;]"
		.."listring[current_player;main]"
		.."listring[current_player;craft]",
	textures = {},
	default_skin = "character",
	version = "0.4.6",
}

if minetest.get_modpath("mcl_skins") then
	skin_mod = "mcl_skins"
elseif minetest.get_modpath("skins") then
	skin_mod = "skins"
elseif minetest.get_modpath("simple_skins") then
	skin_mod = "simple_skins"
elseif minetest.get_modpath("u_skins") then
	skin_mod = "u_skins"
elseif minetest.get_modpath("wardrobe") then
	skin_mod = "wardrobe"
end

armor.def = {
	state = 0,
	count = 0,
}

armor.update_player_visuals = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()
	if self.textures[name] then
		mcl_player.player_set_textures(player, {
			self.textures[name].skin,
			self.textures[name].armor,
			self.textures[name].wielditem,
		})
	end
end

armor.set_player_armor = function(self, player)
	local name, player_inv = armor:get_valid_player(player, "[set_player_armor]")
	if not name then
		return
	end
	local armor_texture = "3d_armor_trans.png"
	local armor_level = 0
	local armor_heal = 0
	local armor_fire = 0
	local armor_water = 0
	local armor_radiation = 0
	local state = 0
	local items = 0
	local elements = {}
	local textures = {}
	local physics_o = {speed=1,gravity=1,jump=1}
	local material = {type=nil, count=1}
	local preview = armor:get_preview(name) or "character_preview.png"
	for _,v in ipairs(self.elements) do
		elements[v] = false
	end
	for i=1, 6 do
		local stack = player_inv:get_stack("armor", i)
		local item = stack:get_name()
		if stack:get_count() == 1 then
			local def = stack:get_definition()
			for k, v in pairs(elements) do
				if v == false then
					local level = def.groups["armor_"..k]
					if level then
						local texture = def.texture or item:gsub("%:", "_")
						table.insert(textures, texture..".png")
						preview = preview.."^"..texture.."_preview.png"
						armor_level = armor_level + level
						state = state + stack:get_wear()
						items = items + 1
						armor_heal = armor_heal + (def.groups["armor_heal"] or 0)
						armor_fire = armor_fire + (def.groups["armor_fire"] or 0)
						armor_water = armor_water + (def.groups["armor_water"] or 0)
						armor_radiation = armor_radiation + (def.groups["armor_radiation"] or 0)
						for kk,vv in ipairs(self.physics) do
							local o_value = def.groups["physics_"..vv]
							if o_value then
								physics_o[vv] = physics_o[vv] + o_value
							end
						end
						local mat = string.match(item, "%:.+_(.+)$")
						if material.type then
							if material.type == mat then
								material.count = material.count + 1
							end
						else
							material.type = mat
						end
						elements[k] = true
					end
				end
			end
		end
	end
	if minetest.get_modpath("shields") then
		armor_level = armor_level * 0.9
	end
	if material.type and material.count == #self.elements then
		armor_level = armor_level * 1.1
	end
	armor_level = armor_level * ARMOR_LEVEL_MULTIPLIER
	armor_heal = armor_heal * ARMOR_HEAL_MULTIPLIER
	armor_radiation = armor_radiation * ARMOR_RADIATION_MULTIPLIER
	if #textures > 0 then
		armor_texture = table.concat(textures, "^")
	end
	local armor_groups = player:get_armor_groups()
	armor_groups.fleshy = 100
	armor_groups.level = nil
	armor_groups.radiation = nil
	if armor_level > 0 then
		armor_groups.level = math.floor(armor_level / 20)
		armor_groups.fleshy = 100 - armor_level
		armor_groups.radiation = 100 - armor_radiation
	end
	player:set_armor_groups(armor_groups)
	-- Physics override intentionally removed because of possible conflicts
	self.textures[name].armor = armor_texture
	self.textures[name].preview = preview
	self.def[name].state = state
	self.def[name].count = items
	self.def[name].level = armor_level
	self.def[name].heal = armor_heal
	self.def[name].jump = physics_o.jump
	self.def[name].speed = physics_o.speed
	self.def[name].gravity = physics_o.gravity
	self.def[name].fire = armor_fire
	self.def[name].water = armor_water
	self.def[name].radiation = armor_radiation
	self:update_player_visuals(player)
end

armor.update_armor = function(self, player)
	-- Legacy support: Called when armor levels are changed
	-- Other mods can hook on to this function, see hud mod for example 
end

armor.get_player_skin = function(self, name)
	local skin = nil
	if skin_mod == "mcl_skins" then
		skin = mcl_skins.skins[name]
	elseif skin_mod == "skins" or skin_mod == "simple_skins" then
		skin = skins.skins[name]
	elseif skin_mod == "u_skins" then
		skin = u_skins.u_skins[name]
	elseif skin_mod == "wardrobe" then
		skin = string.gsub(wardrobe.playerSkins[name], "%.png$","")
	end
	return skin or armor.default_skin
end

armor.get_preview = function(self, name)
	if skin_mod == "skins" then
		return armor:get_player_skin(name).."_preview.png"
	end
end

armor.get_armor_formspec = function(self, name)
	if not armor.textures[name] then
		minetest.log("error", "3d_armor: Player texture["..name.."] is nil [get_armor_formspec]")
		return ""
	end
	if not armor.def[name] then
		minetest.log("error", "3d_armor: Armor def["..name.."] is nil [get_armor_formspec]")
		return ""
	end
	local formspec = armor.formspec.."list[detached:"..name.."_armor;armor;0,1;2,3;]"
	formspec = formspec:gsub("armor_preview", armor.textures[name].preview)
	formspec = formspec:gsub("armor_level", armor.def[name].level)
	formspec = formspec:gsub("armor_heal", armor.def[name].heal)
	formspec = formspec:gsub("armor_fire", armor.def[name].fire)
	formspec = formspec:gsub("armor_radiation", armor.def[name].radiation)
	return formspec
end

armor.update_inventory = function(self, player)
end

armor.get_valid_player = function(self, player, msg)
	msg = msg or ""
	if not player then
		minetest.log("error", "3d_armor: Player reference is nil "..msg)
		return
	end
	local name = player:get_player_name()
	if not name then
		minetest.log("error", "3d_armor: Player name is nil "..msg)
		return
	end
	local pos = player:get_pos()
	local player_inv = player:get_inventory()
	local armor_inv = minetest.get_inventory({type="detached", name=name.."_armor"})
	if not pos then
		minetest.log("error", "3d_armor: Player position is nil "..msg)
		return
	elseif not player_inv then
		minetest.log("error", "3d_armor: Player inventory is nil "..msg)
		return
	elseif not armor_inv then
		minetest.log("error", "3d_armor: Detached armor inventory is nil "..msg)
		return
	end
	return name, player_inv, armor_inv, pos
end

-- Register Player Model

mcl_player.player_register_model("3d_armor_character.b3d", {
	animation_speed = 30,
	textures = {
		armor.default_skin..".png",
		"3d_armor_trans.png",
		"3d_armor_trans.png",
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
	},
})

-- Register Callbacks

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = armor:get_valid_player(player, "[on_player_receive_fields]")
	if not name then
		return
	end
	if fields.armor then
		return
	end
	for field, _ in pairs(fields) do
		if string.find(field, "skins_set") then
			minetest.after(0, function(name)
				local player = minetest.get_player_by_name(name)
				if not player then
					return
				end
				local skin = armor:get_player_skin(name)
				armor.textures[name].skin = skin..".png"
				armor:set_player_armor(player)
			end, player:get_player_name())
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	mcl_player.player_set_model(player, "3d_armor_character.b3d")
	local name = player:get_player_name()
	local player_inv = player:get_inventory()
	local armor_inv = minetest.create_detached_inventory(name.."_armor", {
		on_put = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, stack)
			armor:set_player_armor(player)
			armor:update_inventory(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, nil)
			armor:set_player_armor(player)
			armor:update_inventory(player)
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			local plaver_inv = player:get_inventory()
			local stack = inv:get_stack(to_list, to_index)
			player_inv:set_stack(to_list, to_index, stack)
			player_inv:set_stack(from_list, from_index, nil)
			armor:set_player_armor(player)
			armor:update_inventory(player)
		end,
		allow_put = function(inv, listname, index, stack, player)
			local iname = stack:get_name()
			local g
			local groupcheck
			if index == 2 then
				g = minetest.get_item_group(iname, "armor_head")
			elseif index == 3 then
				g = minetest.get_item_group(iname, "armor_torso")
			elseif index == 4 then
				g = minetest.get_item_group(iname, "armor_legs")
			elseif index == 5 then
				g = minetest.get_item_group(iname, "armor_feet")
			end
			-- Minor FIXME: If player attempts to place stack into occupied slot, this is rejected.
			-- It would be better if 1 item is placed in exchanged for the item in the slot.
			if g ~= 0 and g ~= nil and (inv:get_stack(listname, index):is_empty() or (inv:get_stack(listname, index):get_name() ~= stack:get_name()) and stack:get_count() <= 1) then
				return 1
			else
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
	}, name)
	armor_inv:set_size("armor", 6)
	player_inv:set_size("armor", 6)
	for i=1, 6 do
		local stack = player_inv:get_stack("armor", i)
		armor_inv:set_stack("armor", i, stack)
	end	
	armor.def[name] = {
		state = 0,
		count = 0,
		level = 0,
		heal = 0,
		jump = 1,
		speed = 1,
		gravity = 1,
		fire = 0,
		water = 0,
		radiation = 0,
	}
	armor.textures[name] = {
		skin = armor.default_skin..".png",
		armor = "3d_armor_trans.png",
		wielditem = "3d_armor_trans.png",
		preview = armor.default_skin.."_preview.png",
	}
	if skin_mod == "mcl_skins" then
		local skin = mcl_skins.skins[name]
		if skin then
			armor.textures[name].skin = skin..".png"
		end
	elseif skin_mod == "skins" then
		local skin = skins.skins[name]
		if skin and skins.get_type(skin) == skins.type.MODEL then
			armor.textures[name].skin = skin..".png"
		end
	elseif skin_mod == "simple_skins" then
		local skin = skins.skins[name]
		if skin then
			armor.textures[name].skin = skin..".png"
		end
	elseif skin_mod == "u_skins" then
		local skin = u_skins.u_skins[name]
		if skin and u_skins.get_type(skin) == u_skins.type.MODEL then
			armor.textures[name].skin = skin..".png"
		end
	elseif skin_mod == "wardrobe" then
		local skin = wardrobe.playerSkins[name]
		if skin then
			armor.textures[name].skin = skin
		end
	end
	if minetest.get_modpath("player_textures") then
		local filename = minetest.get_modpath("player_textures").."/textures/player_"..name
		local f = io.open(filename..".png")
		if f then
			f:close()
			armor.textures[name].skin = "player_"..name..".png"
		end
	end
	for i=1, ARMOR_INIT_TIMES do
		minetest.after(ARMOR_INIT_DELAY * i, function(name)
			local player = minetest.get_player_by_name(name)
			if not player then
				return
			end
			armor:set_player_armor(player)
		end, player:get_player_name())
	end
end)

if ARMOR_DROP == true or ARMOR_DESTROY == true then
	armor.drop_armor = function(pos, stack)
		local obj = minetest.add_item(pos, stack)
		if obj then
			obj:set_velocity({x=math.random(-1, 1), y=5, z=math.random(-1, 1)})
		end
	end
	minetest.register_on_dieplayer(function(player)
		local name, player_inv, armor_inv, pos = armor:get_valid_player(player, "[on_dieplayer]")
		if not name then
			return
		end
		local drop = {}
		for i=1, player_inv:get_size("armor") do
			local stack = armor_inv:get_stack("armor", i)
			if stack:get_count() > 0 then
				table.insert(drop, stack)
				armor_inv:set_stack("armor", i, nil)
				player_inv:set_stack("armor", i, nil)
			end
		end
		armor:set_player_armor(player)
		if ARMOR_DESTROY == false then
			minetest.after(ARMOR_BONES_DELAY, function(pos, drop)
				local node = minetest.get_node(vector.round(pos))
				if node then
					if node.name ~= "bones:bones" then
						pos.y = pos.y+1
						node = minetest.get_node(vector.round(pos))
						if node.name ~= "bones:bones" then
							minetest.log("warning", "Failed to add armor to bones node.")
							return
						end
					end
					local meta = minetest.get_meta(vector.round(pos))
					local owner = meta:get_string("owner")
					local inv = meta:get_inventory()
					for _,stack in ipairs(drop) do
						if name == owner and inv:room_for_item("main", stack) then
							inv:add_item("main", stack)
						else
							armor.drop_armor(pos, stack)
						end
					end
				else
					for _,stack in ipairs(drop) do
						armor.drop_armor(pos, stack)
					end
				end
			end, pos, drop)
		end
	end)
end

minetest.register_on_player_hpchange(function(player, hp_change)
	local name, player_inv, armor_inv = armor:get_valid_player(player, "[on_hpchange]")
	if name and hp_change < 0 then

		-- used for insta kill tools/commands like /kill (doesnt damage armor)
		if hp_change < -100 then
			return hp_change
		end

		local heal_max = 0
		local state = 0
		local items = 0
		for i=1, 6 do
			local stack = player_inv:get_stack("armor", i)
			if stack:get_count() > 0 then
				local use = stack:get_definition().groups["armor_use"] or 0
				local heal = stack:get_definition().groups["armor_heal"] or 0
				local item = stack:get_name()
				stack:add_wear(use)
				armor_inv:set_stack("armor", i, stack)
				player_inv:set_stack("armor", i, stack)
				state = state + stack:get_wear()
				items = items + 1
				if stack:get_count() == 0 then
					local desc = minetest.registered_items[item].description
					if desc then
						minetest.chat_send_player(name, "Your "..desc.." got destroyed!")
					end
					armor:set_player_armor(player)
					armor:update_inventory(player)
				end
				heal_max = heal_max + heal
			end
		end
		armor.def[name].state = state
		armor.def[name].count = items
		heal_max = heal_max * ARMOR_HEAL_MULTIPLIER
		if heal_max > math.random(100) then
			hp_change = 0
		end
		armor:update_armor(player)
	end
	return hp_change
end, true)

-- Fire Protection and water breating, added by TenPlus1

if ARMOR_FIRE_PROTECT == true then
	-- override hot nodes so they do not hurt player anywhere but mod
	for _, row in pairs(ARMOR_FIRE_NODES) do
		if minetest.registered_nodes[row[1]] then
			minetest.override_item(row[1], {damage_per_second = 0})
		end
	end
else
	print ("[3d_armor] Fire Nodes disabled")
end

minetest.register_globalstep(function(dtime)
	armor.timer = armor.timer + dtime
	if armor.timer < ARMOR_UPDATE_TIME then
		return
	end
	for _,player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local hp = player:get_hp()
		-- water breathing
		if name and armor.def[name].water > 0 then
			if player:get_breath() < 10 then
				player:set_breath(10)
			end
		end
		-- fire protection
		if ARMOR_FIRE_PROTECT == true
		and name and pos and hp then
			pos.y = pos.y + 1.4 -- head level
			local node_head = minetest.get_node(pos).name
			pos.y = pos.y - 1.2 -- feet level
			local node_feet = minetest.get_node(pos).name
			-- is player inside a hot node?
			for _, row in pairs(ARMOR_FIRE_NODES) do
				-- check fire protection, if not enough then get hurt
				if row[1] == node_head or row[1] == node_feet then
					if hp > 0 and armor.def[name].fire < row[2] then
						hp = hp - row[3] * ARMOR_UPDATE_TIME
						player:set_hp(hp)
						break
					end
				end
			end
		end
	end
	armor.timer = 0
end)
