# mcl_damage
This mod provide damage handling.

## mcl_damage.register_modifier(func, priority)
Register damage modifier.
* func: function, called with (obj, damage, reason)

    This function can modify damage, based on mcl reason.

* priority: int, define call order of registered functions
  
    You should make use higher values for important or most used functions.

## mcl_damage.from_mt(mt_reason)
Convert mt damage reason (nil, fall, drown, punch, node_damage) to mc like reason.
* mt_reason: table, mt damage reason