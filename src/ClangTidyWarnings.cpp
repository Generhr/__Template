#include "ClangTidyWarnings.h"

class DerivedExample : public ClangTidyExample {
public:
    // No override specifier for a virtual function
    void UnusedFunction(int value);

    // Function hides a non-virtual function from the base class
    void MissingOverride(int value);
};

ClangTidyExample::ClangTidyExample() {
    // Uninitialized member
    m_data = 0;
}

void ClangTidyExample::Function(int value) {
    // Unused parameter
    m_data = value;
}

void ClangTidyExample::UnusedFunction(int value) {
    // Unused parameter
    m_data = value;
}
