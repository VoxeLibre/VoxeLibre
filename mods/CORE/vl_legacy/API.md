# Legacy Code Support Functions

## `vl_legacy.deprecated(description, replacement)`

Creates a wrapper that logs calls to deprecated function.

Arguments:
* `description`: The text logged when the deprecated function is called.
* `replacement`: The function that should be called instead. This is invoked passing
                 along the parameters exactly as provided.

## `vl_legacy.register_item_conversion`

Allows automatic conversion of items.

Arguments:
* `old`: Itemstring to be converted
* `new`: New item string

