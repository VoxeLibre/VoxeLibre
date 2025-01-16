# mcl_init

Initialization of VoxeLibre, in particular some shared variables exposed via `mcl_vars`.


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


