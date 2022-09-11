#!/bin/bash

PATH="${PATH}:/opt/homebrew/bin"
xcrun --sdk macosx mint run realm/SwiftLint swiftlint --fix --format
