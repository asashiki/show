import AppKit
import ApplicationServices
import SwiftUI

@main
struct CornerMagnetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            MagnetSettingsView(engine: .shared)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "dot.scope", accessibilityDescription: "Corner Magnet")
            button.toolTip = "Corner Magnet"
            button.target = self
            button.action = #selector(togglePopover)
        }

        popover.behavior = .transient
        popover.contentSize = NSSize(width: 300, height: 330)
        popover.contentViewController = NSHostingController(
            rootView: MagnetSettingsView(engine: .shared)
        )
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        MagnetEngine.shared.setEnabled(false)
    }
}

struct MagnetSettingsView: View {
    @ObservedObject var engine: MagnetEngine

    private var hasAccessibility: Bool { AXIsProcessTrusted() }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "dot.scope")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Corner Magnet").font(.headline)
                    Text("A softer aim for window controls").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            Toggle(isOn: Binding(
                get: { engine.isEnabled },
                set: { engine.setEnabled($0) }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Enable magnet")
                    Text(engine.isEnabled ? "Active while you move the pointer" : "Off until you enable it")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("Attraction radius")
                    Spacer()
                    Text("\(Int(engine.radius)) pt").monospacedDigit().foregroundStyle(.secondary)
                }
                Slider(value: $engine.radius, in: 16...48, step: 2)
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("Pull strength")
                    Spacer()
                    Text("\(Int(engine.strength * 100))%").monospacedDigit().foregroundStyle(.secondary)
                }
                Slider(value: $engine.strength, in: 0.08...0.30, step: 0.02)
            }

            if !hasAccessibility {
                Text("Accessibility permission is needed to find native window controls.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Open Accessibility Settings") {
                    engine.openAccessibilitySettings()
                }
                .buttonStyle(.bordered)
            }

            Divider()

            HStack {
                Label("No auto-clicks", systemImage: "hand.raised")
                Spacer()
                Text("No network").foregroundStyle(.secondary)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(width: 300)
    }
}
