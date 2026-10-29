# Corner Magnet

A tiny, native macOS menu-bar utility that gently attracts the pointer toward a window's close, minimize, or zoom control when you are already moving toward it.

The first release is deliberately narrow: no window management, no overlays, no auto-clicking, no telemetry, no network access, and no launch-at-login behavior.

## Status

Prototype / early testing. The code is committed, but this environment cannot run macOS AppKit or verify real-world pointer behavior. Treat the current build as an experiment, not a release-ready utility.

## Requirements

- macOS 13 or later
- Swift 5.9+ / Xcode Command Line Tools
- Accessibility permission (to inspect window controls and move the pointer)

## Build

From this directory on a Mac:

```sh
swift test
./Scripts/build-app.sh
open "build/Corner Magnet.app"
```

The script assembles a small `.app` bundle and applies an ad-hoc signature for local use. It is not notarized or signed with a Developer ID.

## First run

1. Launch the app; it appears only in the menu bar.
2. Open its menu and enable Magnet.
3. Grant Accessibility permission when macOS asks, then relaunch or toggle Magnet on again.
4. Move the pointer toward a visible close / minimize / zoom button. The pointer is gently pulled toward the nearest eligible control; it is never clicked automatically.

The app starts disabled. A menu-bar toggle is always available to stop it immediately.

## Interaction design

- **Intent-aware:** attraction only applies when the pointer is moving toward a target, not away from it.
- **Bounded:** the pull only activates inside a small radius and eases the pointer partway toward the target.
- **No polling loop:** target geometry is refreshed only during pointer movement and throttled to at most 12.5 times per second.
- **Low idle cost:** when the pointer is still, no timer or animation runs.
- **Native controls:** uses AppKit, SwiftUI, Core Graphics and the macOS Accessibility API; no third-party dependencies.

## Known limitations

- Some applications use custom title bars or do not expose standard AX close/minimize/zoom controls. Those windows may not be eligible.
- Spaces, full-screen windows, unusual display arrangements and per-display coordinate conversion need real-device testing.
- The global mouse monitor and pointer warping must be tested on supported macOS versions. Accessibility permissions can vary with signing identity; rebuilds may require granting permission again.
- This prototype deliberately does not auto-click, change window state, record input, or inspect screen pixels.

## Architecture

- `Sources/CornerMagnet/CornerMagnetApp.swift`: menu-bar entry point and settings UI.
- `Sources/CornerMagnet/MagnetEngine.swift`: event-driven pointer attraction and target refresh throttling.
- `Sources/CornerMagnet/AccessibilityTargets.swift`: reads standard window-control bounds via AXUIElement.
- `Sources/CornerMagnet/AttractionMath.swift`: deterministic, testable geometry.
- `Tests/CornerMagnetTests`: geometry tests.

## License

MIT
