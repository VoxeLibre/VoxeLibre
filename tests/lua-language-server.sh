#!/bin/sh

set -e

# Make sure luanti lls definitions are up-to-date
(
	mkdir -p /usr/share/luanti/
	cd /usr/share/luanti
	git clone https://codeberg.org/teknomunk/luanti-lls-definitions.git || true
	cd luanti-lls-definitions
	git pull
)

lua-language-server --check . --log check.log --logpath ./log | tr '\r' '\n' || true
lua tests/display-lls-check-log.lua
