#!/bin/bash
docker stop echoserver || docker rm echoserver || docker stop lldb_server || docker rm lldb_server || docker rm swift_runtime ||  docker volume prune
