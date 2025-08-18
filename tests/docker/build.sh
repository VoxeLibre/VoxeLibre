#!/bin/sh

source ~/.config/voxelibre-docker.sh

LUANTI_VERSION=5.13.0
VOXELIBRE_VERSION=0.90.1

if test -z "$USER"; then
	echo "\$USER must be set for docker image build and uploads to function"
	exit 1
fi

# TODO: build packages

(
	cd luanti-server
	docker build . -t $USER/luanti-server:$LUANTI_VERSION
	docker image tag $USER/luanti-server:$LUANTI_VERSION $USER/luanti-server:latest

	docker image push $USER/luanti-server:$LUANTI_VERSION
	docker image push $USER/luanti-server:latest
)
(
	cd luanti-ci
	docker build . -t $USER/luanti-ci:$LUANTI_VERSION
	docker image tag $USER/luanti-ci:$LUANTI_VERSION $USER/luanti-ci:latest

	docker image push $USER/luanti-ci:$LUANTI_VERSION
	docker image push $USER/luanti-ci:latest
)
(
	cd voxelibre
	docker build . -t $USER/voxelibre:$VOXELIBRE_VERSION
	docker image tag $USER/voxelibre:$VOXELIBRE_VERSION $USER/voxelibre:latest

	docker image push $USER/voxelibre:$VOXELIBRE_VERSION
	docker image push $USER/voxelibre:latest
)


#(
#	cd tests/docker
#	test -e luanti && ( cd luanti; git checkout master; git pull ) || git clone https://github.com/luanti-org/luanti.git luanti
#	test -e irrlichtmt && ( cd irrlichtmt; git checkout master; git pull ) || git clone https://github.com/minetest/irrlicht.git irrlichtmt
#)
#cp tests/docker/Dockerfile .
#docker build . -t 127.0.0.1:5000/voxelibre-test:latest
#docker build . -t voxelibre-test
