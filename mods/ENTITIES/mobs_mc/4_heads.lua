--MC Heads for minetest
--maikerumine

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

-- Heads system

local sounds
if minetest.get_modpath("default") then
	sounds = default.node_sound_defaults({
		footstep = {name="default_hard_footstep", gain=0.3}
	})
end

local function addhead(mobname, desc, longdesc)
	if not mobs_mc.is_item_variable_overridden("head_"..mobname) then
		return
	end
	minetest.register_node("mobs_mc:head_"..mobname, {
		description = desc,
		_doc_items_longdesc = longdesc,
		drawtype = "nodebox",
		is_ground_content = false,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },
			},
		},
		groups = { oddly_breakable_by_hand=3, head=1, },
		-- The head textures are based off the textures of an actual mob.
		-- FIXME: This code assumes 16×16 textures for the mob textures!
		tiles = {
			-- Note: bottom texture is overlaid over top texture to get rid of possible transparency.
			-- This is required for skeleton skull and wither skeleton skull.
			"[combine:16x16:-4,4=mobs_mc_"..mobname..".png", -- top
			"([combine:16x16:-4,4=mobs_mc_"..mobname..".png)^([combine:16x16:-12,4=mobs_mc_"..mobname..".png)", -- bottom
			"[combine:16x16:-12,0=mobs_mc_"..mobname..".png", -- left
			"[combine:16x16:4,0=mobs_mc_"..mobname..".png", -- right
			"[combine:16x16:-20,0=mobs_mc_"..mobname..".png", -- back
			"[combine:16x16:-4,0=mobs_mc_"..mobname..".png", -- front
		},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = true,
		sounds = sounds,
		selection_box = {
			type = "fixed",
			fixed = { -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },
		},
	})
end

-- Add heads
addhead("zombie", S("Zombie Head"), S("A zombie head is a small decorative block which resembles the head of a zombie."))
addhead("creeper", S("Creeper Head"), S("A creeper head is a small decorative block which resembles the head of a creeper."))
addhead("skeleton", S("Skeleton Skull"), S("A skeleton skull is a small decorative block which resembles the skull of a skeleton."))
addhead("wither_skeleton", S("Wither Skeleton Skull"), S("A wither skeleton skull is a small decorative block which resembles the skull of a wither skeleton."))
