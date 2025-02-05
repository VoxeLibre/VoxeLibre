#!/bin/bash

which luarocks && eval $(luarocks path)
which luarocks-5.3 && eval $(luarocks-5.3 path)

LUACHECK=$HOME/.luarocks/bin/luacheck
LUA=$( which lua || which lua5.1 || which lua5.2 || which lua5.3 || which luajit )
if [[ -z "$LUA" ]]; then
	echo "Unable to find lua interpreter"
	exit 1
fi
(
	find ./ -name mod.conf
	echo EOF
) | $LUA tests/luacheck/test.lua | sh

