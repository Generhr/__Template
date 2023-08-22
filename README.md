# C++ Project Template

[![Continuous Integration](https://github.com/Onimuru/__Template/actions/workflows/continuous-integration.yml/badge.svg)](https://github.com/Onimuru/__Template/actions/workflows/continuous-integration.yml)
[![Documentation](https://svgshare.com/i/vaA.svg)](https://onimuru.github.io/__Template/)
[![Codecov](https://codecov.io/gh/Onimuru/__Template/branch/main/graph/badge.svg?token=Z2CFXJ9IGL)](https://codecov.io/gh/Onimuru/__Template)
[![License](https://camo.githubusercontent.com/890acbdcb87868b382af9a4b1fac507b9659d9bf/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f6c6963656e73652d4d49542d626c75652e737667)](./LICENSE)


This is a template for C++ projects. What you get:

- Use of modern CMake for building and compiling
- External libraries installed and managed by [Vcpkg](https://github.com/microsoft/vcpkg) Package Manager:
  - [JSON](https://github.com/nlohmann/json)
  - [spdlog](https://github.com/gabime/spdlog)
  - [cxxopts](https://github.com/jarro2783/cxxopts)
  - [fmt](https://github.com/fmtlib/fmt)
- Tooling: Automatically update submodules, [CCache](https://ccache.dev/), and Sanitizers
- Code analysis with [Cppcheck](https://sourceforge.net/p/cppcheck/wiki/Home/), [Clang-Tidy](https://clang.llvm.org/extra/clang-tidy/), and [Include what you use](https://include-what-you-use.org/)
- Unit testing with [Googletest](https://github.com/google/googletest)
- Code coverage reports, including automatic upload to [Codecov](https://codecov.io)
- Code documentation with [Doxygen](https://doxygen.nl/) and [Github Pages](https://onimuru.github.io/__Template/)
- Continuous integration testing with Github Actions and [pre-commit](https://pre-commit.com/)

## Structure

``` text
├── CMakeLists.txt
├── cmake
│   ├── CMake modules
│   └── ...
├── docs
│   └── html/
├── external
│   ├── vcpkg/
│   └── CMakesLists.txt
├── include
│   ├── pch.h
│   └── ...
├── lib
│   └── ...
├── src
│   ├── Main.cpp
│   └── ...
└── test
    ├── CMakeLists.txt
    └── ...
```

Headers go in [include/](include/), source code in [src/](src/), and unit tests go in [test/](test/)

## Software Requirements

**These can be [installed](tools/__Setup/) with choco and pip on windows by running [Install.bat](tools/__Setup/Install.bat) (choco and pip must be installed manually)**

- [CMake](https://cmake.org/download/) v3.21+
- [GNU Makefile](https://ftp.gnu.org/gnu/make/)
- MSVC 2017 (or higher), G++9 (or higher), or Clang++9 (or higher)
- [Vcpkg](https://vcpkg.io/en/getting-started) (included as a [submodule](external/vcpkg/))
- (Optional) Tooling:
  - [Ccache](https://ccache.dev/download.html)
- (Optional) Static analyzers:
  - [Cppcheck](https://cppcheck.sourceforge.io/)
  - [Clang-Tidy](https://releases.llvm.org/download.html)
  - [Include what you use](https://include-what-you-use.org/downloads/) (this must be built manually, I think I successfully build it on windows with Clang)
- (Optional, **Clang compiler only**) Code Coverage: [llvm-profdata](https://llvm.org/docs/CommandGuide/llvm-profdata.html) and [llvm-cov](https://llvm.org/docs/CommandGuide/llvm-cov.html) (download with [LLVM](https://releases.llvm.org/download.html))
- (Optional) Documentation: [Doxygen](https://www.doxygen.nl/download.html) and [Graphviz](https://graphviz.org/download/) (not really necessary to install this locally as documentation can be built and automatically deployed by workflows)

## Additional setup

### GitHub

- Allow [template janitor](.github/workflows/template-janitor.yml) workflow to complete, this will rename various placeholders in the CMake files to your new project name and also delete some files that you don't need
- Give your workflows write permission in Settings/Actions/General/Workflow permissions ([documentation](.github/workflows/documentation.yml) will fail to deploy to [gh-pages](https://github.com/Onimuru/__Template/tree/gh-pages) unless this is done)
- Setup [GitHub Pages](https://docs.github.com/en/pages/quickstart)

### Local Machine

- Ensure all software is in your `PATH` environment variable (relaunch VSCode or cmd for the changes to be recognised)
- (Optional) If you're using the Clang compiler, add a variable called `EXTERNAL_INCLUDE` to your environment variables (system or user) and give it the paths to the various windows headers provided by Visual Studio. The reason the variable is called `EXTERNAL_INCLUDE` is because github workflows use this variable too. For instance the headers currently needed by this project:
```shell
C:\Program Files\Microsoft Visual Studio\2022\Preview\VC\Tools\MSVC\14.38.32919\include
C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\um
C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\shared
C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\ucrt
C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\winrt
```
- Modify `CMAKE_C_COMPILER` and `CMAKE_CXX_COMPILER` in [CMakeUserPresets.json](CMakeUserPresets.json) to the compiler you wish to use
- Modify `"generator"` in [CMakeUserPresets.json](CMakeUserPresets.json) to the generator you wish to use although this project is geared towards Ninja or Ninja-Multi-Config generators
- (Optional) Automate unit tests with [git hooks](https://www.redhat.com/sysadmin/git-hooks) (for example: [pre-commit](tools/__Setup/pre-commit))
- (Optional) Install the various [hooks](https://pre-commit.com/hooks.html) listed in [.pre-commit-config.yaml](.pre-commit-config.yaml) for use with pre-commit or delete the file if you don't intend to use it. Pre-commit can be automated with git hooks like ctest above

## Building

First, clone this repo:

```shell
git clone --recursive https://github.com/<your github username>/<your repository name>
```

Now ideally use VSCode with [CMake Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools) which will read from [CMakeUserPresets.json](CMakeUserPresets.json) and give you a nice toolbar on the bottom of the VSCode window to switch between configurations. Alternatively you can build the project manually on the command line:

- Executable

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXECUTABLE=ON ..
cmake --build . --config Release
cd bin
./<your project name>.exe
```

- Unit testing

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake --build . --config Debug --target unit_tests
ctest -C Debug -VV
```

- Code Coverage (**Clang compiler only**)

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DENABLE_CODE_COVERAGE=ON ..
cmake --build . --config Debug --target unit_tests
```

- Documentation

```shell
cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DENABLE_DOXYGEN=ON ..
cmake --build . --config Debug --target doxygen
```

For more info about CMake see [here](./README_cmake.md).
