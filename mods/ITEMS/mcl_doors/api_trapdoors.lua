---- Trapdoor ----

function mcl_doors:register_trapdoor(name, def)
	local groups = table.copy(def.groups)
	if groups == nil then
		groups = {}
	end

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end
	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	local function punch(pos)
		local me = minetest.get_node(pos)
		local tmp_node
		-- Close
		if minetest.get_item_group(me.name, "trapdoor") == 2 then
			minetest.sound_play(def.sound_close, {pos = pos, gain = 0.3, max_hear_distance = 16})
			tmp_node = {name=name, param1=me.param1, param2=me.param2}
		-- Open
		else
			minetest.sound_play(def.sound_open, {pos = pos, gain = 0.3, max_hear_distance = 16})
			tmp_node = {name=name.."_open", param1=me.param1, param2=me.param2}
		end
		minetest.set_node(pos, tmp_node)
	end

	local on_rightclick
	if not def.only_redstone_can_open then
		on_rightclick = function(pos, node, clicker)
			punch(pos)
		end
	end

	-- Default help texts
	local longdesc, usagehelp
	longdesc = def._doc_items_longdesc
	if not longdesc then
		if def.only_redstone_can_open then
			longdesc = "Trapdoors are horizontal barriers which can be opened or closed. They occupy the upper or lower part of a block, depending on how they have been placed. This trapdoor can only be opened or closed by redstone power."
		else
			longdesc = "Trapdoors are horizontal barriers which can be opened or closed. They occupy the upper or lower part of a block, depending on how they have been placed. This trapdoor can be opened or closed by hand or redstone power."
		end
	end
	usagehelp = def._doc_items_usagehelp
	if not usagehelp and not def.only_redstone_can_open then
		usagehelp = "To open or close this trapdoor, rightclick it or send a redstone signal to it."
	end

	-- Closed trapdoor

	local groups_closed = groups
	groups_closed.trapdoor = 1
	minetest.register_node(name, {
		description = def.description,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		drawtype = "nodebox",
		tiles = def.tiles,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		is_ground_content = false,
		paramtype = "light",
		stack_max = 64,
		paramtype2 = "facedir",
		sunlight_propagates = true,
		groups = groups_closed,
		_mcl_hardness = def._mcl_hardness,
		_mcl_blast_resistance = def._mcl_blast_resistance,
		sounds = def.sounds,
		node_box = {
			type = "fixed",
			fixed = {
			{-8/16, -8/16, -8/16, 8/16, -5/16, 8/16},},
		},
		mesecons = {effector = {
			action_on = (function(pos, node)
				punch(pos)
			end),
		}},
		on_place = function(itemstack, placer, pointed_thing)
			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local param2 = 0

			local placer_pos = placer:getpos()
			if placer_pos then
				param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
			end

			local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
			local fpos = finepos.y % 1


			local origname = itemstack:get_name()
			if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
					or (fpos < -0.5 and fpos > -0.999999999) then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end
			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,
		on_rightclick = on_rightclick,
	})

	-- Open trapdoor

	local groups_open = table.copy(groups)
	groups_open.trapdoor = 2
	minetest.register_node(name.."_open", {
		drawtype = "nodebox",
		tiles = def.tiles,
		is_ground_content = false,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		pointable = true,
		groups = groups_open,
		_mcl_hardness = def._mcl_hardness,
		_mcl_blast_resistance = def._mcl_blast_resistance,
		sounds = def.sounds,
		drop = name,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, 5/16, 0.5, 0.5, 0.5}
		},
		on_rightclick = on_rightclick,
		mesecons = {effector = {
			action_on = (function(pos, node)
				punch(pos)
			end),
		}},
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", name, "nodes", name.."_open")
	end

end
