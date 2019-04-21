#!/bin/sh
docker pull cscix65g/swift-runtime:arm64-latest
docker pull cscix65g/echoserver:arm64-latest
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
    docker run --name swift_runtime -v swift_runtime_lib:/lib -v swift_runtime_usr_lib:/usr/lib -v swift_runtime_usr_bin:/usr/bin -d cscix65g/swift-runtime:arm64-latest
    docker logs swift_runtime
fi
docker stop echoserver || true >> /dev/null
docker run --privileged --rm -d --name echoserver -p 8080:8080 --volumes-from swift_runtime cscix65g/echoserver:arm64-latest
docker ps --filter name=echoserver
docker logs echoserver

