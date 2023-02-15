# Mineclone Oxidization API
This document explains the API of this mod.

### `register_oxidation_abm(node_name)`
Registers the ABM for the oxidization of nodes. It expects that the variable
`_mcl_oxidized_variant` be set with the node name of the oxidized version. 

#### Parameters:
`node_name`: the name of the node to check, and to oxidize. 

#### Usage:
To use this API, add `_mcl_oxidized_variant = my_oxidized_node_name,` to the node 
definition of the desired node, and then call 
`register_oxidation_abm(my_oxidizable_node_abm, my_oxidizable_node)` in your code.
This abm will swap out the nodes with the more oxidized version of the node, one 
stage at a time.

#### Example of Usage:
From mcl_copper:
```lua 
local block_oxidation = {
    { "", "_exposed" },
    { "_cut", "_exposed_cut" },
    { "_exposed", "_weathered" },
    { "_exposed_cut", "_weathered_cut" },
    { "_weathered", "_oxidized" },
    { "_weathered_cut", "_oxidized_cut" }
}

for _, b in pairs(block_oxidation) do
    register_oxidation_abm("mcl_copper:block" .. b[1], "mcl_copper:block" .. b[2])
end
```

### Oxidization Removal
Make sure that the Oxidized Node has this in its definition:

`_mcl_stripped_variant = my_less_oxidized_node,`

And axes in mineclone will scrape the oxidization level down, usually by one stage.
An example of usage: `_mcl_stripped_variant = "mcl_copper:block",`

Implementation of other tools for scraping does not yet exist, but may in the future.

