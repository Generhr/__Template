#ifndef PCH_H
#define PCH_H

#ifdef CXX_STANDARD_98
#error "C++11 or better is required."
#endif

#include <algorithm>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <string>

//* C++ Style

#include <list>
#include <map>
#include <stack>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

//* Algorithms

#include <algorithm>
#include <cstdlib>
#include <numeric>

//* Concepts

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<concepts>)
#include <concepts>
#endif
#endif
#endif

//* Sequence Containers

#include <array>
#include <deque>
#include <forward_list>
#include <list>
#include <vector>

//* Ordered Associative Containers

#include <map>
#include <set>

//* Unordered Associative Containers

#include <unordered_map>
#include <unordered_set>

//* Container Adaptors

#include <queue>
#include <stack>

//* Container Views

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<span>)
#include <span>
#endif
#endif
#endif

//* Errors and Exception Handling

#include <cassert>
#include <exception>
#include <stdexcept>
#include <system_error>

//* General Utilities

#include <any>

#include <bitset>
#include <cstdlib>

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<execution>)
#include <execution>
#endif
#endif
#endif

#include <functional>
#include <memory>

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<memory_resource>)
#include <memory_resource>
#endif
#endif
#endif

#include <optional>
#include <ratio>
#include <scoped_allocator>
#include <tuple>
#include <type_traits>
#include <typeindex>
#include <utility>
#include <variant>

//* Multithreading

#include <atomic>
#include <condition_variable>
#include <future>
#include <mutex>
#include <shared_mutex>
#include <thread>

//* I/O and Formatting

#include <cinttypes>
#include <cstdio>

#ifdef CXX_STANDARD_20
#ifdef __has_include
#if __has_include(<filesystem>)
#include <filesystem>
#endif
#endif
#endif

#include <fstream>
#include <iomanip>
#include <ios>
#include <iosfwd>
#include <iostream>
#include <istream>
#include <ostream>
#include <sstream>
#include <streambuf>

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<syncstream>)
#include <syncstream>
#endif
#endif
#endif

//* Iterators

#include <iterator>

//* Language Support

#include <cfloat>
#include <climits>
#include <codecvt>


#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<compare>)
#include <compare>
#endif
#endif
#endif

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<contract>)
#include <contract>
#endif
#endif
#endif

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<coroutine>)
#include <coroutine>
#endif
#endif
#endif

#include <csetjmp>
#include <csignal>
#include <cstdarg>
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <exception>
#include <initializer_list>
#include <limits>
#include <new>
#include <typeinfo>

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<version>)
#include <version>
#endif
#endif
#endif

//* Ranges

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<ranges>)
#include <ranges>
#endif
#endif
#endif

//* Regular expressions

#include <regex>

//* Strings and character data

#include <cctype>
#include <charconv>
#include <cstdlib>
#include <cstring>

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<cuchar>)
#include <cuchar>
#endif
#endif
#endif

#include <cwchar>
#include <cwctype>
#include <regex>
#include <string>
#include <string_view>

//* Time

#include <chrono>
#include <ctime>

//* C-style Under C++

#include <cassert>
#include <cctype>
#include <cerrno>
#include <cfenv>
#include <cfloat>
#include <cinttypes>
#include <ciso646>
#include <climits>
#include <clocale>
#include <cmath>
#include <csetjmp>
#include <csignal>
#include <cstdarg>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <cwchar>
#include <cwctype>

//* Localization

#include <clocale>
#include <codecvt>
#include <locale>

//* Math and Numerics

#if defined(CXX_STANDARD_20)
#ifdef __has_include
#if __has_include(<bit>)
#include <bit>
#endif
#endif
#endif
#include <cfenv>
#include <cmath>
#include <complex>
#include <cstdlib>
#include <limits>
#include <numeric>
#include <random>
#include <ratio>
#include <valarray>

//* Memory management

#ifdef __has_include
#if __has_include(<allocators>)
#include <allocators>
#endif
#endif
#include <memory>
#ifdef __has_include
#if __has_include(<memory_resource>)
#include <memory_resource>
#endif
#endif
#include <new>
#include <scoped_allocator>

#ifdef _MSC_VER
#include <intrin.h>
#endif

#if __cpp_lib_json
#include <json>
#else
#if __has_include(<boost/json.hpp>)
#include <boost/json.hpp>
#elif __has_include(<json/json.h>)
#include <json/json.h>
#endif
#endif

#if __cpp_lib_format
#include <format>
#else
#if __has_include(<boost/format.hpp>)
#include <boost/format.hpp>
#elif __has_include(<fmt/format.h>)
#include <fmt/format.h>
#endif
#endif

#endif  // PCH_H
