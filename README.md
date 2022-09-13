Requires following packages on host system in order to build `curl, jq, git and docker`

To build the image, just run the script `build-docker.sh`  
You can pass following parameters to build script:
```
DEST_REPO=[defaults to wahooli/hyperion.ng]
CPU_ARCH=[defaults to 'uname -m' command output]
RELEASE=[defaults to latest hyperion.ng release on github]
DEST_TAG=[defaults to RELEASE value. you can override the docker tag name to be built, for example "latest"]
USE_BUILDX=[defaults to 0. by setting to 1 you can perform cross platform builds]
```
For example you can run the script with following parameters
```
DEST_TAG=latest DEST_REPO=yourdockerhubuser/hyperion.ng RELEASE=2.0.12 build-docker.sh
```
which builds from github release version 2.0.12 to yourdockerhubuser/hyperion.ng:latest image/tag

To run container itself
```
docker run -d -p 8090:8090 -p 8092:8092 -p 19400:19400 -p 19445:19445 -p 19444:19444 -p 19333:19333 -v /path/to/config:/hyperion --name hyperion.ng -it wahooli/hyperion.ng:latest
```

My images are tested on arm64 and amd64 platform