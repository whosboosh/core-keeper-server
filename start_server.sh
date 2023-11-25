#!/bin/bash
docker run --platform linux/amd64 -it --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --net=host corekeeper
