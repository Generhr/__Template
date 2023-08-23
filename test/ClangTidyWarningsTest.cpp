#include "ClangTidyWarnings.h"

#include <gtest/gtest.h>

TEST(ClangTidyWarningsTest, BadCode) {
    ClangTidyWarnings example;
    example.BadCode();
}
