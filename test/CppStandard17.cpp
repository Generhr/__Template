#include <gtest/gtest.h>

TEST(CppStandard17, FoldExpressions) {
    auto sum = [](auto... values) { return (values + ... + 0); };

    EXPECT_EQ(sum(1, 2, 3, 4, 5), 15);
}

#include <memory>

TEST(CppStandard17, Memory) {
    std::unique_ptr<int> ptr;
    ptr = std::make_unique<int>(10);

    EXPECT_EQ(*ptr, 10);
}
