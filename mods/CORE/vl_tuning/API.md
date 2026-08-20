# `vl_tuning`
Provides runtime-tunable settings and parameters and a GUI for server admins to change them.

## `vl_tuning.setting(name, type, definition)`
Registers a tunable setting.
* `name`: name of the setting
* `type`: setting type. Must be one of "bool", "number" or "string"
* `definition`: setting defintion with the following fields:
  * `set`: a function taking a single parameter. Called when the setting is changed
  * `get`: a function returning a single value. Called whenever the API needs the current setting value
  * `default`: the setting's default value
  * `description`: a description of the setting. Must already be translated.
  * `formspec_desc_lines`: number of lines to use for the description. Used for laying out the settings GUI

## `vl_tuning.player_setting(name, type, definition)`
Registers a per-player setting stored in player metadata.
* `name`: name of the setting
* `type`: setting type. Must be one of "bool", "number" or "string"
* `definition`: optional per-player setting definition with the following fields:
  * `default`: the setting's default value
  * `description`: a description of the setting. Must already be translated.
  * `formspec_desc_lines`: number of lines to use for the description. Used for laying out the player settings GUI
  * `on_change`: optional hook called as `on_change(setting, player, value)` when a player's value is applied or changed

Returns a setting object with:
* `setting:get(player)`: fetch the current value for a player
* `setting:set(player, value)`: set the current value for a player
* `setting:get_string(player)`: fetch the current value as a string
