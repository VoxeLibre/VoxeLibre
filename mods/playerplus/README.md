# PlayerPlus mod for MineClone 2

## Features

- Hurt players touching cacti (0.5 hearts / 0.5s)
- Suffocation: Hurt players who have their head inside a solid block (0.5 hearts / 0.5s)

Suffocation *not* dealt to player with the `noclip` privilege.

## Notes
This mod is based on PlayerPlus [`playerplus`] by TenPlus1. It behaves a bit
differently than the original, but the API is fully compatible.

## API

Every half second the mod checks which node the player is standing on, which
node is at foot and head level and stores inside a global table to be used by mods:

- `playerplus[name].nod_stand`
- `playerplus[name].nod_foot`
- `playerplus[name].nod_head`

Setting the group `disable_suffocation=1` disables suffocation for nodes which
would otherwise deal suffocation damage.

## License
WTFPL.

