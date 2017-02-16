Modpack - 3d Armor
==================

[mod] Unified Skins [unified_skins]
-----------------------------------

depends: default

A 3d character model re-texturing api used as the framework for this modpack.

Compatible with player skins mod [skins] by Zeg9 and Player Textures [player_textures] by sdzen.

Note: Currently only supports 64x32px player skins.

[mod] Visible Wielded Items [wieldview]
---------------------------------------

depends: unified_skins

Makes hand wielded items visible to other players.

Note: Currently only supports 16x16px texture packs, sorry!

[mod] Visible Player Armor [3d_armor]
-------------------------------------

depends: unified_skins, inventory_plus

Adds craftable armor that is visible to other players. Each armor item worn contributes to
a player's armor group level making them less vulnerable to weapons.

Armor takes damage when a player is hurt, however, many armor items offer a 'stackable'
percentage chance of restoring the lost health points.

[mod] Shields [shields]
-------------------------------------

depends: 3d_armor

Originally a part of 3d_armor, shields have been re-included as an optional extra.
If you do not want shields then simply remove the shields folder from the modpack.
