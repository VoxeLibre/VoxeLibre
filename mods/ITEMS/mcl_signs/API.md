# `mcl_signs` API Reference

## Specifics

The signs code internally uses Lua lists (array tables) of UTF-8 codepoints to
process text, as Lua 5.1 makes too many assumptions about strings that don't
apply to Unicode text.

From [Lua 5.1 Reference Manual, §2.2](https://www.lua.org/manual/5.1/manual.html#2.2):

> _String_ represents arrays of characters. Lua is 8-bit clean: strings can
> contain any 8-bit character, including embedded zeros (`'\0'`).

This is OK when all you have is ASCII, where each character really does take up
just 8 bits, or 1 byte. And the code prior to the rework even made some
workarounds to support 2 byte values for the Latin-1 character set. But a UTF-8
character can be up to 4 bytes in size! And when we try to treat a 4 byte
character as a 2 byte one, we get 2 invalid characters! Unthinkable!

Luckily, modlib's `utf8.lua` comes to rescue with its codepoint handlers. We
use `utf8.codes` to cycle through user input strings and convert them to the
codepoint lists mentioned previously, which will be referred to here as
_UTF-8 strings_, or _u-strings_ for short.


## Functions

* `mcl_signs.register_sign(name, color, [definition])`
	* `name` is the part of the namestring that will follow `"mcl_signs:"`
	* `color` is the HEX color value to color the greyscale sign texture with.\
	  **Hint:** use `""` or `"#ffffff"` if you're overriding the texture fields
	  in sign definition
	* `definition` is optional, see section below for reference
* `mcl_signs.update_sign(pos)`
	* Updates the sign node and entity at `pos`
* `mcl_signs.get_text_entity(pos, [force_remove])`
	* Finds and returns ObjectRef for text entity for the sign at `pos`
	* `force_remove` automatically removes the found entity if truthy
* `mcl_signs.string_to_ustring(str, [max_characters])`
	* `str` is the string to convert to u-string
	* `max_characters` is optional, defines the codepoint index to stop reading
	  at. 256 by default
* `mcl_signs.ustring_to_string(ustr)`
	* Converts a u-string to string. Used for displaying text in sign formspec
* `mcl_signs.ustring_to_line_array(ustr)`
	* Converts a u-string to line-broken list of u-strings aka _a line array_
	* Behavior on line overflow is controlled by the `mcl_signs_wrap_mode` enum
* `mcl_signs.generate_line(ustr, ypos)`
	* Generates a texture string from a u-string for a single line using the
	  character map
	* `ypos` is the Y tile coordinate offset for the texture string to specify
* `mcl_signs.generate_texture(data)`
	* Generates a texture string for the sign text entity from data table
* `mcl_signs.show_formspec(player, pos)`
	* Shows the formspec of the sign at `pos` to `player` if protection checks
	  pass.

## Sign definition

```lua
{
	-- This can contain any node definition fields which will ultimately make
	-- up the sign nodes.
	-- Usually you'll want to at least supply `description`:
	description = S("Significant Sign"),

    -- If you don't want to use texture coloring, you'll have to supply the
	-- textures yourself:
	tiles = {"vl_significant_sign.png"},
	inventory_image = "vl_significant_sign_inv.png",
	wield_image = "vl_significant_sign_inv.png",
}
```

## Character map (`characters.tsv`)

It's a UTF-8 encoded text file that contains metadata for all supported
characters. Despite its file extension and the theoretical possibility of
opening it in a spreadsheet editor, it's still plaintext values separated by
`\t` (tab idents). The separated values are _columns_, and the lines they are
located at are _rows_. It's customary that different character sets are
separated with an empty line for readability.

The format expects 1 row with 3 columns per character:

* **Column 1:** The literal (as-is) glyph. Only [precomposed characters](https://en.wikipedia.org/wiki/Precomposed_character)
  are supported for diacritics
* **Column 2:** Name of the texture file for this character minus the ".png"
  suffix (found in the `textures/` sub-directory in root)
* **Column 3:** Currently ignored. This is reserved for character width in
  pixels in case the font will be made proportional

All character textures must be 12 pixels high and 5 or 6 pixels wide (5
is preferred).

Can be accessed by other mods via `mcl_signs.charmap[<utf-8 codepoint>]`.
