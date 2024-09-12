# mcl_buckets
Adds an API to register buckets to VL

## mcl_buckets.register_liquid(def)

Register a new liquid.

Accepts the following parameters:

* `source_place`: a string or a function
	* `string`: name of the node to place
	* `function(pos)`: will return name of the node to place with pos being the placement position
* `source_take`: table of liquid source node names to take
* `bucketname`: itemstring of the new bucket item
* `inventory_image`: texture of the new bucket item (ignored if itemname == nil)
* `name`: user-visible bucket description
* `longdesc`: long explanatory description (for help)
* `usagehelp`: short usage explanation (for help)
* `tt_help`: very short tooltip help
* `extra_check(pos, placer)`: (optional) additional check before liquid placement (return 2 booleans: (1) whether to place the liquid source and (2) whether to empty the bucket)
* `groups`: optional list of item groups


**Usage example:**

```lua
mcl_buckets.register_liquid({
	bucketname = "dummy:bucket_dummy",
	--source_place = "dummy:dummy_source",
	source_place = function(pos)
		if condition then
			return "dummy:dummy_source"
		else
			return "dummy:dummy_source_nether"
		end
	end,
	source_take = {"dummy:dummy_source"},
	inventory_image = "bucket_dummy.png",
	name = S("Dummy liquid Bucket"),
	longdesc = S("This bucket is filled with a dummy liquid."),
	usagehelp = S("Place it to empty the bucket and create a dummy liquid source."),
	tt_help = S("Places a dummy liquid source"),
	extra_check = function(pos, placer)
		--pos = pos where the liquid should be placed
		--placer who tried to place the bucket (can be nil)

		--no liquid node will be placed
		--the bucket will not be emptied
		--return false, false

		--liquid node will be placed
		--the bucket will be emptied
		return true, true
	end,
	groups = { dummy_group = 123 },
})
```
