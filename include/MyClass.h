#pragma once

class MyClass {
public:
    MyClass() = default;
    virtual ~MyClass() = default;

    MyClass(const MyClass&) = default;
    MyClass& operator=(const MyClass&) = default;
    MyClass(MyClass&&) = default;
    MyClass& operator=(MyClass&&) = default;

    virtual int Divide(int a, int b);
    virtual int Add(int a, int b);
    virtual int Subtract(int a, int b);
};
