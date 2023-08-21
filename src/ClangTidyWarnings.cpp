#include "ClangTidyWarnings.h"

ClangTidyWarnings::ClangTidyWarnings() : m_data(0) {
}

void ClangTidyWarnings::UnusedParameter(int unusedParam) {
    // Warning: Parameter 'unusedParam' is unused
}

void ClangTidyWarnings::ShadowedMember(int m_data) {
    // Warning: Parameter 'm_data' shadows a class member
}

int ClangTidyWarnings::UninitializedMember() {
    // Warning: Member 'm_data' is not initialized in this constructor
    return m_data;
}

void ClangTidyWarnings::RedundantIf(bool condition) {
    if (condition) {
        // Warning: Redundant if statement
    }
}

void ClangTidyWarnings::NullPtrCheck(int* ptr) {
    if (ptr != nullptr) {
        // Warning: Consider using 'if (ptr)' instead
    }
}

void ClangTidyWarnings::NonConstLoopVariable() {
    for (int i = 0; i < 10; ++i) {
        // Warning: Loop variable 'i' should be declared as const
    }
}

void ClangTidyWarnings::LongLineExceedingLimit() {
    // Warning: Line exceeds a recommended limit
    int aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa = 42;
}
