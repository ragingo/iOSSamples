//
//  Cpp.hpp
//  Sample010-Cpp
//
//  Created by ragingo on 2022/09/22.
//

#pragma once
#include <cstdint>
#include <cstddef>

int cpp_add(int a, int b);

namespace CppMedia {

enum class MediaType: std::uint32_t {
    unknown = 0x0000,
    invalid = 0x0001,

    image = 0x80000000,
    jpeg  = image | 0x0001,
    png   = image | 0x0002,
    gif   = image | 0x0003,
    webp  = image | 0x0004,
};

class RgMedia {
public:
    static MediaType getType(const void* const data, std::size_t len);
};

};
