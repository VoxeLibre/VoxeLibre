This mod automatically adds groups to items based on item metadata.

Specifically, this mod has 2 purposes:
1) Automatically adding the group “solid” for blocks considered “solid” in Minecraft.
2) Generating digging time group for all nodes based on node metadata (it's complicated)

This mod also requires another mod called “mcl_autogroup” to function properly.
“mcl_autogroup” exposes the API used to register digging groups, while this mod
uses those digging groups to set the digging time groups for all the nodes and
tools.

See init.lua for more infos.

The leading underscore in the name “_mcl_autogroup” was added to force Luanti to load this mod as late as possible.
As of 0.4.16, Luanti loads mods in reverse alphabetical order.
