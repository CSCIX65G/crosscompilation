swift build --destination /Library/Developer/Destinations/arm64-5.0.1-RELEASE.json
docker build --file ./Dockerfile-arm64 --tag cscix65g/echoserver:arm64-latest .
docker push cscix65g/echoserver:arm64-latest
