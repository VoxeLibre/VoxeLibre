# PlayerInfo mod for VoxeLibre

This is a helper mod for other mod to query the nodes around the player.

Every half second the mod checks which node the player is standing on, which
node is at foot and head level and stores inside a global table to be used by mods:

- `mcl_playerinfo[name].node_stand`
- `mcl_playerinfo[name].node_stand_below`
- `mcl_playerinfo[name].node_foot`
- `mcl_playerinfo[name].node_head`

## License
MIT License

