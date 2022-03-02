local modpath = minetest.get_modpath(minetest.get_current_modname())

local pairs = pairs
local get_connected_players = minetest.get_connected_players
local get_item_group = minetest.get_item_group

mcl_burning = {
	storage = {}
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

minetest.register_on_respawnplayer(function(player)
	mcl_burning.extinguish(player)
end)

minetest.register_on_joinplayer(function(player)
	local storage = {}
	local burn_data = player:get_meta():get_string("mcl_burning:data")
	if burn_data ~= "" then
		storage = minetest.deserialize(burn_data)
	end
	mcl_burning.storage[player] = storage
end)

local function on_leaveplayer(player)
	local storage = mcl_burning.storage[player]
	storage.fire_hud_id = nil
	player:get_meta():set_string("mcl_burning:data", minetest.serialize(storage))
	mcl_burning.storage[player] = nil
end

minetest.register_on_leaveplayer(function(player)
	on_leaveplayer(player)
end)

minetest.register_on_shutdown(function()
	for _,player in ipairs(minetest.get_connected_players()) do
		on_leaveplayer(player)
	end
end)

local animation_frames = tonumber(minetest.settings:get("fire_animation_frames")) or 8

minetest.register_entity("mcl_burning:fire", {
	initial_properties = {
		physical = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "upright_sprite",
		textures = {
			"mcl_burning_entity_flame_animated.png",
			"mcl_burning_entity_flame_animated.png"
		},
		spritediv = {x = 1, y = animation_frames},
		pointable = false,
		glow = -1,
		backface_culling = false,
	},
	animation_frame = 0,
	animation_timer = 0,
	on_activate = function(self)
		self.object:set_sprite({x = 0, y = 0}, animation_frames, 1.0 / animation_frames)
	end,
	on_step = function(self, dtime)
		local parent = self.object:get_attach()
		if not parent then
			self.object:remove()
			return
		end
		local storage = mcl_burning.get_storage(parent)
		if not storage or not storage.burn_time then
			self.object:remove()
			return
		end
		if parent:is_player() then
			self.animation_timer = self.animation_timer + dtime
			if self.animation_timer >= 0.1 then
				self.animation_timer = 0
				mcl_burning.update_hud(parent)
			end
		end
	end,
})
