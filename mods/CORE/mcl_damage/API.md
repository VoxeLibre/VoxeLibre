# mcl_damage
This mod provide damage handling.

## mcl_damage.register_modifier(func, priority)
Register damage modifier.
* func: function, called with (obj, damage, reason)

    This function can modify damage, based on mcl reason.

* priority: int, define call order of registered functions
  
    You should make use higher values for important or most used functions.
