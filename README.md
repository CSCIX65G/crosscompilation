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

Congrats, you have successfully cross-compiled for amd64.  This docker image can be deployed to any amd64 cloud image (with docker installed) if you like by simply running the commands in the run script.

## Running in Docker on the Raspberry Pi

*NB* For now, you _*MUST*_ be running a 64 bit OS such as Ubuntu or Debian on your Pi to follow these steps.   Also note that which 64-bit OS you are running is immaterial.  Also note that everything _should_ run on any single board computer with an arm64v8 processor provided you are running a 64-bit LInux OS and have docker installed, because the entire process is independent of the underlying OS.
 
Unfortunately, I’m still working on the 32-bit version of the cross compiler. There don’t seem to be insuperable difficulties here, I just need to figure out which pieces are missing and build the cross-compiler and docker run-time images.  Sorry, but such is life in the open source world.

The process here is pretty much the same, only we have to move the docker image to the Pi to test.  I’ll have to leave that part as an exercise for the reader, since your mileage may vary, but the steps up to deployment are pretty much the same.  

Build the docker container with:

`build-arm64.sh`

This will produce a docker image called _echoserver:arm64-latest_.  Move that image to the Pi in whatever way you normally would do, presumably through a docker registry.  Also move the _run-arm64.sh_ and `test.sh` scripts to the Pi.  On your Pi, execute the run script.  Test as above.

## Debugging

On your mac, do the following:

`debug-server-amd64.sh`

`docker ps —all` should the produce output like:

```
CONTAINER ID        IMAGE                                 COMMAND                  CREATED             STATUS                      PORTS                                                      NAMES
4100fd7bbf7c        cscix65g/lldb-server:amd64-latest     "/swift_runtime/usr/…"   19 minutes ago      Up 19 minutes               0.0.0.0:8080->8080/tcp, 0.0.0.0:9293-9296->9293-9296/tcp   lldb_server
44dc506ffecd        cscix65g/swift-runtime:amd64-latest   "/lib/x86_64-linux-g…"   19 minutes ago      Exited (0) 19 minutes ago                                                              swift_runtime

```
Note that this process will use the 8080 port and be incompatible with running the echoserver container at the same time.  You’ll need to kill it with `docker stop echoserver` if you want to play with the debugger.  If the lldb_server instance is up, then you can do the following:

` lldb ./.build/x86_64-unknown-linux/debug/echoserver`

Once lldb has launched, do the following:
```
env LD_LIBRARY_PATH=/swift_runtime/usr/lib/swift/linux:/swift_runtime/usr/lib/x86_64-linux-gnu:/swift_runtime/lib/x86_64-linux-gnu
platform connect connect://0.0.0.0:9293
platform select remote-linux
break set --file main.swift --line 32
run
```

You should see output like:

```
Process 20 launched: '/Users/rvs/Development/Projects/HarvardExtension/crosscompilation/.build/x86_64-unknown-linux/debug/echoserver' (x86_64)
Process 20 stopped
* thread #1, name = 'echoserver', stop reason = breakpoint 1.1
    frame #0: 0x00005555557aa452 echoserver`main at main.swift:32:11
   17  	let services = [
   18  	    (path: "/echo", method: HTTPMethod.POST, type: EchoService.self)
   19  	]
   20  	
   21  	func createHandlerSelector() -> HandlerSelector {
   22  	    var handlerSelector = HandlerSelector(
   23  	        defaultOperationDelegate: ApplicationContext.operationDelegate
   24  	    )
   25  	    services.forEach { service in
   26  	        handlerSelector.addHandlerForUri(service.path, httpMethod: service.method, handler: service.type.serviceHandler)
   27  	    }
   28  	    return handlerSelector
   29  	}
   30  	
   31  	do {
-> 32  	    Log.info("Starting Server")
   33  	    Log.info("Verifying shell availability.  Hostname = \(shell.hostname())")
   34  	    let handlerSelector = createHandlerSelector()
   35  	    let server = try SmokeHTTP1Server.startAsOperationServer(
   36  	        withHandlerSelector: handlerSelector,
   37  	        andContext: ApplicationContext()
   38  	    )
   39  	    try server.waitUntilShutdownAndThen {
   40  	        Log.info("shutdown server = \(server)")
   41  	    }
   42  	    Log.info("started server = \(server)")
   43  	} catch {
   44  	    Log.error("Unable to start Operation Server: '\(error)'")
   45  	}
Target 0: (echoserver) stopped.
```

You are now debugging the echo server running inside a docker container on your mac.  To do this on your Pi, you simply need to transport the `debug-server-arm64.sh` script to your Pi and run it.  Then at the connect command in lldb on your mac, substitute the hostname or IP address of your Pi and you’ll be remotely debugging the echoserver on the Pi.

*NB* there is no need to copy the arm executable from the mac to the Pi.  On your _mac_ build the Pi executable with the command:

```
./build-arm64.sh
```

And follow the steps as above with the following changes:

```
lldb ./.build/aarch64-unknown-linux/debug/echoserver
```

Once in lldb do:

```
env LD_LIBRARY_PATH=/swift_runtime//usr/lib/swift/linux:/swift_runtime/usr/lib/aarch64-linux-gnu:/swift_runtime/lib/aarch64-linux-gnu
platform connect  connect://[IP or FQDN of your R/Pi]:9293
break set --file main.swift --line 32
run
```

Note the changes to the LD_LIBRARY_PATH.  These are to account for the fact that you are debugging on a different architecture.

## Explanation

So what’s happening here is that I have modified the work of Johannes Weiss and Helge Hess to create the cross compilers.  If you are curious about how that works the repo is [here](https://github.com/CSCIX65G/swift-mac2arm-x-compile-toolchain) . 

One of the outputs of that process, when the cross compilers are built for Ubuntu 18.04 (bionic), is that all of the shlibs that Swift requires in order to link swift-compiled programs at run time on bionic can be determined by looking at the libraries produced in the cross-compiler SDK and can then be downloaded and assembled into a single runtime.tar.gz file.  

Note that, ubuntu 18.04 is *NOT* required as part of all this.  (Well ok at the moment a minimal ubuntu is needed for the lldb-server, but even that is unmodified and should go away soon(ish)). 

The idea is to run swift programs without the weight of a full linux distribution (i.e. distro-less).  Once we provide a complete set of libs drawn from any OS, then it is as if we had statically linked the executable, only we don’t have to include those libs in every docker image.

To do that we construct docker images of just those files + the Ubuntu loader.  If you are interested in what _that_ looks like, the repository is [here](https://github.com/CSCIX65G/swift-remote-debug)  That repo also hosts docker images which can be used to remotely debug cross-compiled swift programs as well.

Once we can run swift programs in ‘distro-less’ mode so that all you need is the executable output of the cross compiler in a docker container which mounts the swift_runtime volumes, thenyou can run fast, small and secure swift applications.

That’s the current state of the world.  Will be interested in people’s feedback.

## To do

1. The next big to do is to get all of this working with VS Code.  I’ve tried getting [this](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) working, but so far no dice with remote lldb debugging.  If it could be combined with [this](https://marketplace.visualstudio.com/items?itemName=vknabel.vscode-swift-development-environment) we’d have a decent Mac IDE for swift.  The big thing on the debugger is that it seems to not understand the remote commands properly.

2. Extend the previous lld-server work I did in January to run distro-less on all platforms as well.
 
3. Figure out how to run amd64 tests easily on a mac
 
4. Get the armv7 cross-compiler working so that people can run this stuff on Raspbian and Yocto Linux
 
5. Ditto for armv6, so that swift code can be easily deployed to the R Pi Zero series
