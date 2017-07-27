local node_sounds
if minetest.get_modpath("mcl_sounds") then
	node_sounds = mcl_sounds.node_sound_wood_defaults()
end

-- Helper function
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Banner node
minetest.register_node("mcl_banners:standing_banner_white", {
	description = "White Banner",
	_doc_items_longdesc = "Banners are tall decorative blocks which can be placed on the floor.",
	walkable = false,
	is_ground_content = false,
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "airlike",
	inventory_image = "mcl_banners_item_base.png^mcl_banners_item_overlay.png",
	wield_image = "mcl_banners_item_base.png^mcl_banners_item_overlay.png",
	selection_box = {type = "fixed", fixed= {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2} },
	tiles = {"mcl_banners_banner_base.png"},
	groups = { deco_block = 1, attached_node = 1 },
	stack_max = 16,
	sounds = node_sounds,

	on_place = function(itemstack, placer, pointed_thing)
		local above = pointed_thing.above
		local under = pointed_thing.under

		-- Use pointed node's on_rightclick function first, if present
		local node_under = minetest.get_node(under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node_under.name] and minetest.registered_nodes[node_under.name].on_rightclick then
				return minetest.registered_nodes[node_under.name].on_rightclick(under, node_under, placer, itemstack) or itemstack
			end
		end

		-- Place the node!
		local _, success = minetest.item_place_node(itemstack, placer, pointed_thing)
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

		local banner = minetest.add_entity(place_pos, "mcl_banners:banner")

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
	on_destruct = function(pos)
		local objects = minetest.get_objects_inside_radius(pos, 0.5)
		for _, v in ipairs(objects) do
			if v:get_entity_name() == "mcl_banners:banner" then
				v:remove()
			end
		end
	end,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 5,
})

minetest.register_entity("mcl_banners:banner", {
	physical = false,
	collide_with_objects = false,
	visual = "mesh",
	mesh = "amc_banner.b3d",
	visual_size = { x=2.5, y=2.5 },
	textures = { "mcl_banners_banner_base.png" },
	collisionbox = { 0, 0, 0, 0, 0, 0 },

	_base_color = nil,

	get_staticdata = function(self)
		local out = { _base_color = self._base_color }
		return minetest.serialize(out)
	end,
	on_activate = function(self, staticdata)
		if staticdata and staticdata ~= "" then
			local inp = minetest.deserialize(staticdata)
			self._base_color = inp._base_color
		end
		self.object:set_armor_groups({immortal=1})
	end,
})

if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_wool") then
	minetest.register_craft({
		output = "mcl_banners:standing_banner_white",
		recipe = {
			{ "mcl_wool:white", "mcl_wool:white", "mcl_wool:white" },
			{ "mcl_wool:white", "mcl_wool:white", "mcl_wool:white" },
			{ "", "mcl_core:stick", "" },
		}
	})

end

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_banners:standing_banner_white",
	burntime = 15,
})

