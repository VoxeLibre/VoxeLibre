#!/bin/sh

. tests/env.sh
set -e

# Make sure luanti lls definitions are up-to-date
(
	mkdir -p /usr/share/luanti/
	cd /usr/share/luanti
	# TODO: change to https://codeberg.org/fgaz/luanti-lls-definitions after https://codeberg.org/fgaz/luanti-lls-definitions/pulls/1 is merged
	git clone --depth 1 https://codeberg.org/teknomunk/luanti-lls-definitions.git || true
	cd luanti-lls-definitions
	git checkout fill-out-definitions
	git pull

	if ! test -d /usr/share/luanti/builtin; then
		ln /usr/share/minetest/builtin /usr/share/luanti/builtin -s
	fi
)

lua-language-server --check . --log check.log --logpath ./log | tr '\r' '\n' || true
$LUA tests/display-lls-check-log.lua
