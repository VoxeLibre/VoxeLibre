# `mcl_signs`

* Originally based on reworked signs mod by PilzAdam (<https://forum.luanti.org/viewtopic.php?t=3289>)
* Adapted for MineClone2 by Wuzzy
* Later massively extended by Michieal
* Mostly rewritten for Mineclonia and simplified by cora
* Reworked for VoxeLibre with UTF-8 support by rudzik8
* Word wrap algorithm improved by kno10


## Characters

All characters are mapped to their textures in `characters.tsv`. See `API.md`
for technical details.

Currently supported character sets:

* [ASCII](https://en.wikipedia.org/wiki/ASCII)
* [Latin-1](https://en.wikipedia.org/wiki/ISO/IEC_8859-1) (Western European)
* [Latin-2](https://en.wikipedia.org/wiki/ISO/IEC_8859-2) (Central/Eastern European)
* [Latin-3](https://en.wikipedia.org/wiki/ISO/IEC_8859-3) (South European)
* [Latin-4](https://en.wikipedia.org/wiki/ISO/IEC_8859-4) (North European)
* [Latin-5/Cyrillic](https://en.wikipedia.org/wiki/ISO/IEC_8859-5)
  * with additional glyphs and diacritics
* [Latin-7/Greek](https://en.wikipedia.org/wiki/ISO/IEC_8859-7)
* Other math-related/miscellaneous characters


## License

**Code:** MIT
* `utf8.lua` is from `modlib`, by Lars Mueller alias LMD or appguru(eu) [(source)](https://github.com/appgurueu/modlib/blob/master/utf8.lua)
* See `LICENSE` file for details

**Font:** CC0
* Originally by PilzAdam
* Modified and massively extended by rudzik8
* Can be found in the `/textures` sub-directory of game root, prefixed with `_`
* See <https://creativecommons.org/publicdomain/zero/1.0/> for details

**Models:** GPLv3
* by 22i: <https://github.com/22i/amc>
* See <https://www.gnu.org/licenses/gpl-3.0.html> for details
