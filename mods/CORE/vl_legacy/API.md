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

## `vl_legacy.convert_node(pos, node)`

Converts legacy nodes to newer versions.

Arguments:
* `pos`: Position of the node to attempt conversion
* `node`: Node definition to convert. The node will be loaded from map data if `nil`.

The node definition for the old node must contain the field `_vl_legacy_convert` with
a value that is either a `function(pos, node)` or `string` for this call to have any
affect. If a function is provided, the function is called with `pos` and `node` as
arguments. If a string is provided, a node name conversion will occur.

This mod provides an LBM and ABM that will automatically call this function for nodes
with `group:legacy` set.

