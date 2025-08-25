-- Currently, this is a passthru to mesecons
-- TODO: override mesecons and redirect operations to VoxeLibre implementation so that third-party
-- mods use our implementation instead of the standard mesecons
vl_circuitry.mesecon.on_state  = mesecon.state.on
vl_circuitry.mesecon.off_state = mesecon.state.off

vl_circuitry.mesecon.receptor_on  = mesecon.receptor_on
vl_circuitry.mesecon.receptor_off = mesecon.receptor_off

vl_circuitry.mesecon.rules = {
	alldirs = mesecon.rules.alldirs
}
