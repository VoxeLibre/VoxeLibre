local ARMOR_INIT_DELAY = 1
local ARMOR_INIT_TIMES = 1
local ARMOR_BONES_DELAY = 1

local skin_mod = nil

local modpath = minetest.get_modpath(minetest.get_current_modname())

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
	last_damage_types = {},
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

function armor.on_armor_use(itemstack, user, pointed_thing)
	if not user or user:is_player() == false then
		return itemstack
	end

	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end
	end

	local name, player_inv, armor_inv = armor:get_valid_player(user, "[on_armor_use]")
	if not name then
		return itemstack
	end

	local def = itemstack:get_definition()
	local slot
	if def.groups and def.groups.armor_head then
		slot = 2
	elseif def.groups and def.groups.armor_torso then
		slot = 3
	elseif def.groups and def.groups.armor_legs then
		slot = 4
	elseif def.groups and def.groups.armor_feet then
		slot = 5
	end

	if slot then
		local itemstack_single = ItemStack(itemstack)
		itemstack_single:set_count(1)
		local itemstack_slot = armor_inv:get_stack("armor", slot)
		if itemstack_slot:is_empty() then
			armor_inv:set_stack("armor", slot, itemstack_single)
			player_inv:set_stack("armor", slot, itemstack_single)
			armor:set_player_armor(user)
			armor:update_inventory(user)
			armor:play_equip_sound(itemstack_single, user)
			itemstack:take_item()
		elseif itemstack:get_count() <= 1 and not mcl_enchanting.has_enchantment(itemstack_slot, "curse_of_binding") then
			armor_inv:set_stack("armor", slot, itemstack_single)
			player_inv:set_stack("armor", slot, itemstack_single)
			armor:set_player_armor(user)
			armor:update_inventory(user)
			armor:play_equip_sound(itemstack_single, user)
			itemstack = ItemStack(itemstack_slot)
		end
	end

	return itemstack
end

armor.def = {
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
	local armor_texture = "blank.png"
	local armor_level = 0
	local mcl_armor_points = 0
	local items = 0
	local elements = {}
	local textures = {}
	local physics_o = {speed=1,gravity=1,jump=1}
	local material = {type=nil, count=1}
	local preview
	for _,v in ipairs(self.elements) do
		elements[v] = false
	end
	for i=1, 6 do
		local stack = player_inv:get_stack("armor", i)
		local item = stack:get_name()
		if minetest.registered_aliases[item] then
			item = minetest.registered_aliases[item]
		end
		if stack:get_count() == 1 then
			local def = stack:get_definition()
			for k, v in pairs(elements) do
				if v == false then
					local level = def.groups["armor_"..k]
					if level then
						local texture = def.texture or item:gsub("%:", "_")
						local enchanted_addition = (mcl_enchanting.is_enchanted(item) and mcl_enchanting.overlay or "")
						table.insert(textures, "("..texture..".png"..enchanted_addition..")")
						preview = "(player.png^[opacity:0^"..texture.."_preview.png"..enchanted_addition..")"..(preview and "^"..preview or "")
						armor_level = armor_level + level
						items = items + 1
						mcl_armor_points = mcl_armor_points + (def.groups["mcl_armor_points"] or 0)
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
	preview = (armor:get_preview(name) or "character_preview.png")..(preview and "^"..preview or "")
	if minetest.get_modpath("shields") then
		armor_level = armor_level * 0.9
	end
	if material.type and material.count == #self.elements then
		armor_level = armor_level * 1.1
	end
	if #textures > 0 then
		armor_texture = table.concat(textures, "^")
	end
	local armor_groups = player:get_armor_groups()
	armor_groups.fleshy = 100
	armor_groups.level = nil
	if armor_level > 0 then
		armor_groups.level = math.floor(armor_level / 20)
		armor_groups.fleshy = 100 - armor_level
	end
	player:set_armor_groups(armor_groups)
	-- Physics override intentionally removed because of possible conflicts
	self.textures[name].armor = armor_texture
	self.textures[name].preview = preview
	self.def[name].count = items
	self.def[name].level = armor_level
	self.def[name].heal = mcl_armor_points
	self.def[name].jump = physics_o.jump
	self.def[name].speed = physics_o.speed
	self.def[name].gravity = physics_o.gravity
	self:update_player_visuals(player)
end

armor.update_armor = function(self, player)
	-- Legacy support: Called when armor levels are changed
	-- Other mods can hook on to this function, see hud mod for example
end

armor.get_armor_points = function(self, player)
	local name, player_inv, armor_inv = armor:get_valid_player(player, "[get_armor_points]")
	if not name then
		return nil
	end
	local pts = 0
	for i=1, 6 do
		local stack = player_inv:get_stack("armor", i)
		if stack:get_count() > 0 then
			local p = minetest.get_item_group(stack:get_name(), "mcl_armor_points")
			if p then
				pts = pts + p
			end
		end
	end
	return pts
end

-- Returns a change factor for a mob's view_range for the given player
-- or nil, if there's no change. Certain armors (like mob heads) can
-- affect the view range of mobs.
armor.get_mob_view_range_factor = function(self, player, mob)
	local name, player_inv, armor_inv = armor:get_valid_player(player, "[get_mob_view_range_factor]")
	if not name then
		return
	end
	local factor
	for i=1, 6 do
		local stack = player_inv:get_stack("armor", i)
		if stack:get_count() > 0 then
			local def = stack:get_definition()
			if def._mcl_armor_mob_range_mob == mob then
				if not factor then
					factor = def._mcl_armor_mob_range_factor
				elseif factor == 0 then
					return 0
				else
					factor = factor * def._mcl_armor_mob_range_factor
				end
			end
		end
	end
	return factor
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
		minetest.log("error", "mcl_armor: Player texture["..name.."] is nil [get_armor_formspec]")
		return ""
	end
	if not armor.def[name] then
		minetest.log("error", "mcl_armor: Armor def["..name.."] is nil [get_armor_formspec]")
		return ""
	end
	local formspec = armor.formspec.."list[detached:"..name.."_armor;armor;0,1;2,3;]"
	formspec = formspec:gsub("armor_preview", armor.textures[name].preview)
	formspec = formspec:gsub("armor_level", armor.def[name].level)
	formspec = formspec:gsub("mcl_armor_points", armor.def[name].heal)
	return formspec
end

armor.update_inventory = function(self, player)
end

armor.get_valid_player = function(self, player, msg)
	msg = msg or ""
	if not player then
		minetest.log("error", "mcl_armor: Player reference is nil "..msg)
		return
	end
	local name = player:get_player_name()
	if not name then
		minetest.log("error", "mcl_armor: Player name is nil "..msg)
		return
	end
	local pos = player:get_pos()
	local player_inv = player:get_inventory()
	local armor_inv = minetest.get_inventory({type="detached", name=name.."_armor"})
	if not pos then
		minetest.log("error", "mcl_armor: Player position is nil "..msg)
		return
	elseif not player_inv then
		minetest.log("error", "mcl_armor: Player inventory is nil "..msg)
		return
	elseif not armor_inv then
		minetest.log("error", "mcl_armor: Detached armor inventory is nil "..msg)
		return
	end
	return name, player_inv, armor_inv, pos
end

armor.play_equip_sound = function(self, stack, player, pos, unequip)
	local def = stack:get_definition()
	local estr = "equip"
	if unequip then
		estr = "unequip"
	end
	local snd = def.sounds and def.sounds["_mcl_armor_"..estr]
	if not snd then
		-- Fallback sound
		snd = { name = "mcl_armor_"..estr.."_generic" }
	end
	if snd then
		local dist = 8
		if pos then
			dist = 16
		end
		minetest.sound_play(snd, {object=player, pos=pos, gain=0.5, max_hear_distance=dist}, true)
	end
end

-- Register Player Model

mcl_player.player_register_model("mcl_armor_character.b3d", {
	animation_speed = 30,
	textures = {
		armor.default_skin..".png",
		"blank.png",
		"blank.png",
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
	mcl_player.player_set_model(player, "mcl_armor_character.b3d")
	local name = player:get_player_name()
	local player_inv = player:get_inventory()
	local armor_inv = minetest.create_detached_inventory(name.."_armor", {
		on_put = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, stack)
			armor:set_player_armor(player)
			armor:update_inventory(player)
			armor:play_equip_sound(stack, player)
		end,
		on_take = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, nil)
			armor:set_player_armor(player)
			armor:update_inventory(player)
			armor:play_equip_sound(stack, player, nil, true)
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			local plaver_inv = player:get_inventory()
			local stack = inv:get_stack(to_list, to_index)
			player_inv:set_stack(to_list, to_index, stack)
			player_inv:set_stack(from_list, from_index, nil)
			armor:set_player_armor(player)
			armor:update_inventory(player)
			armor:play_equip_sound(stack, player)
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
			if mcl_enchanting.has_enchantment(stack, "curse_of_binding") and not minetest.settings:get_bool("creative") then
				return 0
			end
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
		count = 0,
		level = 0,
		heal = 0,
		jump = 1,
		speed = 1,
		gravity = 1,
	}
	armor.textures[name] = {
		skin = armor.default_skin..".png",
		armor = "blank.png",
		wielditem = "blank.png",
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

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	local name, player_inv, armor_inv = armor:get_valid_player(player, "[on_hpchange]")
	if name and hp_change < 0 then
		local damage_type = armor.last_damage_types[name]
		armor.last_damage_types[name] = nil
		
		-- Armor doesn't protect from set_hp (commands like /kill),
		if reason.type == "set_hp" then
			return hp_change
		end
		
		local regular_reduction = reason.type ~= "drown" and reason.type ~= "fall"

		-- Account for potion effects (armor doesn't save the target)
		if reason.other == "poison" or reason.other == "harming" then
			return hp_change
		end

		local heal_max = 0
		local items = 0
		local armor_damage = math.max(1, math.floor(math.abs(hp_change)/4))
		
		local total_points = 0
		local total_toughness = 0
		local epf = 0
		local thorns_damage = 0
		local thorns_damage_regular = 0
		for i=1, 6 do
			local stack = player_inv:get_stack("armor", i)
			if stack:get_count() > 0 then
				local enchantments = mcl_enchanting.get_enchantments(stack)
				local pts = stack:get_definition().groups["mcl_armor_points"] or 0
				local tough = stack:get_definition().groups["mcl_armor_toughness"] or 0
				total_points = total_points + pts
				total_toughness = total_toughness + tough
				
				local protection_level = enchantments.protection or 0
				if protection_level > 0 then
					epf = epf + protection_level * 1
				end
				local blast_protection_level = enchantments.blast_protection or 0
				if blast_protection_level > 0 and damage_type == "explosion" then
					epf = epf + blast_protection_level * 2
				end
				local fire_protection_level = enchantments.fire_protection or 0
				if fire_protection_level > 0 and (damage_type == "burning" or damage_type == "fireball" or reason.type == "node_damage" and
					(reason.node == "mcl_fire:fire" or reason.node == "mcl_core:lava_source" or reason.node == "mcl_core:lava_flowing")) then
					epf = epf + fire_protection_level * 2
				end
				local projectile_protection_level = enchantments.projectile_protection or 0
				if projectile_protection_level and (damage_type == "projectile" or damage_type == "fireball") then
					epf = epf + projectile_protection_level * 2
				end
				local feather_falling_level = enchantments.feather_falling or 0
				if feather_falling_level and reason.type == "fall" then
					epf = epf + feather_falling_level * 3
				end
				
				local did_thorns_damage = false
				local thorns_level = enchantments.thorns or 0
				if thorns_level then
					if thorns_level > 10 then
						thorns_damage = thorns_damage + thorns_level - 10
						did_thorns_damage = true
					elseif thorns_damage_regular < 4 and thorns_level * 0.15 > math.random() then
						local thorns_damage_regular_new = math.min(4, thorns_damage_regular + math.random(4))
						thorns_damage = thorns_damage + thorns_damage_regular_new - thorns_damage_regular
						thorns_damage_regular = thorns_damage_regular_new
						did_thorns_damage = true
					end
				end
				
				-- Damage armor
				local use = stack:get_definition().groups["mcl_armor_uses"] or 0
				if use > 0 and regular_reduction then
					local unbreaking_level = enchantments.unbreaking or 0
					if unbreaking_level > 0 then
						use = use / (0.6 + 0.4 / (unbreaking_level + 1))
					end
					local wear = armor_damage * math.floor(65536/use)
					if did_thorns_damage then
						wear = wear * 3
					end
					stack:add_wear(wear)
				end

				local item = stack:get_name()
				armor_inv:set_stack("armor", i, stack)
				player_inv:set_stack("armor", i, stack)
				items = items + 1
				if stack:get_count() == 0 then
					armor:set_player_armor(player)
					armor:update_inventory(player)
				end
			end
		end
		local damage = math.abs(hp_change)
		
		if regular_reduction then
			-- Damage calculation formula (from <https://minecraft.gamepedia.com/Armor#Damage_protection>)
			damage = damage * (1 - math.min(20, math.max((total_points/5), total_points - damage / (2+(total_toughness/4)))) / 25)
		end
		damage = damage * (1 - (math.min(20, epf) / 25))
		damage = math.floor(damage+0.5)		
		
		if reason.type == "punch" and thorns_damage > 0 then
			local obj = reason.object
			if obj then
				local luaentity = obj:get_luaentity()
				if luaentity then
					local shooter = obj._shooter
					if shooter then
						obj = shooter
					end
				end
				obj:punch(player, 1.0, {
					full_punch_interval=1.0,
					damage_groups = {fleshy = thorns_damage},
				})
			end
		end
		
		hp_change = -math.abs(damage)

		armor.def[name].count = items
		armor:update_armor(player)
	end
	return hp_change
end, true)
