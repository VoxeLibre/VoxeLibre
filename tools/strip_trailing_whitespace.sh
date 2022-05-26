#!/bin/bash
sed --in-place 's/[[:space:]]\+$//' $(find -name "*.lua")
