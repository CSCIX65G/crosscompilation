#!/bin/sh
swift package generate-xcodeproj
cat echoserver.xcodeproj/project.pbxproj | sed s/10.10/10.13/g > tmp
mv tmp echoserver.xcodeproj/project.pbxproj
