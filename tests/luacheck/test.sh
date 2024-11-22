#!/bin/bash

LUACHECK=$HOME/.luarocks/bin/luacheck

(
	find ./ -name mod.conf
	echo EOF
) | lua5.3 tests/luacheck/test.lua | sh

