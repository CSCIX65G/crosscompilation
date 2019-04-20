#!/bin/sh
docker pull cscix65g/swift-runtime:amd64-latest
docker pull ubuntu:bionic
if [ ! "$(docker ps --all -q -f name=swift_runtime)" ]; then
    echo "Launching swift_runtime"
    if [ "$(docker volume ls | grep swift_runtime_usr_bin)" ]; then
	docker volume rm swift_runtime_usr_bin >> /dev/null
    fi
    docker volume create swift_runtime_usr_bin
    if [ "$(docker volume ls | grep swift_runtime_usr_lib)" ]; then
	docker volume rm swift_runtime_usr_lib >> /dev/null
    fi
    docker volume create swift_runtime_usr_lib
    if [ "$(docker volume ls | grep swift_runtime_lib)" ]; then
	docker volume rm swift_runtime_lib >> /dev/null
    fi
    docker volume create swift_runtime_lib
    if [ "$(docker volume ls | grep swift_debug)" ]; then
	docker volume rm swift_debug >> /dev/null
    fi
    docker volume create swift_debug
    docker run --name swift_runtime -v swift_runtime_lib:/lib -v swift_runtime_usr_lib:/usr/lib -v swift_runtime_usr_bin:/usr/bin -d cscix65g/swift-runtime:amd64-latest
    docker logs swift_runtime
fi
docker run -it --name lldb_server --rm --privileged --network host --env LD_LIBRARY_PATH=/swift_runtime/usr/lib/swift/linux:/swift_runtime/usr/lib/x86_64-linux-gnu:/swift_runtime/lib/x86_64-linux-gnu -v swift_runtime_lib:/swift_runtime/lib -v swift_runtime_usr_lib:/swift_runtime/usr/lib -v swift_runtime_usr_bin:/swift_runtime/usr/bin -v swift_debug:/swift_debug ubuntu:bionic bash

