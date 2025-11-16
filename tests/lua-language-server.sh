#!/bin/sh

. tests/env.sh
set -e

# Make sure luanti lls definitions are up-to-date
(
	git clone --single-branch --depth 1 https://git.minetest.land/andro/luanti-api.git || true

#	if ! test -d /usr/share/luanti/builtin; then
#		ln /usr/share/minetest/builtin /usr/share/luanti/builtin -s
#	fi
)

lua-language-server --check . --check_format json --logpath ./log | tr '\r' '\n' || true
$LUA tests/display-lls-check-log.lua
