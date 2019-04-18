# Cross compilation of Swift for ARM64 and AMD64

## Prerequisites
You must have:

1.  Xcode 10.2 installed (or be using a swift 5 toolchain in 10.1)

2.  Docker installed on your mac

Then, get and install the arm64 and amd64 cross compilers on your mac:

[arm64](https://drive.google.com/file/d/16wtHZRcfkaMMq_53vMcBl1pt7hf_1K0l) 

[amd64](https://drive.google.com/open?id=1y-tX00iuLk6LVluAK7r13f30Up6Bya8N)

*NB* These will install in /Library/Developer/[SDKs, Toolchains, Destinations].

## Running natively on the Mac
Once the cross compilers are installed, on your mac open the _echoserver_ project in Xcode, and build and run the echo server.  In a terminal window, test that it is working by running:

`test.sh`

The echoserver is a very simple Amazon Smoke/SwiftNIO webservice that simply echoes back JSON that it receives.  It does require that all of the associated packages compile and link successfully though, so it makes a good test.

## Running in Docker on the Mac

Stop the server in Xcode.  At a terminal prompt, build a docker container for the Mac (or any amd64 machine which can run docker) by executing:

`build-amd64.sh`

The build step is two lines long and provided in this form for clarity.  This script will cross-compile the exact same swift code that you ran under Xcode to the amd-64 architecture and then produce a docker image called _echoserver_.  Verify this by running 

`docker images`

You should see a docker image named: _echoserver:amd64-latest_.  It should be <10MB in size.  Run that image by executing:

`run-amd64.sh`

That command will automatically pull and run the _swift_runtime:amd64-latest_ docker container which contains all of the shlibs necessary to run the cross-compiled _echoserver_.    Note that _swift_runtime_ starts, copies the necessary runtime files into a docker volume, prints a success message (via a program written in swift) and then exits.  

The script will then run the echoserver.  Verify this by executing:

`docker ps —all`

You should see that _swift_runtime_ is present but exited and that _echoserver_ is running successfully.  

Test the echo server as above:

`test.sh`

Congrats, you have successfully cross-compiled for amd64.  This docker image can be deployed to any amd64 cloud image if you like.

## Running in Docker on the Raspberry Pi

*NB* For now, you _*MUST*_ be running a 64 bit OS such as Ubuntu or Debian on your Pi to follow these steps.   Also note that which 64-bit OS you are running is immaterial.  Also note that everything _should_ run on any single board computer with an arm64v8 processor provided you are running a 64-bit LInux OS and have docker installed.
 
Unfortunately, I’m still working on the 32-bit version of the cross compiler. There don’t seem to be insuperable difficulties here, I just need to figure out which pieces are missing and build the cross-compiler and docker run-time images.  Sorry, but such is life in the open source world.

The process here is pretty much the same, only we have to move the docker image to the Pi to test.  I’ll have to leave that part as an exercise for the reader, since your mileage may vary, but the steps up to deployment are pretty much the same.  

Build the docker container with:

`build-arm64.sh`

This will produce a docker image called _echoserver:arm64-latest_.  Move that image to the Pi in whatever way you normally would do, presumably through a docker registry.  Also move the _run-arm64.sh_ script to the Pi.  On your Pi, run the script.  Test as above.

## Explanation

So what’s happening here is that I have modified the work of Johannes Weiss and Helge Hess to create the cross compilers.  If you are curious about how that works the repo is [here](https://github.com/CSCIX65G/swift-mac2arm-x-compile-toolchain) . 

One of the outputs of that process, when the cross compilers are built for Ubuntu 18.04 (bionic), is that all of the shlibs that Swift requires in order to link swift-compiled programs at run time on bionic can be determined by looking at the libraries produced in the cross-compiler SDK and can then be downloaded and assembled into a single runtime.tar.gz file.  

Note that, ubuntu 18.04 is *NOT* required as part of all this.  The idea is to run swift programs without the weight of a full linux distribution (i.e. distro-less).  Once we provide a complete set of libs drawn from any OS, then it is as if we had statically linked the executable, only we don’t have to include those libs in every docker image.

Once I did that, I realized that I could construct docker images of just those files + the Ubuntu loader.  If you are interested in what _that_ looks like, the repository is [here](https://github.com/CSCIX65G/swift-remote-debug)  That repo will (soonish) host a docker image which can remotely debug cross-compiled swift programs as well.

Then I realized that I can run swift programs in ‘distro-less’ mode so that all you need is the executable output of the cross compiler in a docker container which mounts the swift_runtime volumes and you can run fast, small and secure swift applications.

That’s the current state of the world.  Will be interested in people’s feedback.

## To do

1. Extend the previous lld-server work I did in January to run distro-less on all platforms as well.
 
2. Figure out how to run amd64 tests easily on a mac
 
3. Get the armv7 cross-compiler working so that people can run this stuff on Raspbian and Yocto Linux
 
4. Ditto for armv6, so that swift code can be easily deployed to the R Pi Zero series
