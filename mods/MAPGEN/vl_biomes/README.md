Biomes mod. Originally by Wuzzy and maikerumine, refactored by kno10.

# Decorations

Some hints:

- `noise_params` overrides `fill_ratio`, do not set both
- use `fill_ratio = 10` for complete coverage (optimized codepath in Luanti)
- `sidelen` defaults to 1, and must be a divisor of 80 (chunk size)
- decorations are randomly placed in blocks of size `sidelen`, a smaller sidelen
  can be used to make placement *more regular* than uniform sampling.
  If you do not need that, `sidelen = 80` is a good choice with `fill_ratio`.
- with `noise_params`, the noise function is evaluated for every block of size `sidelen`
  so increasing `sidelen` can improve performance, but large `sidelen` can cause visible
  block patterns
- it does not make sense to combine large `sidelen` and fine-resolution noise, as noise
  is only evaluated for the center of each block of size `sidelen`
