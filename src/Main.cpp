// #define FMT_HEADER_ONLY // may need this line

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
    std::cout << "JSON: " << NLOHMANN_JSON_VERSION_MAJOR << "." << NLOHMANN_JSON_VERSION_MINOR << "."
              << NLOHMANN_JSON_VERSION_PATCH << '\n';
    std::cout << "FMT: " << FMT_VERSION << '\n';
    std::cout << "CXXOPTS: " << CXXOPTS__VERSION_MAJOR << "." << CXXOPTS__VERSION_MINOR << "." << CXXOPTS__VERSION_PATCH
              << '\n';
    std::cout << "SPDLOG: " << SPDLOG_VER_MAJOR << "." << SPDLOG_VER_MINOR << "." << SPDLOG_VER_PATCH << '\n';
    std::cout << "\n\nUsage Example:\n";

    try {
        int age = 15;

        if (age >= 18) {
            fmt::print("Access granted - you are old enough.\n");
        }
        else {
            throw(age);
        }
    }
    catch (int myNum) {
        fmt::print("Access denied - You must be at least 18 years old.\n");
        fmt::print("Age is: {}\n", myNum);
    }

    ClangTidyExample example;
    int value = 42;

    example.Function(value);

    // Address Sanitizer should see this
    // int *x = new int[42];
    // x[100] = 5; // Boom!

    const auto welcome_message = fmt::format("Welcome to {} v{}\n", project_name, project_version);
    spdlog::info(welcome_message);

    cxxopts::Options options(project_name.data(), welcome_message);

    options.add_options("arguments")("h,help", "Print usage")("f,filename",
        "File name",
        cxxopts::value<std::string>())("v,verbose", "Verbose output", cxxopts::value<bool>()->default_value("false"));

    auto result = options.parse(argc, argv);

    if (argc == 1 || result.count("help") != 0) {
        std::cout << options.help() << '\n';
        return 0;
    }

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

    auto ifs = std::ifstream {filename};

    if (!ifs.is_open()) {
        return 1;
    }

    const auto parsed_data = json::parse(ifs);

    if (verbose) {
        fmt::print("Name: {}\n", parsed_data["name"]);
    }

    return 0;
}
