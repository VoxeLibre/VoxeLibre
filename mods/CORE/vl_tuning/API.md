# `vl_tuning`
Provides runtime-tunable settings and parameters and a GUI for server admins to change them.

## `vl_tuning.setting(name, type, definition)`
Registers a tunable settings.
* `name`: name of the settings
* `type`: setting type. Must be one of "bool", "number" or "string"
* `definition`: setting defintion with the following fields:
  * `set`: a function taking a single parameter. Called when the setting is changed
  * `get`: a function returning a single value. Called whenever the API needs the current setting value
  * `default`: the setting's default value
  * `description`: a description of the setting. Must already be translated.
  * `formspec_desc_lines`: number of lines to use for the description. Used for laying out the settings GUI

