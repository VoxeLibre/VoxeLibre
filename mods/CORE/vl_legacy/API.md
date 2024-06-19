# Legacy Code Support Functions

## vl\_legacy.deprecated(description, replacement)

Creates a wrapper than logs calls to deprecated function.

Arguments:
* `description`: The text logged when the deprecated function is called.
* `replacement`: The function that should be called instead. This is invoked passing
                 along the parameters exactly as provided.

## vl\_legacy.register\_item\_conversion

Allows automatic conversion of items.

Arguments:
* `old`: Itemstring to be converted
* `new`: New item string

