# Dopamine wallpaper modification report

## Result

No modified IPA was produced in this environment. The original IPA remains unchanged at:

`/var/minis/attachments/uploads/Dopamine_roothide_zqbb_3.0.13-29_20261104_141516.ipa`

A complete standalone Objective-C injection implementation is provided at `WallpaperHook.m`, with a Theos `Makefile` and `build_and_inject.sh` under this directory.

## Implementation

The dylib targets `DOMainViewController` discovered in the extracted Dopamine binary.

- Adds a `Wallpaper` navigation-bar menu to the main view.
- `Choose Wallpaper` opens `UIImagePickerController` for the photo library.
- Selected image is stored as `Documents/DopamineWallpaper.png`.
- Wallpaper is restored on startup and whenever the app's existing `setupBackground` runs.
- `Reset Wallpaper` deletes the persisted file and invokes the original background setup.
- Uses only app-local UI/storage and does not alter jailbreak internals.

## Static investigation

- Extracted target: `/var/minis/workspace/dopamine_inspect/Payload/Dopamine.app`.
- Main executable is Mach-O 64-bit arm64.
- Existing binary already links UIKit, Foundation, Photos, CoreGraphics, ImageIO and has `NSPhotoLibraryUsageDescription`.
- Existing classes and selectors include `DOMainViewController`, `backgroundImageView`, `setupBackground`, and photo-picker delegate methods, making the hook target explicit.
- Existing app has an `LC_CODE_SIGNATURE`; modifying its executable/bundle would require re-signing.

## Blockers

The Alpine environment has clang and LLVM Mach-O inspection tools, but no iPhoneOS SDK, Theos checkout, `ldid`, `codesign`, `insert_dylib`, or `optool`. Local `/var/minis/workspace` and `/var/minis/shared` searches found no usable SDK/toolchain. An attempted public SDK download failed with a TLS EOF before transfer completed. Alpine's package repository has no `ldid` package.

Without an iOS SDK and Mach-O load-command injector, it is not technically valid to claim a built or installable IPA. Ad-hoc signing also cannot preserve the original Apple signature/entitlements without a signing implementation and identity; RootHide-specific runtime behavior further requires device validation.

## Reproduction when toolchain is available

1. Set `THEOS` to a Theos checkout containing an iPhoneOS SDK.
2. Run `make -C /var/minis/workspace/dopamine_wallpaper package FINALPACKAGE=1`.
3. Copy the resulting `DopamineWallpaper.dylib` into `Dopamine.app`.
4. Add `LC_LOAD_DYLIB @rpath/DopamineWallpaper.dylib` to the arm64 executable using a verified Mach-O injector.
5. Re-sign the app and every nested framework/dylib with a valid ad-hoc or Apple identity, preserving required entitlements.
6. Rebuild the IPA with `Payload` at its root and verify code signatures before device testing.

## Validation performed

- Source and build files were written successfully.
- Target class/selector/framework strings were confirmed in the original executable.
- Original IPA file was not modified.
- No runtime/device test was possible.
- No claim is made that the hook compiles, loads, presents the picker, persists, or resets successfully until built, signed, installed, and exercised on a compatible device.
