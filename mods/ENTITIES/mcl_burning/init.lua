local modpath = minetest.get_modpath(minetest.get_current_modname())

local pairs = pairs

local get_connected_players = minetest.get_connected_players
local get_item_group = minetest.get_item_group

mcl_burning = {
	storage = {},
	channels = {},
	animation_frames = tonumber(minetest.settings:get("fire_animation_frames")) or 8
}

dofile(modpath .. "/api.lua")

minetest.register_globalstep(function(dtime)
	for _, player in pairs(get_connected_players()) do
		local storage = mcl_burning.storage[player]
		if not mcl_burning.tick(player, dtime, storage) and not mcl_burning.is_affected_by_rain(player) then
			local nodes = mcl_burning.get_touching_nodes(player, {"group:puts_out_fire", "group:set_on_fire"}, storage)
			local burn_time = 0

			for _, pos in pairs(nodes) do
				local node = minetest.get_node(pos)
				if get_item_group(node.name, "puts_out_fire") > 0 then
					burn_time = 0
					break
				end

				local value = get_item_group(node.name, "set_on_fire")
				if value > burn_time then
					burn_time = value
				end
			end

			if burn_time > 0 then
				mcl_burning.set_on_fire(player, burn_time)
			end
		end
	end
end)

mcl_damage.register_modifier(function(obj, damage, reason)
	if reason.is_fire then
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.no_fire_damage then
			return 0
		end
	end
end, -200)

mcl_damage.register_on_damage(function(obj, damage, reason)
	if reason.direct and mcl_burning.is_burning(obj) then
		mcl_burning.set_on_fire(obj, 5)
	end
end)

minetest.register_on_respawnplayer(function(player)
	mcl_burning.extinguish(player)
end)

minetest.register_on_joinplayer(function(player)
	local storage

	local burn_data = player:get_meta():get_string("mcl_burning:data")
	if burn_data == "" then
		storage = {}
	else
		storage = minetest.deserialize(burn_data)
	end

	mcl_burning.storage[player] = storage
	mcl_burning.channels[player] = minetest.mod_channel_join("mcl_burning:" .. player:get_player_name())
end)

minetest.register_on_leaveplayer(function(player)
	player:get_meta():set_string("mcl_burning:data", minetest.serialize(mcl_burning.storage[player]))
	mcl_burning.storage[player] = nil
end)


minetest.register_entity("mcl_burning:fire", {
	initial_properties = {
		physical = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "upright_sprite",
		textures = {
			name = "mcl_burning_entity_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		spritediv = {x = 1, y = mcl_burning.animation_frames},
		pointable = false,
		glow = -1,
		backface_culling = false,
	},
	animation_frame = 0,
	animation_timer = 0,
	on_activate = function(self)
		self.object:set_sprite({x = 0, y = 0}, mcl_burning.animation_frames, 1.0 / mcl_burning.animation_frames)
	end,
	on_step = function(self)
		if not self:sanity_check() then
			self.object:remove()
		end
	end,
	sanity_check = function(self)
		local parent = self.object:get_attach()

		if not parent then
			return false
		end

		local storage = mcl_burning.get_storage(parent)

		if not storage or not storage.burn_time then
			return false
		end

		return true
	end,
	update_visual_size = function(self, parent, storage)
		parent = parent or self.object:get_attach()
		storage = storage or mcl_burning.get_storage(parent)

		local minp, maxp = mcl_burning.get_collisionbox(parent, false, storage)
		local obj_size = parent:get_properties().visual_size

		local vertical_grow_factor = 1.2
		local horizontal_grow_factor = 1.1
		local grow_vector = vector.new(horizontal_grow_factor, vertical_grow_factor, horizontal_grow_factor)

		local size = vector.subtract(maxp, minp)
		size = vector.multiply(size, grow_vector)
		size = vector.divide(size, obj_size)
		local offset = vector.new(0, size.y * 10 / 2, 0)

		self.object:set_properties({visual_size = size})
		self.object:set_attach(parent, "", offset)
	end,
})
