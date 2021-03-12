# mcl_buckets
Add an API to register buckets to mcl

## mcl_buckets.register_liquid(def)

Register a new liquid
Accept folowing params:
* source_place = a string or function.
	* string: name of the node to place
	* function(pos): will returns name of the node to place with pos being the placement position
* source_take = table of liquid source node names to take
* itemname = itemstring of the new bucket item (or nil if liquid is not takeable)
* inventory_image = texture of the new bucket item (ignored if itemname == nil)
* name = user-visible bucket description
* longdesc = long explanatory description (for help)
* usagehelp = short usage explanation (for help)
* tt_help = very short tooltip help
* extra_check(pos, placer) = optional function(pos) which can returns false to avoid placing the liquid. Placer is object/player who is placing the liquid, can be nil.
* groups = optional list of item groups

This function can be called from any mod (which depends on this one)