# `vl_hudbars` mod API

This mod is used for registering hudbars to display stats e.g. health, breath on the player's screen for VoxeLibre

## Features:
* Customisable texture and size per-hudbar
* Settings such as hudbar icon size, length and the area of the screen they are in are settings which are not configurable per-hudbar
* Dynamically resizeable and repositioning
* Multi-part compound hudbars with different sections
* Choice of absolute (resizing) or proportional

## Types of hudbars

### Absolute vs Proportional
Absolute hudbars are like the VL health hudbar - they can expand into multiple layers as necessary if their maximum value increases.
Proportional hudbars have a fixed size, and they display their value as a fraction of the maximum. Proportional hudbars always have a size which is an integer number of layers.

### Simple vs Compound
If you want to register a simple hudbar, don't use a compound hudbar.
However, compound hudbars can be used to make hudbars more detailed - the VL health hudbar is compound because it contains multiple sections - the main red health section, and the absorption section, which has a different icon, but displays in line with the main health.

### Squishing
All hudbars are squished if they get too many layers, this is not configurable per-hudbar.
When being squished, layers can overlap, so the correct z_index_step should be used.

## API Functions

### `vl_hudbars.register_hudbar(hudbar_params)`
Register a new hudbar which can be subsequently used for players
All types of hudbar can have fields:
* `identifier`: string (required) - the technical name of this hudbar
* `sort_index`: number (default 0) - the priority in terms of y-positioning relative to other hudbars; setting this value lower will make the hudbar lower down on average
* `on_right`: bool (default false) - which side of the screen to put this hudbar; false puts it on left, true on right
* `direction`: number (default 0) - the direction to display this hudbar; 0 is left-to-right, 1 is right-to-left, other values are not allowed
* `layer_gap`: number (default 4) - the number of pixels gap to put by default between layers of this hudbar - will be decreased by hudbar squishing
* `scale_y`: number (default 1) - the aspect ratio of the icons on the hudbar, i.e. height/width of icon texture
* `value_type`: string (default "absolute") - can take "absolute" or "proportional"; see above
* `is_compound`: bool (default false) - whether this hudbar is compound or simple; see above *WARNING: Proportional compound hudbars are unused in the game itself and are considered an experimental feature. Bugs are possible.*
* `take_up_space`: bool (default true) - whether this hudbar should cause other hudbars to reposition or whether they may be drawn over this hudbar *WARNING: Untested*
* `value_scale`: number (default 1) - for "absolute"-type hudbars, how much one half-texture represents in value
* `round_to_full_texture`: bool (default false) - whether this hudbar should be forced to a whole number of background textures displayed, even if its maximum number of half-textures is odd; applies to all parts of the hudbar
* `z_index`: number (default 99) - the z-index of the first layer of this hudbar (see MT Lua API docs)

Fields applicable to simple-type hudbars:
* `default_max_val`: number (default 1) - the starting maximum value of this hudbar when it is instantiated (don't set to 0 for "proportional"-type hudbars)
* `default_value`: number (default 0) - the starting value of this hudbar when it is instantiated
* `default_hidden`: bool (default false) - whether to automatically hide this hudbar when it is instantiated
* `icon`: texture string (required) - the default 'on' texture of this hudbar when it is instantiated
* `bgicon`: texture string (required) - the default 'off' texture of this hudbar when it is instantiated
* `layers`: number (default 1) - for "proportional"-type hudbars, how many layers this hudbar should have
* `z_index_step`: number (default -1) - how much to change z-index by each layer; useful for changing how a hudbar should look when squished

Fields applicable to compound-type hudbars
* `parts`: table (required) - the table of parts this hudbar should have; the keys are part identifiers and the values are tables defining the parts:
    * `default_max_val`: number (default 1) - the starting maximum value of this part when it is instantiated (don't set to 0 for "proportional"-type hudbars)
    * `default_value`: number (default 0) - the starting value of this part when it is instantiated
    * `default_hidden`: bool (default false) - whether to automatically hide this part when it is instantiated
    * `icon`: texture string (required) - the default 'on' texture of this part when it is instantiated
    * `bgicon`: texture string (required) - the default 'off' texture of this part when it is instantiated
    * `layers`: number (default 1) - for "proportional"-type hudbars, how many layers this part should have
    * `part_sort_index`: number (default 0) - the priority in terms of y-positioning this part has in the hudbar
    * `take_up_space`: bool (default true) - whether this part should cause other parts to reposition or whether they may be drawn over this part *WARNING: Untested*
    * `z_index_offset`: number (default -1) - how much to change z-index by at the start of drawing this part (set to -1 because when a part starts on a new layer the normal z_index_step is not applied)
    * `z_index_step`: number (default -1) - how much to change z-index by each layer; useful for changing how a part should look when squished (recommended to set to same for all parts, especially for "absolute"-type hudbars)

### `vl_hudbars.init_hudbar(player, identifier)`
Instantiate a hudbar for a particular player
* `player`: ObjectRef of a player - if it is anything else the function is no-op
* `identifier`: string - the identifier of the hudbar to instantiate; must have been registered previously
Should reset hudbar to default values if this function has previously been called *WARNING: Untested*

### `vl_hudbars.remove_hudbar(player, identifier)`
Removes a hudbar for a player *WARNING: Untested*
If the player does not have this hudbar instantiated this function is no-op

### `vl_hudbars.change_value(player, identifier, value, max_val, part)`
Change the value and maximum value of a hudbar for a player
* `player`: ObjectRef of a player - if it is anything else the function is no-op
* `identifier`: string - the identifier of the hudbar to change the value of; must have been registered previously
* `value`: number or nil - the new value of this hudbar, remains unchanged if nil
* `max_val`: number or nil - the new maximum value of this hudbar, remains unchanged if nil
* `part`: string or nil - the part of the hudbar to change the value of (for compound hudbars)
If the player does not have this hudbar instantiated this function is no-op

### `vl_hudbars.hide(player, identifier, part)`
Hide a hudbar for a player
* `player`: ObjectRef of a player - if it is anything else the function is no-op
* `identifier`: string - the identifier of the hudbar to hide; must have been registered previously
* `part`: string or nil - the part of the hudbar to hide (for compound hudbars); if left nil all parts will be hidden
If the player does not have this hudbar instantiated this function is no-op

### `vl_hudbars.show(player, identifier, part)`
Show a hudbar for a player

### `vl_hudbars.set_icon(player, identifier, new_icon, part)`
Change the icon of a hudbar
* `player`: ObjectRef of a player - if it is anything else the function is no-op
* `identifier`: string - the identifier of the hudbar to change icon of; must have been registered previously
* `new_icon`: texture string - the new texture to use as the 'on' icon
* `part`: string or nil - the part of the hudbar to change icon of (for compound hudbars)
If the player does not have this hudbar instantiated this function is no-op

### `vl_hudbars.reset_icon(player, identifier, part)`
Reset the icon of a hudbar to its default value defined when it was registered

### `vl_hudbars.set_bgicon(player, identifier, new_bgicon, part)`
Change the background 'off' icon of a hudbar

### `vl_hudbars.has_hudbar(player, identifier)`
Returns true if hudbar `identifier` has been instantiated for player `player`, otherwise false

### `vl_hudbars.register_hudbar_modifier(def)`
Registers a hudbar icon modifier function applicable to all players.
A hudbar icon modifier can change the icon on a hudbar based on certain conditions
Hudbar icon modifications are mutually exclusive (only one may apply at once)
Fields in `def`:
* `identifier`: string (required) - the hudbar to modify
* `predicate`: function(player) (required) - should return truthy if the player meets the condition required to change the look of the hudbar
* `icon`: texture string (required) - the texture that the hudbar icon should be changed to
* `priority`: number (required) - the priority of this modifier; a lower number is checked (and activated) with higher priority
* `part`: string or nil - the part of the hudbar to modify (must be nil for simple hudbars, not-nil for compound hudbars)


# `vl_hudbars` internal fields (for reference)

Has fields:
* hudbar_defs
* players
* settings

## `vl_hudbars.hudbar_defs`
A table with keys: identifier; values: definition
Each value contains the fields specified in the API documentation for `vl_hudbars.register_hudbar`

## `vl_hudbars.settings`
A table with keys: setting name; values: setting value

### General settings:
* vl_hudbars.settings.start_offset_left = {x = -16, y = -90}
    The offset in pixels from bottom-centre of screen to start drawing the right side of hudbars on the left of the screen
* vl_hudbars.settings.start_offset_right = {x = 16, y = -90}
    The offset in pixels from bottom-centre of screen to start drawing the left side of hudbars on the right of the screen
* vl_hudbars.settings.scale_x = 24
    The length in pixels of one icon texture to be displayed
* vl_hudbars.settings.hudbar_height_gap = 4
    The gap in pixels between hudbars
* vl_hudbars.settings.bar_length = 20
    The length of a hudbar layer in half-textures
* vl_hudbars.settings.base_pos = {x=0.5, y=1}
    Where to anchor hudbar drawing (bottom-centre) - increases towards bottom-right
* vl_hudbars.settings.max_rendered_layers = 100
    Absolute hudbars must have a maximum number of layers to protect against server crashes or lag
    This is the maximum number of layers on a single part of an absolute hudbar - each part will be truncated if it is above this

### Squish settings:
* vl_hudbars.settings.min_layer_offset = 8
    Minimum increase in y (in pixels) between layers when squishing
* vl_hudbars.settings.max_unsquished_layers = 3
    Maximum number of layers a hudbar may have before it starts getting squished
* vl_hudbars.settings.squish_duration = 12
    Number of layers to squish over before reaching max squish - currently the squish fraction increases linearly over this many layers

### Builtin hudbar settings:
* vl_hudbars.settings.forceload_default_hudbars = true
    Whether to load default hudbars even if damage is disabled (i think?)
* vl_hudbars.settings.autohide_breath = true
    Whether to automatically hide the breath bar when not in water
* vl_hudbars.settings.tick = 0.1
    Interval in seconds between updating default hudbars to improve performance (capped at 4)

## `vl_hudbars.players`
A table of players with hudbars instantiated, indexed by player name
The values are tables holding the state of hudbars for the player

### `vl_hudbars.players[name]`
A table giving the state the hudbars for this player
Fields:
* hudbar_order_left: array of hudbar identifiers displayed on the left of the player's screen, bottom to top
* hudbar_order_right: array of hudbar identifiers displayed on the right of the player's screen, bottom to top
* hudstate: a hudstate table (see below)

### `vl_hudbars.players[name].hudstate`
A table indexed by identifier, values are the state of a particular hudbar for the player

### `vl_hudbars.players[name].hudstate[identifier]`
Contains the state of a particular hudbar
Has fields:
* current_height_pixels: the total displayed height this hudbar is taking up on screen in pixels; used to work out how much to move other hudbars up or down when changing value

Simple hudbars:
* icon: icon texture name for this hudbar
* base_icon: default icon texture name
* bgicon: default background icon texture name
* layer_ids: the minetest ids for each layer of this hudbar, bottom-to-top
* state: table with values:
    * hidden: whether this hudbar is hidden
    * value: current abstract value of this hudbar (not the number of parts displayed)
    * max_val: current abstract maximum value of this hudbar (not the number of parts displayed)

Compound hudbars:
* parts_order: array of part identifiers in this hudbar, bottom-to-top
* parts: table of the state of parts in this hudbar, has fields:
    * icon: icon texture name for this part
    * base_icon: default icon texture name
    * bgicon: default background icon texture name
    * layer_ids: the minetest ids for each layer of this part, bottom-to-top
    * state: table with values:
        * hidden: whether this part is hidden
        * value: current abstract value of this part (not the number of parts displayed)
        * max_val: current abstract maximum value of this part (not the number of parts displayed)
