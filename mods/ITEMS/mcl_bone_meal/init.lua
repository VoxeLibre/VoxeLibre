local S = minetest.get_translator(minetest.get_current_modname())

local longdesc = S(
	"Bone meal is a white dye and also useful as a fertilizer to " ..
	"speed up the growth of many plants."
)
local usagehelp = S(
	"Rightclick a sheep to turn its wool white. Rightclick a plant " ..
	"to speed up its growth. Note that not all plants can be " ..
	"fertilized like this. When you rightclick a grass block, tall " ..
	"grass and flowers will grow all over the place."
)

mcl_bone_meal = {}

-- Bone meal particle api:

--- Spawns bone meal particles.
-- pos: where the particles spawn
-- def: particle spawner parameters, see minetest.add_particlespawner() for
--	details on these parameters.
--
function mcl_bone_meal.add_bone_meal_particle(pos, def)
	if not def then
		def = {}
	end
	minetest.add_particlespawner({
		amount = def.amount or 10,
		time = def.time or 0.1,
		minpos = def.minpos or vector.subtract(pos, 0.5),
		maxpos = def.maxpos or vector.add(pos, 0.5),
		minvel = def.minvel or vector.new(-0.01, 0.01, -0.01),
		maxvel = def.maxvel or vector.new(0.01, 0.01, 0.01),
		minacc = def.minacc or vector.new(0, 0, 0),
		maxacc = def.maxacc or vector.new(0, 0, 0),
		minexptime = def.minexptime or 1,
		maxexptime = def.maxexptime or 4,
		minsize = def.minsize or 0.7,
		maxsize = def.maxsize or 2.4,
		texture = "mcl_particles_bonemeal.png^[colorize:#00EE00:125", -- TODO: real MC color
		glow = def.glow or 1,
	})
end

-- Begin legacy bone meal API.
--
-- Compatibility code for legacy users of the old bone meal API.
-- This code will be removed at some time in the future.
--
mcl_bone_meal.bone_meal_callbacks = {}

-- Shims for the old API are still available in mcl_dye and defer to
-- the real functions in mcl_bone_meal.
--
function mcl_bone_meal.register_on_bone_meal_apply(func)
	minetest.log("warning", "register_on_bone_meal_apply(func) is deprecated. Read mcl_bone_meal/API.md!")
	print(debug.traceback())
	table.insert(mcl_bone_meal.bone_meal_callbacks, func)
end

-- Legacy registered users of the old API are handled through this function.
--
local function legacy_apply_bone_meal(pointed_thing, placer)
	-- Legacy API support
	for _, func in pairs(mcl_bone_meal.bone_meal_callbacks) do
		if func(pointed_thing, placer) then
			return true
		end
	end

--[[
	Here for when Bonemeal becomes an api, there's code if needed for handling applying to bamboo.
	-- Handle applying bonemeal to bamboo.
	elseif mcl_bamboo.is_bamboo(n.name) then
		local success = mcl_bamboo.grow_bamboo(pos, true)
		if success then
			mcl_dye.add_bone_meal_particle(pos)
		end
		return success
--]]

	return false
end
-- End legacy bone meal API

mcl_bone_meal.use_bone_meal = function(itemstack, placer, pointed_thing)
	local pos = pointed_thing.under

	-- Check protection
	if mcl_util.check_area_protection(pos, pointed_thing.above, placer) then return false end

	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local success = false

	-- If the pointed node can be bonemealed, let it handle the processing.
	if ndef and ndef._mcl_on_bonemealing then
		success = ndef._mcl_on_bonemealing(pointed_thing, placer)
	else
		-- Otherwise try the legacy API.
		success = legacy_apply_bone_meal(pointed_thing, placer)
	end

	-- Particle effects
	if success then
		mcl_bone_meal.add_bone_meal_particle(pos)
	end

	-- Take the item
	if not placer or not minetest.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end

	return itemstack
end

minetest.register_craftitem("mcl_bone_meal:bone_meal", {
	description = S("Bone Meal"),
	_tt_help = S("Speeds up plant growth"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	inventory_image = "mcl_bone_meal.png",
	groups = {craftitem=1},
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]

		-- Use pointed node's on_rightclick function first, if present.
		if placer and not placer:get_player_control().sneak then
			if ndef and ndef.on_rightclick then
				return ndef.on_rightclick(pos, node, placer, itemstack, pointed_thing) or itemstack
			end
		end

		return mcl_bone_meal.use_bone_meal(itemstack, placer, pointed_thing)
	end,
	_on_dispense = function(itemstack, pos, droppos, dropnode, dropdir)
		local pointed_thing
		if dropnode.name == "air" then
			pointed_thing = {above = droppos, under = vector.offset(droppos, 0, -1 ,0)}
		else
			pointed_thing = {above = pos, under = droppos}
		end

		return mcl_bone_meal.use_bone_meal(itemstack, nil, pointed_thing)
	end,
	_dispense_into_walkable = true
})

minetest.register_craft({
	output = "mcl_bone_meal:bone_meal 3",
	recipe = {{"mcl_mobitems:bone"}},
})
