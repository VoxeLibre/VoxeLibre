#!/bin/bash

(
	cd tests/docker
	test -e luanti && ( cd luanti; git checkout master; git pull ) || git clone https://github.com/luanti-org/luanti.git luanti
	test -e irrlichtmt && ( cd irrlichtmt; git checkout master; git pull ) || git clone https://github.com/minetest/irrlicht.git irrlichtmt
)
cp tests/docker/Dockerfile .
docker build . -t 127.0.0.1:5000/voxelibre-test:latest
