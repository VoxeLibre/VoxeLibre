# PlayerPlus mod for MineClone 2

## Features

- Hurt players touching cacti (0.5 hearts / 0.5s)
- Suffocation: Hurt players who have their head inside a solid block (0.5 hearts / 0.5s)
- Exhaustion for swimming and jumping
- Particle effects

Suffocation *not* dealt to player with the `noclip` privilege.

## Notes
This mod is based on PlayerPlus [`playerplus`] by TenPlus1. It is now
very different than the original, no compability is intended.
See also `mcl_playerinfo` for the player node info.

## API

Setting the group `disable_suffocation=1` disables suffocation for nodes which
would otherwise deal suffocation damage.

## License
MIT License

