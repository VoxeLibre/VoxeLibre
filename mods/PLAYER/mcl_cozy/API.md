# VoxeLibre Get Comfortable API

## Actions

The mod provides 2 types of player actions: `"sit"` and `"lay"`. Both attach
players to blocks, but show different animations. Whenever there's a mention
of `action`, it means that it has to either be `"sit"` or `"lay"`.

There is currently no way to register new actions.

## `function mcl_cozy[action](pos, node, player)`

A function provided for every action that applies the action to `player`.
If `pos` is nil, the player will be mounted to their current position.
If `node` is nil and `pos` isn't, it will be fetched automatically.

```lua
core.register_node("mymod:sit_on_me", {
    description = "Sit on me!",
    -- ...
    on_rightclick = mcl_cozy.sit
})
```

## `function mcl_cozy.stand_up(player)`

Stands `player` up, unmounting them, resetting their eye offset and setting
their animation back to standing.

## `function mcl_cozy.print_action(name, action)`

Outputs the `action` of `name`, if the corresponding setting is enabled.

```
<coolguy> I'm sleepy
* coolguy lies
<coolguy> Zzz
```

## `function mcl_cozy.actionbar_show_status(player, message)`

Shows `message` on the actionbar of `player`. If `message` is nil, it defaults
to `S("Move to stand up")`.

Historically, this wrapper was needed because Mineclonia had `mcl_tmp_message`
instead of `mcl_title`. Nowadays, it exists purely for convenience and
simplicity.

## `def._mcl_cozy_offset = vector.new(x, y, z)`

It is possible to offset the body point for a player to be mounted to. Usually,
this is a vector with very small values, just enough to make the player feel
comfortable.

* `+x` and `-x` move the player left and right
* `+y` and `-y` move the player up and down
* `+z` and `-z` move the player front and back

```lua
core.register_node("mymod:lay_on_me", {
    description = "Lay on me!",
    on_rightclick = mcl_cozy.lay,
    -- ...
    _mcl_cozy_offset = vector.new(0, 0.1, -0.2) -- a bit higher and to the back
})
```
