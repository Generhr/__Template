#include <gtest/gtest.h>

TEST(CppStandard20, LambdaImprovements) {
    int x = 42;
    auto lambda = [x = std::move(x)]() mutable {
        x++;
        return x;
    };

    EXPECT_EQ(lambda(), 43);
}

#include <concepts>

template<typename T>
concept Integral = std::is_integral_v<T>;

TEST(CppStandard20, Concepts) {
    EXPECT_TRUE(Integral<int>);
    EXPECT_FALSE(Integral<double>);
}

#include <vector>
#include <ranges>

TEST(CppStandard20, Ranges) {
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    auto even_numbers = numbers | std::views::filter([](int n) { return n % 2 == 0; });

    EXPECT_EQ(std::ranges::distance(even_numbers), 2);
}
