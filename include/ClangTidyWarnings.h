#ifndef CLANG_TIDY_WARNINGS_H
#define CLANG_TIDY_WARNINGS_H

class ClangTidyExample {
public:
    ClangTidyExample();

    void Function(int value);

    void UnusedFunction(int value);

    void MissingOverride(int value);

private:
    int m_data;
};

#endif  // CLANG_TIDY_WARNINGS_H
