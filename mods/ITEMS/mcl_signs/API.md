# `mcl_signs` API

## Functions

* `mcl_signs.register_sign(name, color, [definition])`

## Sign definition

```lua
{
	-- This can contain any node definition fields which will ultimately make up the sign nodes.
	-- Usually you will want to at least supply "description" and "_doc_items_longdesc".
}
```

## `characters.txt`

It's a UTF-8 encoded text file that contains metadata for all supported
characters. It contains a sequence of info blocks, one for each character. Each
info block is made out of 3 lines:

* **Line 1:** The literal UTF-8 encoded character
* **Line 2:** Name of the texture file for this character minus the ".png"
  suffix (found in the "textures/" sub-directory in root)
* **Line 3:** Currently ignored. Previously this was for the character width
  in pixels

After line 3, another info block may follow. This repeats until the end of the file.

All character files must be 5 or 6 pixels wide (5 pixels are preferred).
