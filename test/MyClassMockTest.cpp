#include "MyClass.h"

#include <gtest/gtest.h>
#include <gmock/gmock.h>

class MockMyClass : public MyClass {
public:
    MOCK_METHOD(int, Divide, (int a, int b), (override));
    MOCK_METHOD(int, Add, (int a, int b), (override));
    MOCK_METHOD(int, Subtract, (int a, int b), (override));
};

class MyClassMockTest : public ::testing::Test {
protected:
    MockMyClass myMockClass;

    void SetUp() override {
        // Perform any setup required for the tests
    }

    void TearDown() override {
        // Perform any cleanup after the tests
    }
};

TEST_F(MyClassMockTest, Divide) {
    // Set an expectation that Divide will throw an exception
    EXPECT_CALL(myMockClass, Divide(5, 0)).WillOnce(::testing::Throw(std::runtime_error("Division by zero")));

    // Test that calling Divide(5, 0) throws an exception
    EXPECT_THROW(myMockClass.Divide(5, 0), std::runtime_error);

    // Verify that the expectation is met
    ::testing::Mock::VerifyAndClearExpectations(&myMockClass);
}

TEST_F(MyClassMockTest, Add) {
    EXPECT_CALL(myMockClass, Add(2, 3)).WillOnce(::testing::Return(5));
    EXPECT_EQ(myMockClass.Add(2, 3), 5);
}

TEST_F(MyClassMockTest, Subtract) {
    EXPECT_CALL(myMockClass, Subtract(5, 3)).WillOnce(::testing::Return(2));
    EXPECT_EQ(myMockClass.Subtract(5, 3), 2);
}
