# Oxidization API for VoxeLibre
This mods adds the oxidization api, so that modders can easily use the same features that copper uses.

## API
To take advantage of the actual oxidization, put `oxidizable = 1` into the list of groups for the oxidizable node.
You would also need to put `_mcl_oxidized_variant = itemstring of node this node will oxidize into` into the node definition.
For example, a copper block oxidizes into exposed copper, so the defintion would be `_mcl_oxidized_variant = "mcl_copper:block_exposed"`.

To utilize the ability to wax the block for protection from oxidization, put `mcl_waxed_variant = item string of waxed variant of node` into the node definition table.
For example, Copper Blocks have the definition arguement of `_mcl_waxed_variant = "mcl_copper:waxed_block"`.

For waxed nodes, scraping is easy. Start by putting `waxed = 1` into the list of groups of the waxed node.
Next put `_mcl_stripped_variant = item string of the unwaxed variant of the node` into the defintion table.
Waxed Copper Blocks can be scrapped into normal Copper Blocks because of the definition `_mcl_stripped_variant = "mcl_copper:block"`.

## Seasons

If mcl_oxidation detects the Seasons mod, you may define the seasons of the year in which the node is *not* allowed to oxidize. Here is an example node definition that effectively tells oxidation mod that this node is only allowed to oxidize in the winter:
`_mcl_oxidized_season_disallowed = {"spring", "summer", "fall"},`
