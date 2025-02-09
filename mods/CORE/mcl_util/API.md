# VoxeLibre utility functions

The documentation is currently incomplete.

## Hashing

While Luanti core provides access to *secure hashing* functions via `core.sha1` and `core.sha256`, perfect for password validation,
this often is overkill when there are no cryptographic requirements. This package provides some low-complexity alternatives.

- `mcl_util.djb2_hash(str)` is a simple string hashing function attributed to DJ Bernstein.

- `mcl_util.bitmix32(a, b)` is a simple bit mixer that combines two integers `a` and `b` into an integer hash value.

- `mcl_util.hash_pos(x, y, z, seed)` is a simple hash function of a coordinate vector,
  suitable for deterministic low-security hashing, such as map generation.
  A good choice if performance is more important than cryptographic security.
  In contrast to the misnamed Luanti `core.hash_node_position` (which is `x << 32 + y << 16 + z`,
  a reversible map of the position into a 48 bit integer), this is a *mixing* function,
  such that nearby nodes are expected to produce very different hash code.

For *cryptographic* uses, please continue to use `core.sha256`.

