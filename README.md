Shell script creates `build_info.h` C header file with information about repository: branch, tags, timestamps, etc.
Include this header to access build information from code.

```
#!shell

$ ./build_info.sh -h
Usage:  build_info.sh [GitRepo] [TargetFile]
   GitRepo     Any path under Git VCS. If not specified, uses current folder
   TargetFile  Optional, default is /src/build_info.h

```