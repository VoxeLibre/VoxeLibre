This mod adds a monster spawner for MineClone 2.
Monsters will appear around the monster spawner in semi-regular intervals.

This mod is originally based on the mob spawner from Mobs Redo by TenPlus1
but has been modified quite a lot to fit the needs of MineClone 2.

Players can get a monster spawner by `giveme` and is initially empty after
placing.

## Programmer notes
To set the mob spawned by a monster spawner, first place the monster spawner
(e.g. with `minetest.set_node`), then use the function
`mcl_mobspawners.setup_spawner` to set its attributes. See the comment
in `init.lua` for more info.

## License (code and texture)
MIT License
