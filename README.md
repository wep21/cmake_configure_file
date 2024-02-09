# cmake_configure_file

This macro is alternative to cmake configure_file() in bazel, originally from [drake](https://github.com/RobotLocomotion/drake/blob/master/tools/workspace/cmake_configure_file.bzl).

## Usage

```
# MODULE.bazel
bazel_dep(name = "cmake_configure_file", version = "0.1.0")

# BUILD.bazel
load(
    "@cmake_configure_file//:cmake_configure_file.bzl",
    "cmake_configure_file",
)

cmake_configure_file(
    name = ...,
    src = ...,
    out = ...,
    defines = [
        ...,
    ],
    undefines = [
        ...,
    ],
    visibility = ["//visibility:private"],
)
```
