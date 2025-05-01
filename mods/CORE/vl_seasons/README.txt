Seasons for Voxelibre
by SmokeyDope

The aim of this mod is to introduce a variety of nodes, functions, and entities related to the concept of seasons. The goal is to give voxelibre worlds a more dynamic and lively feeling to them.

## Chat Command usage
various chat command have been added to help with playtesting and development of things affected by season.

/season gives the current season and effective day.
/season X sets the effective day to a manual override value. e.g /season 55 for winter, requires server privs
/season reset disables the override, resets effective day back to being based and updated on real-day.

File Descriptions:
init.lua for potential LBMs, ABMs, important first initializations, and then triggering other mod files.
season-cycle.lua contains functions responsible for defining seasonal cycles and the amount of days that fall within them.
chatcommands.lua contains chat commands for displaying season information and some debug tools to set season day for development.

## version and licensing
This version of Seasons for VoxeLibre was modified for external compatability with the mcl_oxidation mod to maintain the games existing file system structure and not overshadow the work of original oxidation authors, whos precursor efforts on the oxidation mechanisms was vital to helping spark the idea of weathered_nodes and seasons which eventually made this a reality. This version of seasons does not contain its own swap triggers, instead the oxidation mod has been rewritten to handle seasons as an optional dependency to allow for additional optional checks in oxidation code.

I (SmokeyDope) Release this version of the Seasons Mod for the Voxelibre game project. Its source-code is licensed under GPL-3.0 or later. All media assets made by me for this version of the seasons mod project are released under CC0, any asset not released by me will/must fall under a permissive copyleft license compatable with the project such as cc0 or cc-by-sa-3.0 or later. All external assets must be linked with source explicitly attributed in documentation. It is *highly recommended* for any future persons adapting this version of seasons to fall within these licensing and attribution guidelines when making additions/changes. I reserve the right to re-release the seasons mod for various games with or without similar swapping mechanisms built from scratch into the mod internally, and to license alternative versions of the mod differently upon their release as the author deems appropriate.
