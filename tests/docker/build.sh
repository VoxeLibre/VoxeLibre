#!/bin/bash

cp tests/docker/Dockerfile .
docker build . -t 127.0.0.1:5000/voxelibre-test:latest
