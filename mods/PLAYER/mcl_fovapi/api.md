
registered_modifiers has defs of modifiers

applied_modifiers is indexed by player name

mcl_fovapi = {}

mcl_fovapi.default_fov = {}

mcl_fovapi.registered_modifiers = {}

mcl_fovapi.applied_modifiers = {}

function mcl_fovapi.register_modifier(name, fov_factor, time, is_multiplier, exclusive, on_start, on_end)

function mcl_fovapi.apply_modifier(player, modifier_name)

function mcl_fovapi.remove_modifier(player, modifier_name)

function mcl_fovapi.remove_all_modifiers(player, time)

