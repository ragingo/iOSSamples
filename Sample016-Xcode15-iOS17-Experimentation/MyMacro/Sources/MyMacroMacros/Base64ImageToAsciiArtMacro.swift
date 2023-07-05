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

        let dataOffset = try Bitmap.load(data)
        let w = 32
        let h = 32
        let bytesPerPixel = 3
        let bytesPerRow = w * bytesPerPixel
        let t = 140

        var pixels = ""

        (0..<h).forEach { row in
            (0..<w).forEach { col in
                let offset = dataOffset + row * bytesPerRow + col * bytesPerPixel
                let r = data[offset + 0]
                let g = data[offset + 1]
                let b = data[offset + 2]
                let isBlack = t < r && t < g && t < b
                pixels += (isBlack ? "■" : "□")
            }
            pixels += "\n"
        }

        return [
            "let a = \"\"\"\n\(raw: pixels)\"\"\""
        ]
    }
}

struct Bitmap {
    static func load(_ data: Data) throws -> Int {
        let result = try data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            var offset = 0

            let fileHeader = try parseFileHeader(ptr: ptr, offset: &offset)
            let infoHeader = try parseInfoHeader(ptr: ptr, offset: &offset)

//            throw Base64ImageToImageMacro.InvalidArgumentError(message: "\(fileHeader)")
//            throw Base64ImageToImageMacro.InvalidArgumentError(message: "\(infoHeader)")

            return offset
        }

        return result
    }

    private static func parseFileHeader(ptr: UnsafeRawBufferPointer, offset: inout Int) throws -> BitmapFileHeader {
        var fileHeader = BitmapFileHeader()

        // ちゃんと取れてる
        fileHeader.bfType = CFSwapInt16BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt16.self))
        offset += 2

        if !fileHeader.isValidType {
            throw Base64ImageToImageMacro.InvalidArgumentError(message: "invalid bfType")
        }

        // 壊れてるっぽい。間違えてるかも。
        fileHeader.bfSize = CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
        offset += 4

        fileHeader.bfReserved1 = CFSwapInt16BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt16.self))
        offset += 2

        fileHeader.bfReserved2 = CFSwapInt16BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt16.self))
        offset += 2

        // 壊れてるっぽい。間違えてるかも。
        fileHeader.bfOffBits = CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
        offset += 4

        return fileHeader
    }

    private static func parseInfoHeader(ptr: UnsafeRawBufferPointer, offset: inout Int) throws -> BitmapInfoHeader {
        var infoHeader = BitmapInfoHeader()

        infoHeader.biSize = CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
        offset += 4

        infoHeader.biWidth = Int32(CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)))
        offset += 4

        infoHeader.biHeight = Int32(CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)))
        offset += 4

        infoHeader.biPlanes = Int16(CFSwapInt16BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt16.self)))
        offset += 2

        infoHeader.biBitCount = Int16(CFSwapInt16BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt16.self)))
        offset += 2

        infoHeader.biCompression = CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
        offset += 4

        infoHeader.biSizeImage = CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
        offset += 4

        infoHeader.biXPelsPerMeter = Int32(CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)))
        offset += 4

        infoHeader.biYPelsPerMeter = Int32(CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)))
        offset += 4

        infoHeader.biClrUsed = CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
        offset += 4

        infoHeader.biClrImportant = CFSwapInt32BigToHost(ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
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
