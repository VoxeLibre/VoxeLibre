# mcl_init

Initialization of VoxeLibre, in particular some shared variables and utility functions exposed via `mcl_vars`.

## `get_node_name`

This is an interim API while we still support Luanti versions that do not expose `core.get_node_raw`.
We would like to use that function because it generates fewer Lua tables, and hence causes less garbage collection,
yielding better performance. The current `get_node_name` API is a middle-ground that covers many use cases
of that API, while having little overhead over the old `core.get_node`, nor the new `core.get_node_raw` API then.

- `mcl_vars.get_node_name(pos)` returns the node *name*, param1 and param2 at position `pos`.

- `mcl_vars.get_node_name_raw(x, y, z)` returns the node *name*, param1 and param2 at position (x,y,z).

- `mcl_vars.get_node_raw(x, y, z)` returns the *content ID*, param1 and param2 at position (x,y,z).

Which version to use:

1. if you are working with content ids (integers), use `get_node_raw`.
2. if you work with node names, and vectors, use `get_node_name`.
3. if you work with node names and integer coordinate loops, use `get_node_name_raw`.
4. if you need dense access on a larger volume, use a Lua Voxel Manipulator.

Overhead:

On current Luanti, without trusted mods, all functions use `get_node`, and the performance will be similar to
using `get_node`.

When `core.get_node_raw` becomes a public API, or when the trusted mod hack is enabled, the first two perform similar
to using `core.get_node_raw` followed by an content ID to node name lookup (which is supposedly a simple array access).
While the function `get_node_raw` becomes an alias for `core.get_node_raw`.


## Optimized LuaJIT parameters

As of 2024, the default LuaJIT parameters are not well tuned, *depending on the version you use*.

According to <https://luajit.org/running.html>, standard LuaJIT uses:

| maxtrace   |  1000 | Max. number of traces in the cache                  |
| maxrecord  |  4000 | Max. number of recorded IR instructions             |
| maxirconst |   500 | Max. number of IR constants of a trace              |
| minstitch  |     0 | Min. # of IR ins for a stitched trace.              |
| maxmcode   |   512 | Max. total size of all machine code areas in KBytes |

However, the openresty branch uses more sane defaults for a long time <https://github.com/openresty/luajit2/blob/v2.1-agentzh/src/lj_jit.h#L117>:

| maxtrace   |  8000 | Max. number of traces in the cache                  |
| maxrecord  | 16000 | Max. number of recorded IR instructions             |
| maxirconst |   500 | Max. number of IR constants of a trace              |
| minstitch  |     3 | Min. # of IR ins for a stitched trace.              |
| maxmcode   | 40960 | Max. total size of all machine code areas in KBytes |

Mineclonia contributor "halon" investigated this, and
increasing these values appears to be beneficial for improving the performance of Luanti,
although users of openresty (e.g., on Debian GNU/Linux) may not notice a difference.

TODO: every few years, the situation should be re-assessed. For example, Luanti upstream might set improved values.
Unfortunately, it does not appear that we can query the values, only set them.


