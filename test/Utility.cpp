#include <gtest/gtest.h>

#include "Utility/Utility.h"

TEST(Utility, HelloWorld) {
    ASSERT_EQ(Utility::HelloWorld(), "Hello World!");
}
