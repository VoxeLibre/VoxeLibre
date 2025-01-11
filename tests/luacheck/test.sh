#!/bin/bash

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

