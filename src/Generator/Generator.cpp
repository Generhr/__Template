#include "Generator/Generator.h"

#include <algorithm>  // for shuffle
#include <numeric>    // for iota
#include <random>     // for random_device, mt19937
#include <string>     // for to_string
#include <vector>     // for vector, _Vector_const_iterator, _Vector_iterator
#include <xstring>    // for operator<<

std::stringstream& Generator::generate(std::stringstream& stream, const int range) {
    std::vector<int> data(range);
    std::iota(data.begin(), data.end(), 1);

    std::random_device rd;
    std::mt19937 g(rd());

    std::shuffle(data.begin(), data.end(), g);

    for (const auto n : data) {
        stream << std::to_string(n) << " ";
    }

    return stream;
}
