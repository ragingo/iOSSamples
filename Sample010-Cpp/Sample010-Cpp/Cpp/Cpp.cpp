//
//  Cpp.cpp
//  Sample010-Cpp
//
//  Created by ragingo on 2022/09/22.
//

#include "Cpp.hpp"
#include <cassert>
#include <vector>

int cpp_add(int a, int b) {
    return a + b;
}

namespace {

inline std::vector<uint8_t> read_buff(const std::uint8_t* const ptr, std::size_t total_len, std::size_t& current, std::size_t read_len) {
    using ReturnType = std::vector<uint8_t>;

    if (!ptr) {
        return ReturnType();
    }
    if (current + read_len >= total_len) {
        return ReturnType();
    }

    auto result = ReturnType(ptr + current, ptr + current + read_len);
    current += read_len;
    return result;
}

// https://www.itu.int/rec/T-REC-T.871-201105-I/en
// https://github.com/corkami/formats/blob/master/image/jpeg.md
// https://en.wikipedia.org/wiki/JPEG_File_Interchange_Format
inline bool is_jpeg(const std::uint8_t* const data, std::size_t len) {
    std::size_t offset = 0;

    auto soi_marker = read_buff(data, len, offset, 2);
    if (soi_marker.size() != 2) {
        return false;
    }
    if (!(soi_marker[0] == 0xff && soi_marker[1] == 0xd8)) {
        return false;
    }

    auto app0_marker = read_buff(data, len, offset, 2);
    if (app0_marker.size() != 2) {
        return false;
    }
    if (!(app0_marker[0] == 0xff && app0_marker[1] == 0xe0)) {
        return false;
    }

    auto app0_len = read_buff(data, len, offset, 2);
    if (app0_len.size() != 2) {
        return false;
    }

    auto app0_id = read_buff(data, len, offset, 4);
    if (app0_id != std::vector<uint8_t> { 'J', 'F', 'I', 'F' }) {
        return false;
    }

    return true;
}

// https://en.wikipedia.org/wiki/Portable_Network_Graphics
inline bool is_png(const std::uint8_t* const data, std::size_t len) {
    std::size_t offset = 0;

    auto file_header = read_buff(data, len, offset, 8);
    if (file_header != std::vector<uint8_t> { 0x89, 'P', 'N', 'G', 0x0d, 0x0a, 0x1a, 0x0a }) {
        return false;
    }

    return true;
}

// https://ja.wikipedia.org/wiki/Graphics_Interchange_Format
// https://www.w3.org/Graphics/GIF/spec-gif87.txt
// https://www.w3.org/Graphics/GIF/spec-gif89a.txt
inline bool is_gif8xa(const std::uint8_t* const data, std::size_t len) {
    std::size_t offset = 0;

    const auto gif87a_signature = std::vector<uint8_t> { 'G', 'I', 'F', '8', '7', 'a' };
    const auto gif89a_signature = std::vector<uint8_t> { 'G', 'I', 'F', '8', '9', 'a' };
    auto signature = read_buff(data, len, offset, 6);
    if (signature != gif87a_signature && signature != gif89a_signature) {
        return false;
    }

    return true;
}

// https://developers.google.com/speed/webp/docs/riff_container
inline bool is_webp(const std::uint8_t* const data, std::size_t len) {
    std::size_t offset = 0;

    auto file_header = read_buff(data, len, offset, 4);
    if (file_header != std::vector<uint8_t> { 'R', 'I', 'F', 'F' }) {
        return false;
    }

    auto file_size = read_buff(data, len, offset, 4);
    if (file_size.size() != 4) {
        return false;
    }

    auto fourCC = read_buff(data, len, offset, 4);
    if (fourCC != std::vector<uint8_t> { 'W', 'E', 'B', 'P' }) {
        return false;
    }

    return true;
}

};

namespace CppMedia {

MediaType RgMedia::getType(const void* const data, std::size_t len) {
    assert(data);
    assert(len > 0);

    if (data == nullptr || len == 0) {
        return MediaType::invalid;
    }

    auto ptr = reinterpret_cast<const std::uint8_t* const>(data);

    if (is_jpeg(ptr, len)) {
        return MediaType::jpeg;
    }

    if (is_png(ptr, len)) {
        return MediaType::png;
    }

    if (is_gif8xa(ptr, len)) {
        return MediaType::gif;
    }

    if (is_webp(ptr, len)) {
        return MediaType::webp;
    }

    return MediaType::unknown;
};

};
