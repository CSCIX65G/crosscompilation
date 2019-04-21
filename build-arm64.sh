swift build -Xswiftc -Darm64 --destination /Library/Developer/Destinations/arm64-ubuntu-bionic.json
docker build --file ./Dockerfile-arm64 --tag echoserver:arm64-latest .
