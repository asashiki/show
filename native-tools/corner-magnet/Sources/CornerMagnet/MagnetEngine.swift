import AppKit
import ApplicationServices
import Combine
import CoreGraphics

@MainActor
final class MagnetEngine: ObservableObject {
    static let shared = MagnetEngine()

    @Published private(set) var isEnabled = false
    @Published var radius: Double = 30
    @Published var strength: Double = 0.18

    private var monitor: Any?
    private var cachedTargets: [MagnetTarget] = []
    private var lastRefreshTime: TimeInterval = 0
    private var previousPoint: CGPoint?
    private let refreshInterval: TimeInterval = 0.08

    private init() {}

    func setEnabled(_ enabled: Bool) {
        guard enabled != isEnabled else { return }
        guard enabled else {
            stopMonitoring()
            isEnabled = false
            return
        }

        guard AXIsProcessTrusted() else {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            _ = AXIsProcessTrustedWithOptions(options)
            isEnabled = false
            return
        }

        isEnabled = true
        previousPoint = nil
        refreshTargets()
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            guard let point = event.cgEvent?.location else { return }
            self?.handlePointerMove(point)
        }
    }

    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    private func stopMonitoring() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        cachedTargets.removeAll(keepingCapacity: true)
        previousPoint = nil
    }

    private func refreshTargets() {
        cachedTargets = AccessibilityTargets.readFrontWindowTargets()
        lastRefreshTime = ProcessInfo.processInfo.systemUptime
    }

    private func handlePointerMove(_ point: CGPoint) {
        guard isEnabled else { return }
        let now = ProcessInfo.processInfo.systemUptime
        if now - lastRefreshTime >= refreshInterval {
            refreshTargets()
        }

        defer { previousPoint = point }
        guard let previousPoint else { return }

        let candidate = cachedTargets
            .compactMap { target -> (CGPoint, CGFloat)? in
                let dx = target.center.x - point.x
                let dy = target.center.y - point.y
                let distance = hypot(dx, dy)
                guard distance <= radius else { return nil }
                return (target.center, distance)
            }
            .min { $0.1 < $1.1 }

        guard let target = candidate?.0,
              let next = AttractionMath.nextPoint(
                current: point,
                previous: previousPoint,
                target: target,
                radius: CGFloat(radius),
                strength: CGFloat(strength)
              ) else { return }

        if CGWarpMouseCursorPosition(next) == .success {
            self.previousPoint = next
        }
    }
}
