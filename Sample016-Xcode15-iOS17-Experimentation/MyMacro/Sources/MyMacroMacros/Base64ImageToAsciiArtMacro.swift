//
//  Base64ImageToAsciiArtMacro.swift
//
//
//  Created by ragingo on 2023/07/02.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Base64ImageToAsciiArtMacro: DeclarationMacro {
    public struct InvalidArgumentError: Error {
        let message: String
    }

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let expression = node.argumentList.first?.expression else {
            fatalError("compiler bug")
        }

        // expression.description はソースコードそのもの。変数指定ならその変数名が入っているだけ。
        // 変数だった場合、「その中身」を取り出さないといけない。
        guard let data = Data(base64Encoded: expression.description, options: .ignoreUnknownCharacters) else {
            throw InvalidArgumentError(message: "base64 decode error")
        }

        // BitmapFileHeader(bfType: 16973, bfSize: 3126, bfReserved1: 0, bfReserved2: 0, bfOffBits: 54)
        // BitmapInfoHeader(biSize: 40, biWidth: 32, biHeight: 32, biPlanes: 1, biBitCount: 24, biCompression: 0, biSizeImage: 3072, biXPelsPerMeter: 0, biYPelsPerMeter: 0, biClrUsed: 0, biClrImportant: 0)
        let (fileHeader, infoHeader, _) = try Bitmap.load(data)

        let dataOffset = Int(fileHeader.bfOffBits)
        let w = Int(infoHeader.biWidth)
        let h = Int(infoHeader.biHeight)
        let bytesPerPixel = Int(infoHeader.biBitCount) / 8
        let bytesPerRow = w * bytesPerPixel
        let threshold = 0x20

        var pixels = ""

        (0..<h).forEach { row in
            let row = infoHeader.biHeight >= 0 ? (h-1) - row : row

            (0..<w).forEach { col in
                let offset = dataOffset + row * bytesPerRow + col * bytesPerPixel
                var r = data[offset + 0]
                var g = data[offset + 1]
                var b = data[offset + 2]

                if r < threshold {
                    r = 0
                }
                if g < threshold {
                    g = 0
                }
                if b < threshold {
                    b = 0
                }

                let isBlack = r == 0 && g == 0 && b == 0
                let isRed = r >= max(g, b)
                let isGreen = g >= max(r, b)
                let isBlue = b >= max(r, g)

                if isBlack {
                    pixels += "⬛"
                } else if isRed {
                    pixels += "🟥"
                } else if isGreen {
                    pixels += "🟩"
                } else if isBlue {
                    pixels += "🟦"
                } else {
                    pixels += "⬜"
                }
            }
            pixels += "\n"
        }

        return [
            "let a = \"\"\"\n\(raw: pixels)\"\"\""
        ]
    }
}

struct Bitmap {
    static func load(_ data: Data) throws -> (BitmapFileHeader, BitmapInfoHeader, Int) {
        return try data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            var dataOffset = 0

            let fileHeader = try parseFileHeader(ptr: ptr, offset: &dataOffset)
            let infoHeader = try parseInfoHeader(ptr: ptr, offset: &dataOffset)

            return (fileHeader, infoHeader, dataOffset)
        }
    }

    private static func parseFileHeader(ptr: UnsafeRawBufferPointer, offset: inout Int) throws -> BitmapFileHeader {
        var fileHeader = BitmapFileHeader()

        // ちゃんと取れてる
        fileHeader.bfType = CFSwapInt16BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt16.self))
        offset += 2

        if !fileHeader.isValidType {
            throw Base64ImageToImageMacro.InvalidArgumentError(message: "invalid bfType")
        }

        fileHeader.bfSize = ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        offset += 4

        fileHeader.bfReserved1 = ptr.loadUnaligned(fromByteOffset: offset, as: UInt16.self)
        offset += 2

        fileHeader.bfReserved2 = ptr.loadUnaligned(fromByteOffset: offset, as: UInt16.self)
        offset += 2

        fileHeader.bfOffBits = ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        offset += 4

        return fileHeader
    }

    private static func parseInfoHeader(ptr: UnsafeRawBufferPointer, offset: inout Int) throws -> BitmapInfoHeader {
        var infoHeader = BitmapInfoHeader()

        infoHeader.biSize = ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        offset += 4

        infoHeader.biWidth = ptr.loadUnaligned(fromByteOffset: offset, as: Int32.self)
        offset += 4

        infoHeader.biHeight = ptr.loadUnaligned(fromByteOffset: offset, as: Int32.self)
        offset += 4

        infoHeader.biPlanes = ptr.loadUnaligned(fromByteOffset: offset, as: Int16.self)
        offset += 2

        infoHeader.biBitCount = ptr.loadUnaligned(fromByteOffset: offset, as: Int16.self)
        offset += 2

        infoHeader.biCompression = ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        offset += 4

        infoHeader.biSizeImage = ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        offset += 4

        infoHeader.biXPelsPerMeter = ptr.loadUnaligned(fromByteOffset: offset, as: Int32.self)
        offset += 4

        infoHeader.biYPelsPerMeter = ptr.loadUnaligned(fromByteOffset: offset, as: Int32.self)
        offset += 4

        infoHeader.biClrUsed = ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        offset += 4

        infoHeader.biClrImportant = ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        offset += 4

        return infoHeader
    }
}

// https://learn.microsoft.com/ja-jp/windows/win32/api/wingdi/ns-wingdi-bitmapfileheader
struct BitmapFileHeader {
    var bfType: UInt16 = 0
    var bfSize: UInt32 = 0
    var bfReserved1: UInt16 = 0
    var bfReserved2: UInt16 = 0
    var bfOffBits: UInt32 = 0

    var isValidType: Bool {
        bfType >> 8 == Character("B").asciiValue! &&
        bfType & 0xff == Character("M").asciiValue!
    }
}

// https://learn.microsoft.com/ja-jp/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
struct BitmapInfoHeader {
    var biSize: UInt32 = 0
    var biWidth: Int32 = 0
    var biHeight: Int32 = 0
    var biPlanes: Int16 = 0
    var biBitCount: Int16 = 0
    var biCompression: UInt32 = 0
    var biSizeImage: UInt32 = 0
    var biXPelsPerMeter: Int32 = 0
    var biYPelsPerMeter: Int32 = 0
    var biClrUsed: UInt32 = 0
    var biClrImportant: UInt32 = 0
}
