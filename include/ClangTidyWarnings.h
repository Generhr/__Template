#pragma once

class ClangTidyWarnings {
public:
    ClangTidyWarnings();

    // Function with an unused parameter
    void UnusedParameter(int unusedParam);

    // Function with a variable that shadows a class member
    void ShadowedMember(int m_data);

    // Function with a potentially uninitialized member variable
    int UninitializedMember();

    // Function with a redundant if statement
    void RedundantIf(bool condition);

    // Function with a pointer that could be nullptr
    void NullPtrCheck(int* ptr);

    // Function with a loop variable that should be const
    void NonConstLoopVariable();

    // Function with a long line exceeding a recommended limit
    void LongLineExceedingLimit();

private:
    int m_data;
};
