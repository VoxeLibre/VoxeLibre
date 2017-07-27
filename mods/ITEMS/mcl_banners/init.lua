local node_sounds
if minetest.get_modpath("mcl_sounds") then
	node_sounds = mcl_sounds.node_sound_wood_defaults()
end

-- Helper function
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local colors = {
	-- ID, description, wool, unified dyes color group, overlay color,
	["unicolor_white"] = {"white",      "White Banner",      "mcl_wool:white", "#FFFFFFD0" },
	["unicolor_darkcolor"] = {"grey",       "Grey Banner",       "mcl_wool:grey", "#303030D0" },
	["unicolor_grey"] = {"silver",     "Light Grey Banner", "mcl_wool:silver", "#5B5B5BD0" },
	["unicolor_black"] = {"black",      "Black Banner",      "mcl_wool:black", "#000000E0" },
	["unicolor_red"] = {"red",        "Red Banner",        "mcl_wool:red", "#CC0000D0" },
	["unicolor_yellow"] = {"yellow",     "Yellow Banner",     "mcl_wool:yellow", "#CCB800D0" },
	["unicolor_dark_green"] = {"green",      "Green Banner",      "mcl_wool:green", "#008000D0" },
	["unicolor_cyan"] = {"cyan",       "Cyan Banner",       "mcl_wool:cyan", "#00CCCCD0" },
	["unicolor_blue"] = {"blue",       "Blue Banner",       "mcl_wool:blue", "#0000CCD0" },
	["unicolor_red_violet"] = {"magenta",    "Magenta Banner",    "mcl_wool:magenta", "#CC009CD0" },
	["unicolor_orange"] = {"orange",     "Orange Banner",     "mcl_wool:orange", "#CC5000D0" },
	["unicolor_violet"] = {"purple",     "Purple Banner",     "mcl_wool:purple", "#5000CCD0" },
	["unicolor_brown"] = {"brown",      "Brown Banner",      "mcl_wool:brown", "#7A3C00D0" },
	["unicolor_pink"] = {"pink",       "Pink Banner",       "mcl_wool:pink", "#EE658CD0" },
	["unicolor_lime"] = {"lime",       "Lime Banner",       "mcl_wool:lime", "#50CC00D0"},
	["unicolor_light_blue"] = {"light_blue", "Light Blue Banner", "mcl_wool:light_blue", "#5050FFD0" },
}

local on_destruct_standing_banner = function(pos)
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, v in ipairs(objects) do
		if v:get_entity_name() == "mcl_banners:standing_banner" then
			v:remove()
		end
	end
end

local make_banner_texture = function(colorid)
	local colorize
	if colors[colorid] then
		colorize = colors[colorid][4]
	end
	if colorize then
		return { "(mcl_banners_banner_base.png^[mask:mcl_banners_base_inverted.png)^((mcl_banners_banner_base.png^[colorize:"..colorize..")^[mask:mcl_banners_base.png)" }
	else
		return { "mcl_banners_banner_base.png" }
	end
end

for colorid, colortab in pairs(colors) do
	local itemid = colortab[1]
	local desc = colortab[2]
	local wool = colortab[3]
	local colorize = colortab[4]

	local itemstring_standing = "mcl_banners:standding_banner_"..itemid
	local inv
	if colorize then
		inv = "mcl_banners_item_base.png^(mcl_banners_item_overlay.png^[colorize:"..colorize..")"
	else
		inv = "mcl_banners_item_base.png^mcl_banners_item_overlay.png"
	end

	-- Banner node
	minetest.register_node(itemstring_standing, {
		description = desc,
		_doc_items_longdesc = "Banners are tall decorative blocks which can be placed on the floor.",
		walkable = false,
		is_ground_content = false,
		paramtype = "light",
		sunlight_propagates = true,
		drawtype = "airlike",
		inventory_image = inv,
		wield_image = inv,
		tiles = { "blank.png" },
		selection_box = {type = "fixed", fixed= {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2} },
		groups = { banner = 1, deco_block = 1, attached_node = 1 },
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

			local banner = minetest.add_entity(place_pos, "mcl_banners:standing_banner")
			banner:set_properties({textures=make_banner_texture(colorid)})
			banner:get_luaentity()._base_color = colorid

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

		on_destruct = on_destruct_standing_banner,
		_mcl_hardness = 1,
		_mcl_blast_resistance = 5,
	})

	if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_wool") then
		minetest.register_craft({
			output = itemstring_standing,
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

	_base_color = nil,

	get_staticdata = function(self)
		local out = { _base_color = self._base_color }
		return minetest.serialize(out)
	end,
	on_activate = function(self, staticdata)
		if staticdata and staticdata ~= "" then
			local inp = minetest.deserialize(staticdata)
			self._base_color = inp._base_color
			self.object:set_properties({textures = make_banner_texture(self._base_color)})
		end
		self.object:set_armor_groups({immortal=1})
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:banner",
	burntime = 15,
})

