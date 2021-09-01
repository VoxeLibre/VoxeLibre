-- Register spawn eggs

--[[
-- Note: This also introduces the “spawn_egg” group:
-- * spawn_egg=1: Spawn egg (generic mob, no metadata)
-- * spawn_egg=2: Spawn egg (captured/tamed mob, metadata)
function mobs:register_egg(mob, desc, background, addegg, no_creative)

	local grp = {spawn_egg = 1}

	-- do NOT add this egg to creative inventory (e.g. dungeon master)
	if no_creative == true then
		grp.not_in_creative_inventory = 1
	end

	local invimg = background

	if addegg == 1 then
		invimg = "mobs_chicken_egg.png^(" .. invimg ..
			"^[mask:mobs_chicken_egg_overlay.png)"
	end

	-- register old stackable mob egg
	minetest.register_craftitem(mob, {

		description = desc,
		inventory_image = invimg,
		groups = grp,

		_doc_items_longdesc = S("This allows you to place a single mob."),
		_doc_items_usagehelp = S("Just place it where you want the mob to appear. Animals will spawn tamed, unless you hold down the sneak key while placing. If you place this on a mob spawner, you change the mob it spawns."),

		on_place = function(itemstack, placer, pointed_thing)

			local pos = pointed_thing.above

			-- am I clicking on something with existing on_rightclick function?
			local under = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[under.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, under, placer, itemstack)
			end

			if pos
			--and within_limits(pos, 0)
			and not minetest.is_protected(pos, placer:get_player_name()) then

				local name = placer:get_player_name()
				local privs = minetest.get_player_privs(name)
				if mod_mobspawners and under.name == "mcl_mobspawners:spawner" then
					if minetest.is_protected(pointed_thing.under, name) then
						minetest.record_protection_violation(pointed_thing.under, name)
						return itemstack
					end
					if not privs.maphack then
						minetest.chat_send_player(name, S("You need the “maphack” privilege to change the mob spawner."))
						return itemstack
					end
					mcl_mobspawners.setup_spawner(pointed_thing.under, itemstack:get_name())
					if not mobs.is_creative(name) then
						itemstack:take_item()
					end
					return itemstack
				end

				if not minetest.registered_entities[mob] then
					return itemstack
				end

				if minetest.settings:get_bool("only_peaceful_mobs", false)
						and minetest.registered_entities[mob].type == "monster" then
					minetest.chat_send_player(name, S("Only peaceful mobs allowed!"))
					return itemstack
				end

				local mob = minetest.add_entity(pos, mob)
				minetest.log("action", "mcl_mobs.mob spawned: "..name.." at "..minetest.pos_to_string(pos))
				local ent = mob:get_luaentity()

				-- don't set owner if monster or sneak pressed
				--[[
				if ent.type ~= "monster"
				and not placer:get_player_control().sneak then
					ent.owner = placer:get_player_name()
					ent.tamed = true
				end
				] ]--

				-- set nametag
				local nametag = itemstack:get_meta():get_string("name")
				if nametag ~= "" then
					if string.len(nametag) > MAX_MOB_NAME_LENGTH then
						nametag = string.sub(nametag, 1, MAX_MOB_NAME_LENGTH)
					end
					ent.nametag = nametag
					update_tag(ent)
				end

				-- if not in creative then take item
				if not mobs.is_creative(placer:get_player_name()) then
					itemstack:take_item()
				end
			end

			return itemstack
		end,
	})

end
]]--
