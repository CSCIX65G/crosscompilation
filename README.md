#Cross compilation of Swift for ARM64 and AMD64

## Prerequisites
You must have:

1.  Xcode 10.2 installed (or be using a swift 5 toolchain in 10.1)

2.  Docker installed on your mac

Then, get and install the cross compilers on your mac:

[arm64](https://drive.google.com/file/d/16wtHZRcfkaMMq_53vMcBl1pt7hf_1K0l) 

[amd64](https://drive.google.com/open?id=1y-tX00iuLk6LVluAK7r13f30Up6Bya8N)

These will install in Library/Developer/[SDKs, Toolchains, Destinations].

## Running natively on the Mac
Once the cross compilers are installed, on your mac open the echoserver project in Xcode, and build and run the echo server.  In a terminal window, test that it is working by running:

`test.sh`

The echoserver is a very simple Amazon Smoke/SwiftNIO that simply echoes back JSON that it receives.  It does require that all of the associated packages compile and link successfully though.

## Running in Docker on the Mac

Stop the server in Xcode.  At a terminal prompt, build a docker container for the Mac (or any amd64 machine which can run docker) by executing:

`build-amd64.sh`

This will cross-compile the exact same swift code to amd-64  and produce a docker image called _echoserver_.  Verify this by running 

`docker images`

You should see a docker image named: _echoserver:amd64-latest_.  It should be <10MB in size.  Run that image by executing:

`run-amd64.sh`

That command will automatically pull and run the _swift_runtime:amd64-latest_ docker container which contains all of the shlibs necessary to run the cross-compiled _echoserver_.  It will then run the echoserver.  Verify this by executing:

`docker ps —all`

You should see that _swift_runtime_ is present but exited and that _echoserver_ is running successfully.  Test the echo server as above:

`test.sh`

Congrats you have cross-compiled for amd64.

## Running in Docker on the Raspberry Pi

*NB* For now, you _*MUST*_ be running a 64 bit OS such as Ubuntu or Debian on your Pi to follow these steps.  I’m still working on the 32-bit version of the cross compiler. Sorry, but such is life in the open source world.

The process here is pretty much the same, only we have to move the docker image to the Pi to test.  I’ll have to leave that part as an exercise for the reader but the steps are pretty much the same.  Build the docker container with:

`build-arm64.sh`

This will produce a docker image called _echoserver:arm64-latest_.  Move that image to the Pi in whatever way you normally would do, presumably through a docker registry.  Also move the _run-arm64.sh_ script to the Pi.  On your Pi, run the script.  Test as above.

##Explanation

So what’s happening here is that I have modified the work of Johannes Weiss and Helge Hess to create the cross compilers.  If you are curious about how that works the repo is [here](https://github.com/CSCIX65G/swift-mac2arm-x-compile-toolchain) . 

One of the outputs of that process, when the cross compilers are built for Ubuntu 18.04 (bionic) is that all of the shlibs that Swift requires in order to link swift programs at run time on bionic can be determined by looking at the libraries produced in the cross-compiler SDK and can then be downloaded and assembled into a single runtime.tar.gz file.  

Note that, ubuntu 18.04 is *NOT* required as part of all this.  The idea is to run swift programs without the weight of a full linux distribution (i.e. distro-less).  Once we provide a complete set of libs drawn from any OS, then it is as if we had statically linked the executable, only we don’t have to include those libs in every docker image.

Once I did that, I realized that I could construct docker images of just those files + the Ubuntu loader.  If you are interested in what _that_ looks like, the repository is [here](https://github.com/CSCIX65G/swift-remote-debug)  That repo will (soonish) host a docker image which can remotely debug cross-compiled swift programs as well.

Then I realized that I can run swift programs in ‘distro-less’ mode so that all you need is the executable output of the cross compiler in a docker container which mounts the swift_runtime volumes and you can run fast, small and secure swift applications.

That’s the current state of the world.  Will be interested in people’s feedback.

