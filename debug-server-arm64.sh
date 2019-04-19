#!/bin/sh
docker pull cscix65g/swift-runtime:arm64-latest
if [ ! "$(docker ps --all -q -f name=swift_runtime)" ]; then
    echo "Launching swift_runtime"
    docker run --name swift_runtime -d cscix65g/swift-runtime:arm64-latest
    docker logs swift_runtime
fi

docker pull cscix65g/lldb-server:arm64-latest
if [ ! "$(docker ps --all -q -f name=lldb_server)" ]; then
    echo "Launching lldb-server"
    docker run -d --rm --privileged --name lldb_server --network host -v `pwd`/tmp:/debug --volumes-from swift_runtime  cscix65g/lldb-server:arm64-latest
    docker logs lldb_server
fi
