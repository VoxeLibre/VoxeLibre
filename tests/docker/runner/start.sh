#!/bin/sh

docker run --rm --network=host -u 1000 \
	-v data:/data \
	-v /var/run/docker.sock:/var/run/docker.sock --detach=true \
	code.forgejo.org/forgejo/runner:4.0.0 forgejo-runner daemon
