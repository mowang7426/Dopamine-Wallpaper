#!/bin/sh
set -eu
ROOT=${1:-/var/minis/workspace/dopamine_inspect/Payload/Dopamine.app}
THEOS=${THEOS:?Set THEOS to a Theos checkout with an iPhoneOS SDK}
make -C "$(dirname "$0")" package FINALPACKAGE=1
DYLIB="$(dirname "$0")/.theos/obj/arm64/DopamineWallpaper.dylib"
test -f "$DYLIB"
cp "$DYLIB" "$ROOT/DopamineWallpaper.dylib"
printf '%s\n' "Built $DYLIB; copy it into the app and add LC_LOAD_DYLIB @rpath/DopamineWallpaper.dylib with insert_dylib/optool." 
printf '%s\n' "Then re-sign the app and nested frameworks with ldid -S (or a valid Apple signing identity), and zip Payload." 
