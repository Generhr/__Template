#include "MyClass.h"

#include <stdexcept>

int MyClass::Divide(int a, int b) {
    if (b == 0) {
        throw std::runtime_error("Division by zero");
    }

    return a / b;
}

int MyClass::Add(int a, int b) {
    return a + b;
}

int MyClass::Subtract(int a, int b) {
    return a - b;
}
