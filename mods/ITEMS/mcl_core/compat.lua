-- Backwards compatibility and aliases

--
-- Old wood node names
--
local function alias(old, new, mcla)
	mcla = mcla or new
	core.register_alias("mcl_core:"..old, "mcl_core:"..new)
	core.register_alias("mcl_trees:"..mcla, "mcl_core:"..new)
end

alias("wood", "wood_oak")
alias("tree", "tree_oak")
alias("tree_bark", "bark_oak")
alias("stripped_oak", "tree_stripped_oak", "stripped_oak")
alias("stripped_oak_bark", "bark_stripped_oak", "stripped_oak_bark")
alias("sapling", "sapling_oak")
alias("leaves", "leaves_oak")

alias("darkwood", "wood_dark_oak")
alias("darktree", "tree_dark_oak")
alias("darktree_bark", "bark_dark_oak")
alias("stripped_dark_oak", "tree_stripped_dark_oak", "stripped_dark_oak")
alias("stripped_dark_oak_bark", "bark_stripped_dark_oak", "stripped_dark_oak_bark")
alias("darksapling", "sapling_dark_oak")
alias("darkleaves", "leaves_dark_oak")

alias("acaciawood", "wood_acacia")
alias("acaciatree", "tree_acacia")
alias("acaciatree_bark", "bark_acacia")
alias("stripped_acacia", "tree_stripped_acacia", "stripped_acacia")
alias("stripped_acacia_bark", "bark_stripped_acacia", "stripped_acacia_bark")
alias("acaciasapling", "sapling_acacia")
alias("acacialeaves", "leaves_acacia")

alias("birchwood", "wood_birch")
alias("birchtree", "tree_birch")
alias("birchtree_bark", "bark_birch")
alias("stripped_birch", "tree_stripped_birch", "stripped_birch")
alias("stripped_birch_bark", "bark_stripped_birch", "stripped_birch_bark")
alias("birchsapling", "sapling_birch")
alias("birchleaves", "leaves_birch")

alias("junglewood", "wood_jungle")
alias("jungletree", "tree_jungle")
alias("jungletree_bark", "bark_jungle")
alias("stripped_jungle", "tree_stripped_jungle", "stripped_jungle")
alias("stripped_jungle_bark", "bark_stripped_jungle", "stripped_jungle_bark")
alias("junglesapling", "sapling_jungle")
alias("jungleleaves", "leaves_jungle")

alias("sprucewood", "wood_spruce")
alias("sprucetree", "tree_spruce")
alias("sprucetree_bark", "bark_spruce")
alias("stripped_spruce", "tree_stripped_spruce", "stripped_spruce")
alias("stripped_spruce_bark", "bark_stripped_spruce", "stripped_spruce_bark")
alias("sprucesapling", "sapling_spruce")
alias("spruceleaves", "leaves_spruce")
