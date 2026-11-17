# Dopamine Wallpaper (experimental)

This repository contains an experimental Objective-C hook that adds a wallpaper picker to Dopamine's `DOMainViewController`.

The original IPA is intentionally not committed. It contains a compiled third-party application and must be supplied separately to the workflow as a private Actions artifact or local build input.

## Features

- Choose an image from the photo library.
- Persist it in the app Documents directory.
- Restore it when the app launches.
- Reset to the original background.

## Status

This is source and build automation only. The hook has not been device-tested. The resulting app must be re-signed for the target device, and RootHide compatibility must be verified on-device.

## Local build inputs

The workflow expects an uploaded artifact named `original-ipa` containing exactly one `.ipa` file. It builds on macOS, installs Theos, compiles the dylib, and stops after producing build inputs unless an injector and signing identity are explicitly configured.

Do not upload private signing certificates or jailbreak device credentials to this repository.
