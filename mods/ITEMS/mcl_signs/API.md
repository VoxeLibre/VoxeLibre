# `mcl_signs` API Reference

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
* `mcl_signs.create_lines(str)`
	* Converts a string to a line-broken (with hyphens) sequence table of UTF-8
	  codepoints
* `mcl_signs.generate_line(codepoints, ypos)`
	* Generates a texture string from a codepoints sequence table (for a single
	  line) using the character map
	* `ypos` is the Y tile coordinate offset for the texture string to specify
* `mcl_signs.generate_texture(data)`
	* Generates a texture string from a sign data table
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

* **Column 1:** The literal (as-is) glyph. Only [precomposed characters](https://en.wikipedia.org/wiki/Precomposed_character) are supported
* **Column 2:** Name of the texture file for this character minus the ".png"
  suffix (found in the "textures/" sub-directory in root)
* **Column 3:** Currently ignored. This is reserved for character width in
  pixels in case the font will be made proportional

All character textures must be 12 pixels high and 5 or 6 pixels wide (5
is preferred).

Can be accessed by other mods via `mcl_signs.charmap["?"]`.
