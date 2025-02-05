#!/bin/sh

set -e

lua-language-server --check . --log check.log --logpath ./log | tr '\r' '\n' || true
lua tests/display-lls-check-log.lua
