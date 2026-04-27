#!/bin/bash
set -e
cd "$(dirname "$0")"
xcodebuild -project BetterPWA.xcodeproj -scheme BetterPWA -configuration Release build