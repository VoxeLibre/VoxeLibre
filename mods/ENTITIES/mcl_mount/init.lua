mcl_mount = {
	mounted = {}
}

local S = minetest.get_translator("mcl_mount")

function mcl_mount.update_children_visual_size(parent)
	for _, obj in pairs(parent:get_children()) do
		mcl_mount.update_visual_size(obj)
	end
end

function mcl_mount.update_visual_size(obj)
	if obj:is_player() then
		local visual_size = vector.new(1, 1, 1)
		local attach = obj:get_attach()

		obj:set_properties({visual_size = attach and vector.divide(visual_size, attach:get_properties().visual_size) or visual_size})
		mcl_mount.update_children_visual_size(obj)
	else
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.update_visual_size then
			luaentity:update_visual_size()
		end
	end
end

function mcl_mount.mount(obj, parent, animation)
	if obj:get_attach() then
		return false
	end

	if obj:is_player() then
		obj:set_look_horizontal(parent:get_yaw())
		mcl_mount.mounted[obj] = true
		mcl_player.player_set_animation(obj, animation or "sit", 30)
		mcl_title.set(obj, "actionbar", {text = S("Sneak to dismount"), color = "white", stay = 60})
	end

	mcl_mount.update_visual_size(obj)

	return true
end

function mcl_mount.dismount(obj)
	local parent = obj:get_attach()
	if not parent then
		return false
	end

	obj:set_detach()

	if obj:is_player() then
		mcl_mount.mounted[obj] = nil
		mcl_player.player_set_animation(obj, "stand", 30)
		obj:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
	end

	mcl_mount.update_visual_size(obj)
	return true
end

function mcl_mount.throw_off(obj)
	if mcl_mount.dismount(obj) then
		-- player:add_velocity(vector.new(math.random(-6, 6), math.random(5, 8), math.random(-6, 6)))
		obj:set_pos(vector.add(obj:get_pos(), vector.new(0, 0.2, 0)))
	end
end

minetest.register_on_respawnplayer(mcl_mount.dismount)
minetest.register_on_leaveplayer(mcl_mount.dismount)

minetest.register_globalstep(function()
	for player in pairs(mcl_mount.mounted) do
		local ctrl = player:get_player_control()
		if ctrl.sneak then
			mcl_mount.throw_off(player)
		end
	end
end)

