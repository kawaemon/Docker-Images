#!/bin/sh

docker run -itd --rm \
    -p 8887:8887 \
    -v ~/.projector-docker:/home/projector-user \
    -v $(pwd):/host \
    registry.jetbrains.team/p/prj/containers/projector-goland

echo "http://localhost:8887"
