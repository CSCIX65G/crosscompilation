swift build -Xswiftc -Darm64 -Xswiftc -target -Xswiftc aarch64-unknown-linux --destination /Library/Developer/Destinations/arm64-ubuntu-bionic.json
docker build --file ./Dockerfile-arm64 --tag echoserver:arm64-latest .
