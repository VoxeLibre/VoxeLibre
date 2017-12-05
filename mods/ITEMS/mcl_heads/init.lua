-- Heads system

local function addhead(name, texture, desc, longdesc)
	local on_rotate
	if minetest.get_modpath("screwdriver") then
		on_rotate = screwdriver.rotate_simple
	end

	minetest.register_node("mcl_heads:"..name, {
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
		groups = {handy=1, armor_head=1,non_combat_armor=1, head=1, deco_block=1, dig_by_piston=1},
		-- The head textures are based off the textures of an actual mob.
		-- FIXME: This code assumes 16×16 textures for the mob textures!
		tiles = {
			-- Note: bottom texture is overlaid over top texture to get rid of possible transparency.
			-- This is required for skeleton skull and wither skeleton skull.
			"[combine:16x16:-4,4="..texture, -- top
			"([combine:16x16:-4,4="..texture..")^([combine:16x16:-12,4="..texture..")", -- bottom
			"[combine:16x16:-12,0="..texture, -- left
			"[combine:16x16:4,0="..texture, -- right
			"[combine:16x16:-20,0="..texture, -- back
			"[combine:16x16:-4,0="..texture, -- front
		},	    
		paramtype = "light",
		stack_max = 64,
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = true,
		selection_box = {
			type = "fixed",
			fixed = { -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },
		},
		sounds = mcl_sounds.node_sound_defaults({
			footstep = {name="default_hard_footstep", gain=0.3}
		}),
		on_rotate = on_rotate,
		_mcl_blast_resistance = 5,
		_mcl_hardness = 1,
	})
end

-- Add heads
addhead("zombie", "mobs_mc_zombie.png", "Zombie Head", "A zombie head is a small decorative block which resembles the head of a zombie. It can also be worn as a helmet for fun, but does not offer any protection.")
addhead("creeper", "mobs_mc_creeper.png", "Creeper Head", "A creeper head is a small decorative block which resembles the head of a creeper. It can also be worn as a helmet for fun, but does not offer any protection.")
-- Original Minecraft name: “Head”
addhead("steve", "character.png", "Human Head", "A human head is a small decorative block which resembles the head of a human (i.e. a player character). It can also be worn as a helmet for fun, but does not offer any protection.")
addhead("skeleton", "mobs_mc_skeleton.png", "Skeleton Skull", "A skeleton skull is a small decorative block which resembles the head of a skeleton. It can also be worn as a helmet for fun, but does not offer any protection.")
addhead("wither_skeleton", "mobs_mc_wither_skeleton.png", "Wither Skeleton Skull", "A wither skeleton skull is a small decorative block which resembles the head of a wither skeleton. It can also be worn as a helmet for fun, but does not offer any protection.")
