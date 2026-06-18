# vl_attach API

`vl_attach` handles placement and support checks for nodes that attach to
another node face. It compares a support node's attachable surface with an
attached node's required contact area.

Coordinates in surface rectangles use `{u1, v1, u2, v2}`. They are relative to
the support face and use node-box coordinates from `-0.5` to `0.5`.

Each face is described by a sequence of rectangles:

```lua
{
	{u1, v1, u2, v2},
	{u1, v1, u2, v2},
}
```

Multiple rectangles on the same face are treated as one combined attachable
area. This allows shapes such as stairs, walls, panes, and other multipart
nodeboxes to expose several separate support regions.

## Wallmounted Directions

Most API calls use a wallmounted direction (`wdir`) to describe the face used
for attachment:

* `0`: bottom face
* `1`: top face
* `2`-`5`: side faces

The direction describes the attached node's orientation toward its support.

## Node Definition Fields

### `groups.vl_attach = 1`

Marks a node as managed by `vl_attach`. Nodes using `vl_attach.place_attached`
must set this group. `vl_attach.should_drop` uses it to decide whether the node
should use contract-based support validation.

This marks the attached/dependent node, not the support node.

### `_vl_attach_surfaces`

Defines which parts of a support node's faces can accept attachments.
Each face value is a sequence of rectangles.

Accepted forms:

```lua
_vl_attach_surfaces = false
_vl_attach_surfaces = { source = "node_box" }
_vl_attach_surfaces = { faces = { top = {{u1, v1, u2, v2}} } }
_vl_attach_surfaces = function(node, def, wdir) return rects end
```

`false` means the node has no attachable surface.

If this field is absent, full solid opaque nodes default to a full-cube support
surface. Other nodes have no support surface unless they define this field or
allow attachment through `_vl_allow_attach`.

Supported `source` values:

* `"regular"`: full cube.
* `"node_box"`: use `def.node_box`.
* `"selection_box"`: use `def.selection_box`.
* `"collision_box"`: use `def.collision_box`; mechanically supported through
  `core.get_node_boxes`, but prefer visual/support geometry unless collision is
  intentionally the attachment surface.

For `"node_box"` and `"collision_box"`, normal drawtype nodes or nodes without
the requested box fall back to a full cube. If box extraction returns no boxes,
the fallback is also a full cube.

`faces` may be keyed by numeric `wdir` or by face class:

```lua
_vl_attach_surfaces = {
	faces = {
		top = {{-0.5, -0.5, 0.5, 0.5}},
		side = {{-0.25, -0.5, 0.25, 0.5}},
		[0] = false,
	},
}
```

Face classes are `bottom`, `top`, and `side`.

### `_vl_attach_contract`

Defines the contact area required by an attached node. It uses the same forms
as `_vl_attach_surfaces`. Each face value is a sequence of rectangles, and all
rectangles must fit inside the support surface:

```lua
_vl_attach_contract = { faces = { top = {{-1/16, -1/16, 1/16, 1/16}} } }
_vl_attach_contract = { source = "selection_box" }
_vl_attach_contract = function(node, def, wdir) return rects end
```

If this field is absent, `vl_attach` falls back to the attached node's
`selection_box`, then `node_box`, if present.

### `_vl_allow_attach`

Support-side allow/deny hook.

```lua
_vl_allow_attach = true
_vl_allow_attach = false
_vl_allow_attach = function(node, def, wdir, attached_node, attached_def)
	return true
end
```

Callback parameters:

* `node`: support node.
* `def`: support node definition.
* `wdir`: wallmounted attachment direction.
* `attached_node`: node being attached.
* `attached_def`: attached node definition.

If this returns `true` and the support has `_vl_attach_surfaces` while the
attached node has `_vl_attach_contract`, `vl_attach` still refines the result
through `vl_attach.check_geometry`. A callback may call
`vl_attach.check_geometry` itself when it needs custom direction filtering
before geometry comparison.

### `_vl_attach_allow`

Attached-node allow/deny hook. It has the same boolean/function form and
callback signature as `_vl_allow_attach`, but it is declared on the attached
node definition.

Use this only when the attached node has placement rules that are not expressible
by `_vl_attach_contract` alone.

### `_vl_attach_fixed_wdir`

Fixed wallmounted direction for attached nodes without wallmounted/facedir
orientation. Used by fixed-orientation nodes such as floor-only pressure plates.

```lua
_vl_attach_fixed_wdir = 1
on_place = vl_attach.place_attached_fixed
```

### `_vl_attach_make_placed_node`

Optional callback used by `vl_attach.place_attached` to convert the item being
placed into the concrete node that should be checked and placed.

```lua
_vl_attach_make_placed_node = function(placed_node, placer, dir, itemstack, pointed_thing, under_node)
	placed_node.name = "example:wall_variant"
	return placed_node
end
```

Return `nil` to reject placement.

Callback parameters:

* `placed_node`: initial node table with `name` and `param2`.
* `placer`: player object.
* `dir`: vector from placement target toward the support.
* `itemstack`: item being placed.
* `pointed_thing`: pointed thing used for this placement attempt.
* `under_node`: support candidate node.

### `_vl_attach_get_supports`

Optional callback for attached nodes that can be supported by additional nodes
besides the node in their main attachment direction.

```lua
_vl_attach_get_supports = function(pos, node, def, wdir, dir)
	return {
		{ pos = vector.offset(pos, 0, 1, 0), wdir = 0 },
	}
end
```

Each returned support may contain:

* `pos`: support node position.
* `node`: support node; used instead of reading `pos`.
* `wdir`: support direction; defaults to the attached node's `wdir`.
* `attached_node`: node to validate; defaults to the attached node.
* `attached_def`: definition to validate; defaults to the attached node def.

## Functions

### `vl_attach.check_geometry(node, def, wdir, attached_node, attached_def)`

Returns `true` when the attached node's contract rectangles fit inside the
support node's surface rectangles for `wdir`.

This function does not apply support or attached policy callbacks. Use
`vl_attach.check_allowed` for normal placement/support checks.

### `vl_attach.check_allowed(node, wdir, attached_node, attached_def)`

Returns whether `attached_node` may attach to support `node` at `wdir`.

Order of checks:

1. support-side `_vl_allow_attach`, if present.
2. attached-side `_vl_attach_allow`, if present.
3. geometry comparison when the attached node has `_vl_attach_contract`.

If no policy or contract applies, returns `false`.

### `vl_attach.should_drop(pos, node)`

Returns `true` if `node` at `pos` is no longer supported.

For `groups.vl_attach = 1` nodes, this uses the `vl_attach` contract system.
For legacy nodes, it still supports the older groups:

* `attached_node_facedir`
* `attached_node_wallmounted`
* `supported_node`
* `supported_node_facedir`
* `supported_node_wallmounted`

### `vl_attach.place_attached(itemstack, placer, pointed_thing, idef, make_placed_node)`

Generic `on_place` callback for wallmounted attached nodes.

`idef` and `make_placed_node` are optional. If `make_placed_node` is not
provided, `_vl_attach_make_placed_node` from the item definition is used.

This function:

1. handles right-click interaction with the pointed node;
2. builds the concrete placed node;
3. checks support with `vl_attach.check_allowed`;
4. rejects placement if the node would immediately drop;
5. places the node with the final node name and param2.

### `vl_attach.place_attached_fixed(itemstack, placer, pointed_thing, idef)`

`on_place` helper for nodes with `_vl_attach_fixed_wdir`.

### `vl_attach.place_attached_facedir(itemstack, placer, pointed_thing, idef)`

`on_place` helper for attached nodes that use facedir param2. The facedir is
chosen from the clicked face and player yaw.
