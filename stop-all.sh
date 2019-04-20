#!/bin/bash
docker stop echoserver || true >> /dev/null
docker rm echoserver || true >> /dev/null
docker stop lldb_server || true >> /dev/null
docker rm lldb_server || true >> /dev/null
docker rm swift_runtime || true >> /dev/null
docker volume prune
