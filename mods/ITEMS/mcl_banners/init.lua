-- Load shared stuff
dofile(minetest.get_modpath("mcl_banners").."/shared.lua")

-- Add pattern/emblazoning crafting recipes
dofile(minetest.get_modpath("mcl_banners").."/patterncraft.lua")

local node_sounds
if minetest.get_modpath("mcl_sounds") then
	node_sounds = mcl_sounds.node_sound_wood_defaults()
end

-- Helper function
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Overlay ratios (0-255)
local base_color_ratio = 224
local layer_ratio = 255

-- After destroying the standing banner node
local on_destruct_standing_banner = function(pos)
	-- Find this node's banner entity and make it drop as an item
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, v in ipairs(objects) do
		if v:get_entity_name() == "mcl_banners:standing_banner" then
			v:get_luaentity():_drop()
		end
	end
end

local make_banner_texture = function(base_color, layers)
	local colorize
	if mcl_banners.colors[base_color] then
		colorize = mcl_banners.colors[base_color][4]
	end
	if colorize then
		-- Base texture with base color
		local base = "(mcl_banners_banner_base.png^[mask:mcl_banners_base_inverted.png)^((mcl_banners_banner_base.png^[colorize:"..colorize..":"..base_color_ratio..")^[mask:mcl_banners_base.png)"

		-- Optional pattern layers
		if layers then
			local finished_banner = base
			for l=1, #layers do
				local layerinfo = layers[l]
				local pattern = "mcl_banners_" .. layerinfo.pattern .. ".png"
				local color = mcl_banners.colors[layerinfo.color][4]

				-- Generate layer texture
				local layer = "(("..pattern.."^[colorize:"..color..":"..layer_ratio..")^[mask:"..pattern..")"

				finished_banner = finished_banner .. "^" .. layer
			end
			return { finished_banner }
		end
		return { base }
	else
		return { "mcl_banners_banner_base.png" }
	end
end

-- Standing banner node.
-- This is an invisible node which is only used to destroy the banner entity.
-- All the important banner information (such as color) is stored in the entity.
-- It is used only used internally.
minetest.register_node("mcl_banners:standing_banner", {
	walkable = false,
	is_ground_content = false,
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "airlike",
	inventory_image = "mcl_banners_item_base.png",
	wield_image = "mcl_banners_item_base.png",
	tiles = { "blank.png" },
	selection_box = {type = "fixed", fixed= {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2} },
	groups = { deco_block = 1, attached_node = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1, },
	stack_max = 16,
	sounds = node_sounds,
	drop = "", -- Item drops are handled in entity code

	on_destruct = on_destruct_standing_banner,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 5,
})

for colorid, colortab in pairs(mcl_banners.colors) do
	local itemid = colortab[1]
	local desc = colortab[2]
	local wool = colortab[3]
	local colorize = colortab[4]

	local itemstring = "mcl_banners:banner_item_"..itemid
	local inv
	if colorize then
		inv = "mcl_banners_item_base.png^(mcl_banners_item_overlay.png^[colorize:"..colorize..")"
	else
		inv = "mcl_banners_item_base.png^mcl_banners_item_overlay.png"
	end

	-- Banner items.
	-- This is the player-visible banner item. It comes in 16 base colors.
	-- The multiple items are really only needed for the different item images.
	-- TODO: Combine the items into only 1 item.
	minetest.register_craftitem(itemstring, {
		description = desc,
		_doc_items_longdesc = "Banners are tall colorful decorative blocks. They can be placed on the floor. Banners can be emblazoned with a variety of patterns using a lot of dye in crafting.",
		_doc_items_usagehelp = "Use crafting to draw a pattern on top of the banner. Emblazoned banners can be emblazoned again to combine various patterns. You can draw up to 6 layers on a banner that way. Use a banner on a cauldron with water to wash off its top-most layer.",
		inventory_image = inv,
		wield_image = inv,
		-- Banner group groups together the banner items, but not the nodes.
		-- Used for crafting.
		groups = { banner = 1, deco_block = 1, },
		stack_max = 16,

		on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under

			local node_under = minetest.get_node(under)
			if placer and not placer:get_player_control().sneak then
				-- Use pointed node's on_rightclick function first, if present
				if minetest.registered_nodes[node_under.name] and minetest.registered_nodes[node_under.name].on_rightclick then
					return minetest.registered_nodes[node_under.name].on_rightclick(under, node_under, placer, itemstack) or itemstack
				end

				if minetest.get_modpath("mcl_cauldrons") then
					-- Use banner on cauldron to remove the top-most layer. This reduces the water level by 1.
					local new_node
					if node_under.name == "mcl_cauldrons:cauldron_3" then
						new_node = "mcl_cauldrons:cauldron_2"
					elseif node_under.name == "mcl_cauldrons:cauldron_2" then
						new_node = "mcl_cauldrons:cauldron_1"
					elseif node_under.name == "mcl_cauldrons:cauldron_1" then
						new_node = "mcl_cauldrons:cauldron"
					end
					if new_node then
						local imeta = itemstack:get_meta()
						local layers_raw = imeta:get_string("layers")
						local layers = minetest.deserialize(layers_raw)
						if type(layers) == "table" and #layers > 0 then
							minetest.log("error", dump(layers))
							table.remove(layers)
							imeta:set_string("layers", minetest.serialize(layers))
							local newdesc = mcl_banners.make_advanced_banner_description(itemstack:get_definition().description, layers)
							imeta:set_string("description", newdesc)
						end

						-- Washing off reduces the water level by 1.
						-- (It is possible to waste water if the banner had 0 layers.)
						minetest.set_node(pointed_thing.under, {name=new_node})

						return itemstack
					end
				end
			end


			-- Place the node!
			local _, success = minetest.item_place_node(ItemStack("mcl_banners:standing_banner"), placer, pointed_thing)
			if not success then
				return itemstack
			end

			local place_pos
			if minetest.registered_nodes[node_under.name].buildable_to then
				place_pos = under
			else
				place_pos = above
			end
			place_pos.y = place_pos.y - 0.5

			local banner = minetest.add_entity(place_pos, "mcl_banners:standing_banner")
			local imeta = itemstack:get_meta()
			local layers_raw = imeta:get_string("layers")
			local layers = minetest.deserialize(layers_raw)
			banner:get_luaentity():_set_textures(colorid, layers)


			-- Determine the rotation based on player's yaw
			local yaw = placer:get_look_horizontal()
			-- Select one of 16 possible rotations (0-15)
			local rotation_level = round((yaw / (math.pi*2)) * 16)
			local final_yaw = (rotation_level * (math.pi/8)) + math.pi
			banner:set_yaw(final_yaw)

			if not minetest.settings:get_bool("creative_mode") then
				itemstack:take_item()
			end
			minetest.sound_play({name="default_place_node_hard", gain=1.0}, {pos = place_pos})

			return itemstack
		end,
	})

	if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_wool") then
		minetest.register_craft({
			output = itemstring,
			recipe = {
				{ wool, wool, wool },
				{ wool, wool, wool },
				{ "", "mcl_core:stick", "" },
			}
		})
	end
end

minetest.register_entity("mcl_banners:standing_banner", {
	physical = false,
	collide_with_objects = false,
	visual = "mesh",
	mesh = "amc_banner.b3d",
	visual_size = { x=2.499, y=2.499 },
	textures = make_banner_texture(),
	collisionbox = { 0, 0, 0, 0, 0, 0 },

	_base_color = nil, -- base color of banner
	_layers = nil, -- table of layers painted over the base color.
		-- This is a table of tables with each table having the following fields:
			-- color: layer color ID (see colors table above)
			-- pattern: name of pattern (see list above)

	get_staticdata = function(self)
		local out = { _base_color = self._base_color, _layers = self._layers }
		return minetest.serialize(out)
	end,
	on_activate = function(self, staticdata)
		if staticdata and staticdata ~= "" then
			local inp = minetest.deserialize(staticdata)
			self._base_color = inp._base_color
			self._layers = inp._layers
			self.object:set_properties({textures = make_banner_texture(self._base_color, self._layers)})
		end
		self.object:set_armor_groups({immortal=1})
	end,

	-- This is a custom function which causes the banner to be dropped as item and destroys the entity.
	_drop = function(self)
		local pos = self.object:getpos()
		pos.y = pos.y + 1

		if not minetest.settings:get_bool("creative_mode") and self._base_color then
			minetest.add_item(pos, "mcl_banners:banner_item_"..mcl_banners.colors[self._base_color][1])
		end

		-- Destroy entity
		self.object:remove()
	end,

	-- Set the banner textures. This function can be used by external mods.
	-- Meaning of parameters:
	-- * self: Lua entity reference to entity.
	-- * other parameters: Same meaning as in make_banner_texture
	_set_textures = function(self, base_color, layers)
		if base_color then
			self._base_color = base_color
		end
		if layers then
			self._layers = layers
		end
		self.object:set_properties({textures = make_banner_texture(self._base_color, self._layers)})
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:banner",
	burntime = 15,
})

