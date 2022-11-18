--TODO: Add sounds for the respawn anchor (charge sounds etc.)

--Nether ends at y -29077
--Nether roof at y -28933
local S = minetest.get_translator(minetest.get_current_modname())
--local mod_doc = minetest.get_modpath("doc") -> maybe add documentation ?

for i=0,4 do
	local nodebox_uncharged = { --Reused the composter nodebox, since it is basicly the same
	type = "fixed",
	fixed = {
		{-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
		{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
		{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
		{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
		{-0.5,   -0.5, -0.5,   0.5,   -0.47, 0.5},   -- Bottom level, -0.47 because -0.5 is so low that you can see the texture of the block below through
		}
	}

	local nodebox_charged = { --Reused the composter nodebox, since it is basicly the same
	type = "fixed",
	fixed = {
		{-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
		{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
		{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
		{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
		{-0.5,   -0.5, -0.5,   0.5,   0.5, 0.5},   -- Bottom level
		}
	}

	local function rightclick(pos, node, player, itemstack)
		if itemstack.get_name(itemstack) == "mcl_nether:glowstone" and i ~= 4 then
			minetest.set_node(pos, {name="mcl_beds:respawn_anchor_charged_" .. i+1})
			itemstack:take_item()
		elseif mcl_worlds.pos_to_dimension(pos) ~= "nether" then
			if node.name ~= "mcl_beds:respawn_anchor" then --only charged respawn anchors are exploding in the overworld & end in minecraft
				mcl_explosions.explode(pos, 5, {drop_chance = 0, fire = true})
			end
		elseif string.match(node.name, "mcl_beds:respawn_anchor_charged_") then
			minetest.chat_send_player(player.get_player_name(player), S"New respawn position set!")
			mcl_spawn.set_spawn_pos(player, pos, nil)
			if i == 4 then
				awards.unlock(player:get_player_name(), "mcl:notQuiteNineLives")
			end
		end
	end


	if i == 0 then
		minetest.register_node("mcl_beds:respawn_anchor",{
			description=S("Respawn Anchor"),
			tiles = {
				"respawn_anchor_top_off.png",
				"respawn_anchor_bottom.png",
				"respawn_anchor_side0.png"
			},
			drawtype = "nodebox",
			node_box = nodebox_uncharged,
			on_rightclick = rightclick,
			groups = {pickaxey=1, material_stone=1},
			_mcl_hardness = 22.5,
			sounds= mcl_sounds.node_sound_stone_defaults(),
			use_texture_alpha = "blend",
		})
		mesecon.register_mvps_stopper("mcl_beds:respawn_anchor")
	else
		minetest.register_node("mcl_beds:respawn_anchor_charged_"..i,{
			description=S("Respawn Anchor"),
			tiles = {
			{
				image="respawn_anchor_top_on.png",
				animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
			},
				"respawn_anchor_bottom.png",
				"respawn_anchor_side"..i ..".png"
			},
			drawtype = "nodebox",
			node_box = nodebox_charged,
			on_rightclick = rightclick,
			groups = {pickaxey=1, material_stone=1, not_in_creative_inventory=1},
			_mcl_hardness = 22.5,
			sounds= mcl_sounds.node_sound_stone_defaults(),
			drop = {
				max_items = 1,
				items = {
					{items = {"mcl_beds:respawn_anchor"}},
				}
			},
			light_source = math.min((4 * i) - 1, minetest.LIGHT_MAX),
			use_texture_alpha = "blend",
		})
		mesecon.register_mvps_stopper("mcl_beds:respawn_anchor_charged_"..i)
	end
 end


minetest.register_craft({
	output = "mcl_beds:respawn_anchor",
	recipe = {
			{"mcl_core:crying_obsidian", "mcl_core:crying_obsidian", "mcl_core:crying_obsidian"},
			{"mcl_nether:glowstone", "mcl_nether:glowstone", "mcl_nether:glowstone"},
			{"mcl_core:crying_obsidian", "mcl_core:crying_obsidian", "mcl_core:crying_obsidian"}
		}
	})
