# Unittests API

Add `vl_unittests` to your mod's `depends`, then register tests during loading:

```lua
if vl_unittests.enabled then
    dofile(modpath .. "/tests.lua")
end
```

```lua
local t = vl_unittests

t.test("roman numerals", function()
    t.assert_equal(mcl_util.to_roman(4), "IV")
end)
```

When starting the server with `vl_unittests_enabled = true`, the server will execute tests before exiting. Overwise, the server will run normally and tests will be ignored.

Test names must be unique within the mod. Tests run synchronously after mod loading, raising an error fails the test.

Available assertions (each accepts an optional final message):

- `assert_equal(actual, expected)` — Lua equality.
- `assert_deep_equal(actual, expected)` — recursive contents, ignoring metatables.
- `assert_near(actual, expected, tolerance)` — absolute numeric tolerance.
- `assert_error(func, expected_substring?)` — require an error, optionally matching literal text.

Ordinary Lua `assert` also works.
