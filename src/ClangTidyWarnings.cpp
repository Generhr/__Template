#include "ClangTidyWarnings.h"

#include <iostream>

void ClangTidyWarnings::BadCode() {
    const char str[] = "This is bad code";
    std::cout << str << std::endl;
}
