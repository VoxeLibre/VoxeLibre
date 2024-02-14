minetest.register_craft({
	output = "mcl_copper:block_raw",
	recipe = {
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
	},
})

minetest.register_craft({
	output = "mcl_copper:block",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
	},
})

local function get_shape(name, material)
	if name == "cut" then
		return {
			{material, material},
			{material, material}
		}
	elseif name == "grate" then
		return {
			{"", material, ""},
			{material, "", material},
			{"", material, ""}
		}
	elseif name == "chiseled" then
		return {
			{material},
			{material},
		}
	elseif name == "door" then
		return {
			{material, material},
			{material, material},
			{material, material}
		}
	elseif name == "trapdoor" then
		return {
			{material, material, material},
			{material, material, material}
		}
	elseif name == "bulb_off" then
		return {
			{"", material, ""},
			{material, "mcl_mobitems:blaze_rod", material},
			{"", "mesecons:redstone", ""}
		}
	else
		return {}
	end
end

function mcl_copper.register_variants_recipes(name, material, amount)
	local names
	local materials = {}
	if name ~= "cut" then
		names = {
			name, "waxed_"..name,
			name.."_exposed", "waxed_"..name.."_exposed",
			name.."_weathered", "waxed_"..name.."_weathered",
			name.."_oxidized", "waxed_"..name.."_oxidized"
		}
	else
		names = {
			"block_"..name, "waxed_block_"..name,
			"block_exposed_"..name, "waxed_block_exposed_"..name,
			"block_weathered_"..name, "waxed_block_weathered_"..name,
			"block_oxidized_"..name, "waxed_block_oxidized_"..name
		}
	end

	if type(material) == "string" then
		materials = {
			"mcl_copper:"..material, "mcl_copper:waxed_"..material,
			"mcl_copper:"..material.."_exposed", "mcl_copper:waxed_"..material.."_exposed",
			"mcl_copper:"..material.."_weathered", "mcl_copper:waxed_"..material.."_weathered",
			"mcl_copper:"..material.."_oxidized", "mcl_copper:waxed_"..material.."_oxidized"
		}
	elseif type(material) == "table" then
		if #material == 8 then
			materials = material
		else
			return
		end
	else
		return
	end

	for i = 1, 8 do
		minetest.register_craft({
			output = "mcl_copper:"..names[i].." "..tostring(amount),
			recipe = get_shape(name, materials[i])
		})
	end
end

mcl_copper.register_variants_recipes("cut", "block", 4)
mcl_copper.register_variants_recipes("grate", "block", 4)
mcl_copper.register_variants_recipes("door", "block", 3)
mcl_copper.register_variants_recipes("trapdoor", "block", 2)
mcl_copper.register_variants_recipes("bulb_off", "block", 4)

local chiseled_materials = {
	"mcl_stairs:slab_copper_cut",
	"mcl_stairs:slab_waxed_copper_cut",
	"mcl_stairs:slab_copper_exposed_cut",
	"mcl_stairs:slab_waxed_copper_exposed_cut",
	"mcl_stairs:slab_copper_weathered_cut",
	"mcl_stairs:slab_waxed_copper_weathered_cut",
	"mcl_stairs:slab_copper_oxidized_cut",
	"mcl_stairs:slab_waxed_copper_oxidized_cut"
}

mcl_copper.register_variants_recipes("chiseled", chiseled_materials, 1)

local waxable_blocks = {
	"block",
	"block_cut",
	"grate",
	"chiseled",
	"bulb_off",
	"block_exposed",
	"block_exposed_cut",
	"grate_exposed",
	"chiseled_exposed",
	"bulb_off_exposed",
	"block_weathered",
	"block_weathered_cut",
	"grate_weathered",
	"chiseled_weathered",
	"bulb_off_weathered",
	"block_oxidized",
	"block_oxidized_cut",
	"grate_oxidized",
	"chiseled_oxidized",
	"bulb_off_oxidized"
}

for _, w in ipairs(waxable_blocks) do
	minetest.register_craft({
		output = "mcl_copper:waxed_"..w,
		recipe = {
			{ "mcl_copper:"..w, "mcl_honey:honeycomb" },
		},
	})
end

local cuttable_blocks = {
	"block",
	"waxed_block",
	"block_exposed",
	"waxed_block_exposed",
	"block_weathered",
	"waxed_block_weathered",
	"block_oxidized",
	"waxed_block_oxidized"
}

for _, c in ipairs(cuttable_blocks) do
	mcl_stonecutter.register_recipe("mcl_copper:"..c, "mcl_copper:"..c.."_cut", 4)
	mcl_stonecutter.register_recipe("mcl_copper:"..c, "mcl_copper:"..c:gsub("block", "grate"), 4)
	mcl_stonecutter.register_recipe("mcl_copper:"..c, "mcl_copper:"..c:gsub("block", "chiseled"), 4)
	mcl_stonecutter.register_recipe("mcl_copper:"..c.."_cut", "mcl_copper:"..c:gsub("block", "chiseled"))
end

minetest.register_craft({
	output = "mcl_copper:copper_ingot 9",
	recipe = {
		{ "mcl_copper:block" },
	},
})

minetest.register_craft({
	output = "mcl_copper:raw_copper 9",
	recipe = {
		{ "mcl_copper:block_raw" },
	},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:copper_ingot",
	recipe = "mcl_copper:raw_copper",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:copper_ingot",
	recipe = "mcl_copper:stone_with_copper",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:block",
	recipe = "mcl_copper:block_raw",
	cooktime = 90,
})
