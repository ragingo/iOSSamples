#!/bin/bash

PATH="${PATH}:/opt/homebrew/bin"
xcrun --sdk macosx mint run swiftlint --fix --format
