local function alias(old, new)
	core.register_alias("mcl_cherry_blossom:"..old, "mcl_cherry_blossom:"..new)
end

alias("cherryleaves", "leaves_cherry")
alias("cherrytree", "tree_cherry")
alias("cherrywood", "wood_cherry")

function mcl_cherry_blossom.generate_cherry_tree(pos)
	local def_schematic = vl_trees.registered_woods["cherry"].schematic

	local schematic = type(def_schematic) == "function" and def_schematic(pos)
		or type(def_schematic) == "table" and next(def_schematic) ~= nil and def_schematic[math.random(#def_schematic)]
		or def_schematic
	if not schematic then return end

	return vl_trees.place_schem(pos, schematic)
end
