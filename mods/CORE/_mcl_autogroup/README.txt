This mod automatically adds groups to items based on item metadata.

This mod has a few purposes:
1) Automatically adding some groups like “solid” "opaque" and "creative_breakable" depending on node definitions.
2) Generating digging groups for variable speed and item drops based on node defintions.
3) Ensuring that all nodes that are neither liquids nor unbreakable/indestructible can be dug.


This mod also requires another mod called “mcl_autogroup” to function properly.
“mcl_autogroup” exposes the API used to register digging groups, while this mod
uses those digging groups to set the digging time groups for all the nodes and
tools.

See init.lua for more infos.

The leading underscore in the name “_mcl_autogroup” was added to force Luanti to load this mod as late as possible.
As of 0.4.16, Luanti loads mods in reverse alphabetical order.
