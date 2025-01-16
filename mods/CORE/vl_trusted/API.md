# vl_trusted

This module does not provide a public API.

The optimized function calls are only available via existing APIs.

We currently implement one feature that require trusted access:

## Access to `core.get_node_raw`

The `core.get_node_raw` function has been added to Luanti in version 5.9.0, but as of 5.10 is not a public API,
although we have asked for this to be made public: <https://github.com/minetest/minetest/issues/15317>

This function is beneficial as it does not create a table for the return, which reduces the amount of garbage collection necessary,
in particular as LuaJIT's allocation sinking does not appear to eliminate these, unfortunately.

For compatibility, we expose this with slightly different semantics, which are a tradeoff between using the new API when available
(or exposed via this trusted module), and having to be able to fall back to the regular `core.get_node` call.

TODO: when the minimum version of Luanti has a public version of the API, these wrappers should likely be removed and the unmodified
`core.get_node_raw` should be used where possible.

