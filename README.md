# C++ Project Template

![C++](https://img.shields.io/badge/C%2B%2B-11%2F14%2F17%2F20%2F23-blue)
[![Documentation](https://svgshare.com/i/vaA.svg)](https://onimuru.github.io/__Template/)
[![Continuous Integration](https://github.com/Onimuru/__Template/actions/workflows/continuous-integration.yml/badge.svg)](https://github.com/Onimuru/__Template/actions/workflows/continuous-integration.yml)
[![Codecov](https://codecov.io/gh/Onimuru/__Template/branch/main/graph/badge.svg?token=Z2CFXJ9IGL)](https://codecov.io/gh/Onimuru/__Template)
[![License](https://camo.githubusercontent.com/890acbdcb87868b382af9a4b1fac507b9659d9bf/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f6c6963656e73652d4d49542d626c75652e737667)](./LICENSE)


This is a template for C++ projects. What you get:

- Library, executable and test code separated in distinct folders
- Use of modern CMake for building and compiling
- External libraries installed and managed by [Vcpkg](https://github.com/microsoft/vcpkg) Package Manager
- Unit testing using [Googletest](https://github.com/google/googletest)
- General purpose libraries: [JSON](https://github.com/nlohmann/json), [spdlog](https://github.com/gabime/spdlog), [cxxopts](https://github.com/jarro2783/cxxopts) and [fmt](https://github.com/fmtlib/fmt)
- Continuous integration testing with Github Actions and [pre-commit](https://pre-commit.com/)
- Code documentation with [Doxygen](https://doxygen.nl/) and [Github Pages](https://onimuru.github.io/__Template/)
- Code analysis: [Cppcheck](https://sourceforge.net/p/cppcheck/wiki/Home/)
- Code coverage reports, including automatic upload to [Codecov](https://codecov.io)
- Tooling: CCache, Clang-Format, CMake-Format, and Sanitizers

## Structure

``` text
├── CMakeLists.txt
├── cmake
│   └── CMake modules
│   └── ...
├── doc
│   ├── Doxyfile
│   └── html/
├── external
│   ├── CMakesLists.txt
├── include
│   ├── pch.h
│   └── ...
├── lib
│   └── ...
├── src
│   └── Main.cpp
│   └── ...
└── test
    ├── CMakeLists.txt
    └── ...
```

Headers go in [include/](include/), source code in [src/](src/), and unit tests go in [test/](test/).

## Software Requirements

- [CMake](https://cmake.org/download/) v3.16+
- [GNU Makefile](https://ftp.gnu.org/gnu/make/)
- [Conan](https://conan.io/downloads.html) or [Vcpkg](https://vcpkg.io/en/getting-started)
- MSVC 2017 (or higher), G++9 (or higher), Clang++9 (or higher)
- (Optional) [Doxygen](https://www.doxygen.nl/download.html) and [Graphviz](https://graphviz.org/download/)
- (Optional) [Cppcheck](https://cppcheck.sourceforge.io/)
- (Optional, **GNU or Clang only**) Code Coverage: [lcov](https://pypi.org/project/lcov/) and [gcovr](https://gcovr.com/en/stable/installation.html)

## Additional setup

### GitHub

- Give your workflows write permission in Settings/Actions/General/Workflow permissions
- Setup [GitHub Pages](https://docs.github.com/en/pages/quickstart)

### Local Machine

- (Optional) Automate unit tests with [git hooks](https://www.redhat.com/sysadmin/git-hooks)
- (Optional) Install the various [hooks](https://pre-commit.com/hooks.html) listed in [.pre-commit-config.yaml](.pre-commit-config.yaml) for use with pre-commit or delete the file if you don't intend to use it. Pre-commit can be automated with git hooks like ctest above
- (Optional) Setup [Ccache](https://ccache.dev/) to speed up subsequent compilations. It is already built into the project but only runs if the program can be found
- (Optional, **Windows only**) If you have multiple projects, consider using [symlinks](https://blogs.windows.com/windowsdeveloper/2016/12/02/symlinks-windows-10/) to use the same formatting settings ([.clang-format](.clang-format), [.clang-tidy](.clang-tidy), etc..) for all your projects with a single file. There is a [batch](Tools/Symlink.bat) file that will perform this process automatically but you will need to change the source directory. [The first two lines](https://stackoverflow.com/a/52517718) are to run with admin privileges

## Building

First, clone this repo:

```shell
git clone --recursive https://github.com/Onimuru/__Template
```

- Documentation

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake --build . --config Debug --target doxygen
```

- Code Analysis

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake --build . --config Debug --target cppcheck
```

- Executable

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release
cd bin/Release
./<your project name>
```

- Unit testing

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake --build . --config Debug --target unit_tests
ctest -C Debug -VV
```

- Code Coverage (Unix only)

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DENABLE_CODE_COVERAGE=ON ..
cmake --build . --config Debug --target coverage
```

For more info about CMake see [here](./README_cmake.md).
