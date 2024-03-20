bonemeal = {}

function bonemeal:on_use(pos, strength, node)
	-- Fake itemstack for bone meal
	local itemstack = ItemStack("mcl_bone_meal:bone_meal")

	local pointed_thing = {
		above = pos,
		under = vector.offset(pos, 0, -1, 0)
	}
	mcl_bone_meal.use_bone_meal(itemstack, nil, pointed_thing)
end
