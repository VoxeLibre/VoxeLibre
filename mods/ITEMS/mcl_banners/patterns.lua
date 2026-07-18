local N = function(s) return s end

--- name, description, pattern item (optional), owning mod (optional)
local builtin_patterns = {
	{ "border", N("@1 Bordure") },
	{ "bricks", N("@1 Bricks"), "mcl_core:brick_block" },
	{ "circle", N("@1 Roundel") },
	{ "creeper", N("@1 Creeper Charge"), "mcl_heads:stalker" },
	{ "cross", N("@1 Saltire") },
	{ "curly_border", N("@1 Bordure Indented") },
	{ "diagonal_up_left", N("@1 Per Bend Inverted") },
	{ "diagonal_up_right", N("@1 Per Bend Sinister Inverted") },
	{ "diagonal_right", N("@1 Per Bend") },
	{ "diagonal_left", N("@1 Per Bend Sinister") },
	{ "flower", N("@1 Flower Charge"), "mcl_flowers:oxeye_daisy" },
	{ "gradient", N("@1 Gradient") },
	{ "gradient_up", N("@1 Base Gradient") },
	{ "half_horizontal_bottom", N("@1 Per Fess Inverted") },
	{ "half_horizontal", N("@1 Per Fess") },
	{ "half_vertical", N("@1 Per Pale") },
	{ "half_vertical_right", N("@1 Per Pale Inverted") },
	{ "thing", N("@1 Thing Charge"), "mcl_core:apple_gold_enchanted" },
	{ "rhombus", N("@1 Lozenge") },
	{ "skull", N("@1 Skull Charge"), "mcl_heads:wither_skeleton" },
	{ "small_stripes", N("@1 Paly") },
	{ "square_bottom_left", N("@1 Base Dexter Canton") },
	{ "square_bottom_right", N("@1 Base Sinister Canton") },
	{ "square_top_left", N("@1 Chief Dexter Canton") },
	{ "square_top_right", N("@1 Chief Sinister Canton") },
	{ "straight_cross", N("@1 Cross") },
	{ "stripe_bottom", N("@1 Base") },
	{ "stripe_center", N("@1 Pale") },
	{ "stripe_downleft", N("@1 Bend Sinister") },
	{ "stripe_downright", N("@1 Bend") },
	{ "stripe_left", N("@1 Pale Dexter") },
	{ "stripe_middle", N("@1 Fess") },
	{ "stripe_right", N("@1 Pale Sinister") },
	{ "stripe_top", N("@1 Chief") },
	{ "triangle_bottom", N("@1 Chevron") },
	{ "triangle_top", N("@1 Chevron Inverted") },
	{ "triangles_bottom", N("@1 Base Indented") },
	{ "triangles_top", N("@1 Chief Indented") },
}


for _, pattern in ipairs(builtin_patterns) do
    mcl_banners.register_pattern(pattern[1], {
        description = pattern[2],
        loom = true,
        texture = "mcl_banners_" .. pattern[1] .. ".png",
		pattern_item = pattern[3],
	})
end
