import AppKit
import ApplicationServices
import CoreGraphics

struct MagnetTarget {
    enum Kind: String {
        case close
        case minimize
        case zoom
    }

    let kind: Kind
    let center: CGPoint
}

enum AccessibilityTargets {
    static func readFrontWindowTargets() -> [MagnetTarget] {
        guard let app = NSWorkspace.shared.frontmostApplication,
              app.processIdentifier != ProcessInfo.processInfo.processIdentifier else {
            return []
        }

        let applicationElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowValue: CFTypeRef?
        var result = AXUIElementCopyAttributeValue(
            applicationElement,
            kAXFocusedWindowAttribute as CFString,
            &windowValue
        )
        if result != .success {
            result = AXUIElementCopyAttributeValue(
                applicationElement,
                kAXMainWindowAttribute as CFString,
                &windowValue
            )
        }
        guard result == .success, let windowValue else { return [] }

        let windowElement = unsafeBitCast(windowValue, to: AXUIElement.self)
        let attributes: [(MagnetTarget.Kind, CFString)] = [
            (.close, kAXCloseButtonAttribute as CFString),
            (.minimize, kAXMinimizeButtonAttribute as CFString),
            (.zoom, kAXZoomButtonAttribute as CFString)
        ]

        return attributes.compactMap { kind, attribute in
            var buttonValue: CFTypeRef?
            guard AXUIElementCopyAttributeValue(windowElement, attribute, &buttonValue) == .success,
                  let buttonValue else { return nil }
            let button = unsafeBitCast(buttonValue, to: AXUIElement.self)
            guard let frame = frame(of: button) else { return nil }
            return MagnetTarget(
                kind: kind,
                center: CGPoint(x: frame.midX, y: frame.midY)
            )
        }
    }

    private static func frame(of element: AXUIElement) -> CGRect? {
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionValue) == .success,
              AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeValue) == .success,
              let positionValue, let sizeValue,
              CFGetTypeID(positionValue) == AXValueGetTypeID(),
              CFGetTypeID(sizeValue) == AXValueGetTypeID() else { return nil }

        let position = unsafeBitCast(positionValue, to: AXValue.self)
        let size = unsafeBitCast(sizeValue, to: AXValue.self)
        var point = CGPoint.zero
        var dimensions = CGSize.zero
        guard AXValueGetValue(position, .cgPoint, &point),
              AXValueGetValue(size, .cgSize, &dimensions) else { return nil }
        return CGRect(origin: point, size: dimensions)
    }
}
