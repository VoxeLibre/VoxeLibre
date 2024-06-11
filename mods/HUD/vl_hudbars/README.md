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
