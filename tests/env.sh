#!/bin/bash

which luarocks && eval $(luarocks path)
which luarocks-5.3 && eval $(luarocks-5.3 path)

if test /usr/share/minetest; then
	export LUANTI_PATH=/usr/share/minetest
elif test /usr/share/luanti; then
	export LUANTI_PATH=/usr/share/luanti
else
	echo "Unable to find luanti/minetest path, cannot run tests"
	exit 1
fi

LUACHECK=$HOME/.luarocks/bin/luacheck
LUA=$( which lua || which lua5.1 || which lua5.2 || which lua5.3 || which luajit )
