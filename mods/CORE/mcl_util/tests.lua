-- SPDX-FileCopyrightText: 2026 AFCMS <afcm.contact@gmail.com>
-- SPDX-License-Identifier: GPL-3.0-or-later

local t = vl_unittests

t.test("roman numerals", function()
	t.assert_equal(mcl_util.to_roman(0), "")
	t.assert_equal(mcl_util.to_roman(4), "IVAAA")
	t.assert_error(function()
		t.assert_equal(mcl_util.to_roman(9), "XI")
	end, "expected")
end)

t.test("table defaults preserve false", function()
	local value = { enabled = false }
	table.update_nil(value, { enabled = true, count = 2 })
	t.assert_deep_equal(value, { enabled = false, count = 2 })
end)

t.test("timer accumulates elapsed time", function()
	local state = {}
	mcl_util.check_dtime_timer(state, 0, "test", 1)
	mcl_util.check_dtime_timer(state, 0.1, "test", 1)
	mcl_util.check_dtime_timer(state, 0.2, "test", 1)
	t.assert_near(state._timers.test, 0.3, 1e-12)
	t.assert_equal(mcl_util.check_dtime_timer(state, 0.8, "test", 1), true)
	t.assert_equal(state._timers.test, 0)
end)
