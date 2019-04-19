#!/bin/sh
docker pull cscix65g/swift-runtime:amd64-latest
if [ ! "$(docker ps --all -q -f name=swift_runtime)" ]; then
    echo "Launching swift_runtime"
    docker run --name swift_runtime -d cscix65g/swift-runtime:amd64-latest
    docker logs swift_runtime
fi

docker pull cscix65g/lldb-server:amd64-latest
if [ ! "$(docker ps --all -q -f name=lldb_server)" ]; then
    echo "Launching lldb-server"
    docker run -d --rm --privileged --name lldb_server -p 9293:9293 -v /tmp:/debug --volumes-from swift_runtime  cscix65g/lldb-server:amd64-latest
    docker logs lldb_server
fi
