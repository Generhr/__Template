#include "MyClass.h"

#include <gtest/gtest.h>

class MyClassTest : public ::testing::Test {
protected:
    MyClass myClass;

    void SetUp() override {
        // Perform any setup required for the tests
    }

    void TearDown() override {
        // Perform any cleanup after the tests
    }
};

TEST_F(MyClassTest, Divide) {
    // Test that a division by zero throws an exception
    EXPECT_THROW(myClass.Divide(5, 0), std::runtime_error);

    // Test that a valid division does not throw an exception
    EXPECT_NO_THROW(myClass.Divide(10, 2));
}

TEST_F(MyClassTest, Add) {
    EXPECT_EQ(myClass.Add(2, 3), 5);
    EXPECT_EQ(myClass.Add(-2, 3), 1);
    // Add more test cases as needed
}

TEST_F(MyClassTest, Subtract) {
    EXPECT_EQ(myClass.Subtract(5, 3), 2);
    EXPECT_EQ(myClass.Subtract(3, 5), -2);
    // Add more test cases as needed
}
