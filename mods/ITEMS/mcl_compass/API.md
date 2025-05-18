# mcl_compass

# Compass API

## `mcl_compass.compass_works(pos)`
Checks whether compass works at a position.

## `mcl_compass.stereotype = "mcl_compass:" .. stereotype_frame`
Default compass craftitem.  This is also the image that is shown in the inventory.

## `mcl_compass.get_compass_itemname(pos, dir, itemstack)`
Returns the itemname of a compass with needle direction matching the
current compass position.

  pos: position of the compass;
  dir: rotational orientation of the compass;
  itemstack: the compass including its optional lodestone metadata.

## `mcl_compass.get_compass_image(pos, dir)`
-- Returns partial itemname of a compass with needle direction matching compass position.
-- Legacy compatibility function for mods using older api.


