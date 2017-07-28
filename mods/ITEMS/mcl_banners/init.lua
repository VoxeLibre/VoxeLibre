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
	["unicolor_white"] = {"white",      "White Banner",      "mcl_wool:white", "#FFFFFFE0" },
	["unicolor_darkgrey"] = {"grey",       "Grey Banner",       "mcl_wool:grey", "#303030E0" },
	["unicolor_grey"] = {"silver",     "Light Grey Banner", "mcl_wool:silver", "#5B5B5BE0" },
	["unicolor_black"] = {"black",      "Black Banner",      "mcl_wool:black", "#000000E0" },
	["unicolor_red"] = {"red",        "Red Banner",        "mcl_wool:red", "#BC0000E0" },
	["unicolor_yellow"] = {"yellow",     "Yellow Banner",     "mcl_wool:yellow", "#BCA800E0" },
	["unicolor_dark_green"] = {"green",      "Green Banner",      "mcl_wool:green", "#006000E0" },
	["unicolor_cyan"] = {"cyan",       "Cyan Banner",       "mcl_wool:cyan", "#00ACACE0" },
	["unicolor_blue"] = {"blue",       "Blue Banner",       "mcl_wool:blue", "#0000ACE0" },
	["unicolor_red_violet"] = {"magenta",    "Magenta Banner",    "mcl_wool:magenta", "#AC007CE0" },
	["unicolor_orange"] = {"orange",     "Orange Banner",     "mcl_wool:orange", "#BC6900E0" },
	["unicolor_violet"] = {"purple",     "Purple Banner",     "mcl_wool:purple", "#6400ACE0" },
	["unicolor_brown"] = {"brown",      "Brown Banner",      "mcl_wool:brown", "#402100E0" },
	["unicolor_pink"] = {"pink",       "Pink Banner",       "mcl_wool:pink", "#DE557CE0" },
	["unicolor_lime"] = {"lime",       "Lime Banner",       "mcl_wool:lime", "#30AC00E0"},
	["unicolor_light_blue"] = {"light_blue", "Light Blue Banner", "mcl_wool:light_blue", "#4040CFE0" },
}

local patterns = {
	"border",
	"bricks",
	"circle",
	"creeper",
	"cross",
	"curly_border",
	"diagonal_left",
	"diagonal_right",
	"diagonal_up_left",
	"diagonal_up_right",
	"flower",	
	"gradient",
	"gradient_up",
	"half_horizontal_bottom",
	"half_horizontal",
	"half_vertical",
	"half_vertical_right",
	"thing",
	"rhombus",
	"skull",
	"small_stripes",
	"square_bottom_left",
	"square_bottom_right",
	"square_top_left",
	"square_top_right",
	"straight_cross",
	"stripe_bottom",
	"stripe_center",
	"stripe_downleft",
	"stripe_downright",
	"stripe_left",
	"stripe_middle",
	"stripe_right",
	"stripe_top",
	"triangle_bottom",
	"triangles_bottom",
	"triangles_top",
	"triangle_top",
}

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
	if colors[base_color] then
		colorize = colors[base_color][4]
	end
	if colorize then
		-- Base texture with base color
		local base = "(mcl_banners_banner_base.png^[mask:mcl_banners_base_inverted.png)^((mcl_banners_banner_base.png^[colorize:"..colorize..")^[mask:mcl_banners_base.png)"

		-- Optional pattern layers
		if layers then
			local finished_banner = base
			for l=1, #layers do
				local layerinfo = layers[l]
				local pattern = "mcl_banners_" .. layerinfo.pattern .. ".png"
				local color = colors[layerinfo.color][4]

				-- Generate layer texture
				local layer = "(("..pattern.."^[colorize:"..color..")^[mask:"..pattern..")"

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
	groups = { banner = 1, deco_block = 1, attached_node = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1, },
	stack_max = 16,
	sounds = node_sounds,
	drop = "", -- Item drops are handled in entity code

	on_destruct = on_destruct_standing_banner,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 5,
})

for colorid, colortab in pairs(colors) do
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
		_doc_items_longdesc = "Banners are tall decorative blocks with a solid color. They can be placed on the floor. Banners can not be emblazoned (yet).",
		inventory_image = inv,
		wield_image = inv,
		groups = { banner = 1, deco_block = 1, },
		stack_max = 16,

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
			banner:get_luaentity():_set_textures(colorid)

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
		-- Drop as item when the entity is destroyed.
		if not self._base_color then
			return
		end
		local pos = self.object:getpos()
		pos.y = pos.y + 1

		if not minetest.settings:get_bool("creative_mode") then
			minetest.add_item(pos, "mcl_banners:banner_item_"..colors[self._base_color][1])
		end

		-- Destroy entity
		self.object:remove()
	end,

	-- Set the banner textures. This function can be used by external mods.
	-- Meaning of parameters:
	-- * self: Lua entity reference to entity.
	-- * other parameters: Same meaning as in make_banner_texture
	_set_textures = function(self, base_color, layers)
		if self._base_color then
			self._base_color = colorid
		end
		if self._layers then
			self._layers = layers
		end

		local textures = make_banner_texture(self._base_color, self._layers)
		self:set_properties({textures=textures})
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:banner",
	burntime = 15,
})

