#include <filesystem>
#include <fstream>
#include <iostream>

#include <fmt/format.h>
#include <spdlog/spdlog.h>
#include <cxxopts.hpp>
#include <nlohmann/json.hpp>

#include "ClangTidyWarnings.h"
#include "config.h"

using json = nlohmann::json;

int main(int argc, char** argv) {
    // Display library versions
    std::cout << "JSON: " << NLOHMANN_JSON_VERSION_MAJOR << "." << NLOHMANN_JSON_VERSION_MINOR << "."
              << NLOHMANN_JSON_VERSION_PATCH << '\n';
    std::cout << "FMT: " << FMT_VERSION << '\n';
    std::cout << "CXXOPTS: " << CXXOPTS__VERSION_MAJOR << "." << CXXOPTS__VERSION_MINOR << "." << CXXOPTS__VERSION_PATCH
              << '\n';
    std::cout << "SPDLOG: " << SPDLOG_VER_MAJOR << "." << SPDLOG_VER_MINOR << "." << SPDLOG_VER_PATCH << '\n';

    try {
        // The following code is used to ensure that the /EHsc (C++) exception handling model flag is set (stripped by
        // clang-tidy with the cl.exe compiler). It intentionally throws an exception but doesn't handle it.
        throw(0);
    }
    catch (int /* number */) {
        std::cout << "\nUsage Example:\n";
    }

    // This line ensures that ClangTidyWarnings.cpp is compiled to test whether it is correctly excluded from clang-tidy
    // as it is listed in `NO_STATIC_CODE_ANALYSIS_LIST`.
    ClangTidyWarnings example;

    // Address Sanitizer example (commented out)
    // int *x = new int[42];
    // x[100] = 5; // Boom!

    // Display welcome message
    const auto welcome_message = fmt::format("Welcome to {} v{}\n", project_name, project_version);
    spdlog::info(welcome_message);

    // Parse command line arguments
    cxxopts::Options options(project_name.data(), welcome_message);
    options.add_options("arguments")("h,help", "Print usage")("f,filename",
        "File name",
        cxxopts::value<std::string>())("v,verbose", "Verbose output", cxxopts::value<bool>()->default_value("false"));
    auto result = options.parse(argc, argv);

    if (argc == 1 || result.count("help") != 0) {
        std::cout << options.help() << '\n';

        return 0;
    }

    // Extract options
    auto filename = std::string {};
    auto verbose = false;

    if (result.count("filename") != 0) {
        filename = result["filename"].as<std::string>();
    }
    else {
        return 1;
    }

    verbose = result["verbose"].as<bool>();

    if (verbose) {
        fmt::print("Opening file: {}\n", filename);
    }

    // Open and parse a JSON file
    auto ifs = std::ifstream {filename};

    if (!ifs.is_open()) {
        fmt::print("Failed to open file: {}\n", filename);

        return 1;
    }

    const auto parsed_data = json::parse(ifs);

    if (verbose) {
        fmt::print("Name: {}\n", parsed_data["name"]);
    }

    return 0;
}
