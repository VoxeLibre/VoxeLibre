bonemeal = {
	item_list = {
		bucket_water = "mcl_buckets:bucket_water",
		bucket_empty = "mcl_buckets:bucket_empty",
		dirt = "mcl_core:dirt",
		torch = "mcl_torches:torch",
		coral = "mcl_ocean:dead_horn_coral_block"
	}
}

function bonemeal:on_use(pos, strength, node)
	-- Fake itemstack for bone meal
	local itemstack = ItemStack("mcl_bone_meal:bone_meal")

	local pointed_thing = {
		above = pos,
		under = vector.offset(pos, 0, -1, 0)
	}
	mcl_bone_meal.use_bone_meal(itemstack, nil, pointed_thing)
end

function bonemeal:is_creative(player_name)
	return minetest.is_creative_enabled(player_name)
end

function bonemeal:add_deco(list)
	minetest.log("TODO: implement bonemeal:add_deco("..dump(list).."..)")
	for i = 1,#list do
		local item = list[i]
	end
end

minetest.register_alias("bonemeal:bone", "mcl_mobitems:bone")
