
local reverse = true

local function destruct_bed(pos, n)
	local node = minetest.get_node(pos)
	local other

	if n == 2 then
		local dir = minetest.facedir_to_dir(node.param2)
		other = vector.subtract(pos, dir)
	elseif n == 1 then
		local dir = minetest.facedir_to_dir(node.param2)
		other = vector.add(pos, dir)
	end

	if reverse then
		reverse = not reverse
		minetest.remove_node(other)
		minetest.check_for_falling(other)
	else
		reverse = not reverse
	end
end

local beddesc = "Beds allow you to sleep at night and waste some time. Survival in this world does not demand sleep, but sleeping might have some other uses. "
local beduse = "Right-click on the bed to try to sleep in it. This only works when the sun sets or at night."
if minetest.setting_getbool("enable_bed_respawn") == false then
	beddesc = beddesc .. "In local folklore, legends are told of other worlds where setting the start point for your next would be possible. But this world is not one of them. "
else
	beddesc = beddesc .. "By sleeping in a bed, you set the starting point for your next life. "
end
if minetest.setting_getbool("enable_bed_night_skip") == false then
	beddesc = beddesc .. "In this strange world, the time will not pass faster for you when you sleep."
else
	beddesc = beddesc .. "Going into bed seems to make time pass faster: The night will be skipped when you go sleep and you're alone in this world. If you're not alone, the night is skipped when all players in this world went to sleep."
end

function beds.register_bed(name, def)
	minetest.register_node(name .. "_bottom", {
		description = def.description,
		_doc_items_longdesc = def._doc_items_longdesc or beddesc,
		_doc_items_usagehelp = def._doc_items_usagehelp or beduse,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		drawtype = "nodebox",
		tiles = def.tiles.bottom,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		stack_max = 1,
		groups = {handy=1, flammable = 3, bed = 1},
		_mcl_hardness = 0.2,
		sounds = def.sounds or mcl_sounds.node_sound_wood_defaults(),
		node_box = {
			type = "fixed",
			fixed = def.nodebox.bottom,
		},
		selection_box = {
			type = "fixed",
			fixed = def.selectionbox,
		},

		on_place = function(itemstack, placer, pointed_thing)
			local under = pointed_thing.under

			-- Use pointed node's on_rightclick function first, if present
			local node = minetest.get_node(under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			local pos
			if minetest.registered_items[minetest.get_node(under).name].buildable_to then
				pos = under
			else
				pos = pointed_thing.above
			end

			if minetest.is_protected(pos, placer:get_player_name()) and
					not minetest.check_player_privs(placer, "protection_bypass") then
				minetest.record_protection_violation(pos, placer:get_player_name())
				return itemstack
			end

			local node_def = minetest.registered_nodes[minetest.get_node(pos).name]
			if not node_def or not node_def.buildable_to then
				return itemstack
			end

			local dir = minetest.dir_to_facedir(placer:get_look_dir())
			local botpos = vector.add(pos, minetest.facedir_to_dir(dir))

			if minetest.is_protected(botpos, placer:get_player_name()) and
					not minetest.check_player_privs(placer, "protection_bypass") then
				minetest.record_protection_violation(botpos, placer:get_player_name())
				return itemstack
			end

			local botdef = minetest.registered_nodes[minetest.get_node(botpos).name]
			if not botdef or not botdef.buildable_to then
				return itemstack
			end

			minetest.set_node(pos, {name = name .. "_bottom", param2 = dir})
			minetest.set_node(botpos, {name = name .. "_top", param2 = dir})

			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,

		on_destruct = function(pos)
			destruct_bed(pos, 1)
		end,

		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			beds.on_rightclick(pos, clicker)
			return itemstack
		end,

		on_rotate = function(pos, node, user, mode, new_param2)
			local dir = minetest.facedir_to_dir(node.param2)
			local p = vector.add(pos, dir)
			local node2 = minetest.get_node_or_nil(p)
			if not node2 or not minetest.get_item_group(node2.name, "bed") == 2 or
					not node.param2 == node2.param2 then
				return false
			end
			if minetest.is_protected(p, user:get_player_name()) then
				minetest.record_protection_violation(p, user:get_player_name())
				return false
			end
			if mode ~= screwdriver.ROTATE_FACE then
				return false
			end
			local newp = vector.add(pos, minetest.facedir_to_dir(new_param2))
			local node3 = minetest.get_node_or_nil(newp)
			local node_def = node3 and minetest.registered_nodes[node3.name]
			if not node_def or not node_def.buildable_to then
				return false
			end
			if minetest.is_protected(newp, user:get_player_name()) then
				minetest.record_protection_violation(newp, user:get_player_name())
				return false
			end
			node.param2 = new_param2
			-- do not remove_node here - it will trigger destroy_bed()
			minetest.set_node(p, {name = "air"})
			minetest.set_node(pos, node)
			minetest.set_node(newp, {name = name .. "_top", param2 = new_param2})
			return true
		end,
	})

	minetest.register_node(name .. "_top", {
		drawtype = "nodebox",
		tiles = def.tiles.top,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		pointable = false,
		groups = {handy = 1, flammable = 3, bed = 2},
		_mcl_hardness = 0.2,
		sounds = def.sounds or mcl_sounds.node_sound_wood_defaults(),
		drop = name .. "_bottom",
		node_box = {
			type = "fixed",
			fixed = def.nodebox.top,
		},
		on_destruct = function(pos)
			destruct_bed(pos, 2)
		end,
	})

	minetest.register_alias(name, name .. "_bottom")

	minetest.register_craft({
		output = name,
		recipe = def.recipe
	})
end
