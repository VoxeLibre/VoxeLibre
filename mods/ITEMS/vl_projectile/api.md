# Projectiles API

## `vl_projectile.register(entity_name, def)`

Registers a projectile entity.

Arguments:

* `entity_name`: The name the entity will be refered to by the Luanti engine
* `def`: Projectile defintion. Supports all fields that standard Luanti entities support.
         Must include the field `_vl_projectile` for projectile-specific behaviors. These are the supported
         fields:
  * `ignore_gravity`: if true, the projectile will not be affected by gravity
  * `liquid_drag`: if true, apply drag from liquid nodes to the projectile
  * `survive_collision`: if this field is `false` or `nil`, the projectile will be removed after a collision.
  * `sticks_in_players`: if true, the projectile will stick into players after colliding with them.
  * `damages_players`: if true, the projectile will deal damage to players.
  * `damage_groups`: damage group information to use for `punch()`. May be a function of type `function(projectile,
                     entity_def, projectile_def, obj)` that returns dynamic damange group information.
  * `creative_collectable`: if true, projectiles that are marked as `_collectable = true` will be picked up even in
                           creative gamemode.
  * `allow_punching`: will the projectile punch entities it collides with. May be either a boolean or a function
                      of type `function(projectile, entity_def, projectile_def, obj)`.
  * `survive_collision`: will the projectile surive collisions. May be either a boolean or a function of type
                         `function(projectile, entity_def, projectile_def, type, ...)`.
    * If `type` is "node" then the additional parameters `node, node_def` will be provided.
    * If `type` is "entity" then the additional parameter `objet` will be provided.
  * `behaviors`: a list of behavior callbacks that define the projectile's behavior. This mod provides the following
                 behaviors: `vl_projectiles.collides_with_solids`, `vl_projectiles.collides_with_entities`
                            and `vl_projectiles.raycast_collides_with_entities`
  * `maximum_time`: number of seconds until projectiles are removed.
  * `pitch_offset`: a fixed offset to add to the projectile's rotational pitch.
  * `yaw_offset`: a fixed offset to add to the projectile's rotational pitch.
  * `sounds`: sounds for this projectile. All fields take a table with three parameters corresponding to the
              three parameters for `core.play_sound()`. Supported sounds are:
    * `on_collision`: played when no other more specific sound is defined. May be a function of type
                      `function(projectile, entity_def, projectile_def, type, ...)`
    * `on_solid_collision`: played when the projectile collides with a solid node. May be a function of type
        `funciton(projectile, entity_def, projectile_def, type, pos, node, node_def)` with `type = "node"`
    * `on_entity_collision`: played when the projectile collides with another entity. May be a function of type
        `function(projectile, entity_def, projectile_def, type, entity)` with `type = "entity"`
 * `on_collide_with_solid`: callback of type `function(projectile, pos, node, node_def)` used when the projectile
                            collides with a solid node. Requires `vl_projectile.collides_with_solids` in `behaviors` list.
 * `on_collide_with_entity`: callback of type `function(projectile, pos, obj)` used when the projectile collides
                             with an entity. Requires `vl_projectile.collides_with_entities` in `behaviors` list.

## `vl_projectile.update_projectile(self, dtime)`

Performs standard projectile update logic and runs projectile behaviors.

Arguments:
* `self`: The lua entity of the projectile to update
* `dtime`: The amount of time that has passed since the last update. Nomally the `dtime`
           parameter of the entity's `on_step(self, dtime)` callback.

## `vl_projectile.create(entity_id, options)`

Creates a projectile and performs convenience initialization.

Arguments:
* `entity_id`: The name the entity as passed to `vl_projectile.register()`
* `options`: A table with optional parameters. Supported fields are:
  * `dir`: direction the projectile is moving in
  * `velocity`: scalar velocity amount
  * `drag`: scalar resistance to velocity
  * `owner`: passed thru unmodified
  * `extra`: passed thru unmodified

## `vl_projectile.replace_with_item_drop(projectile_lua_entity, pos, projectile_def)`

Removes the projectile and replaces it with an item entity based on either the entity's `_arrow_item` field or
the value `self._vl_projectile.item`.

Arguments:

* `projectile_lua_entity`: the lua entity of the projectile to be replaced.
* `pos`: the position to create the item entity
* `projectile_def`: The projectile's `_vl_projectile` field. If not provided, it will be
   extracted from the projectile's lua entity.

## Custom Projectile Behaviors

The projectile API supports specifying the behaviors that a projectile will exhibit. There are several
standard behaviors provided with the API:

* `vl_projectile.burns`: projectile can be set on fire
* `vl_projectile.collides_with_solids`: handles collisions between projectiles and solid nodes
* `vl_projectile.collides_with_entities`: handles collisions between projectiles and entities by checking nearby entities
* `vl_projectile.has_tracer`: projectile will have a tracer trail when thrown/shot. Projectile can define
   `_vl_projectile.hide_tracer = function(self)` to conditionally hide the tracer.
* `vl_projectile.sticks`: projectile will stick into nodes. Forces `_vl_projectile.sticks_in_nodes = true`
   and `_vl_projectile.survive_collision = true`.
* `vl_projectile.raycast_collides_with_entities`: handles collisions between projectils and entities by performing a raycast
   check along the path of movement.

Custom behaviors can be provided by adding a function with the signature `function(self, dtime, entity_def, projectile_def)`
to the list of behaviors a projectile supports.

Arguments:

* `self`: The lua entity of the projectile
* `dtime`: The amount of time that has passed since the last update. Nomally the `dtime`
           parameter of the entity's `on_step(self, dtime)` callback.
* `entity_def`: The definition from `core.registered_entities` for the projectile.
* `projectile_def`: Same as `entity_def._vl_projectile`



