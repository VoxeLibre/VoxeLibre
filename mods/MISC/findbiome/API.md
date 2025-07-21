# Find Biome API

This mod has a single public function:

## `findbiome.find_biome(pos, biomes, res, checks)`

Attempts to find a position of any biome listed in `biomes`, starting the search from `pos`.
The algorithm will start check positions around `pos`, starting at `pos` and extend its
search outwards. As soon as any of the listed biomes is found, the algorithm terminates
and the biome position is returned.

### Parameters

* `pos`: Position at where to start the search
* `biomes`: List of the technical names of the biomes to search for
* `res`: (optional): Size of search grid resolution (smaller = more precise, but also smaller area) (default: 64)
* `checks`: (optional): Number of points checked in total (default: 16384)

### Return value

Returns `<biome position>, <success>`.

* `<success>` is `true` on success and `false` on failure.
* `<biome position>` is the position of a found biome or `nil` if none was found

### Additional notes

* This function checks nodes on a square spiral going outwards from `pos`
* Although unlikely, there is *no 100% guarantee* that the biome will always be found if
  it exists in the world. Very small and/or rare biomes tend to get “overlooked”.
* The search might include different Y levels than provided in `pos.y` in order
  to find biomes that are restricted by Y coordinates
* If the mapgen `v6` is used, this function only works if the mod `biomeinfo` is
  active, too. See the `biomeinfo` mod for more information
* Be careful not to check too many points, as this can lead to potentially longer
  searches which may freeze the server for a while