import AppKit
import ApplicationServices

// `open -a Finder` only activates the app; it doesn't raise Finder's window
// if one is already open but behind other windows (a long-standing macOS
// bug). Talking to Finder's AXUIElement directly instead of routing through
// `System Events` (as an AppleScript-based fix would) skips an extra
// process hop and avoids `osascript`'s per-invocation compile cost.

guard let finder = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first else {
    exit(1)
}

finder.activate()

let app = AXUIElementCreateApplication(finder.processIdentifier)

// The raw AX window list includes a titleless entry for the desktop icon
// layer even when zero real Finder windows are open (AppleScript's own
// `count windows` excludes it) — filter it out or "no windows" never
// registers as empty and a new window never gets created.
func finderWindows() -> [AXUIElement] {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &value) == .success,
          let windows = value as? [AXUIElement] else {
        return []
    }
    return windows.filter { window in
        var title: CFTypeRef?
        AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &title)
        return !((title as? String) ?? "").isEmpty
    }
}

let windows = finderWindows()

if let window = windows.first {
    // An existing window can be stuck behind other windows (the bug this
    // tool exists to fix) — AXRaise brings it forward.
    AXUIElementPerformAction(window, kAXRaiseAction as CFString)
} else {
    // A raw compiled binary (not an .app bundle) can't reliably send Finder
    // an Apple Event via NSAppleScript — macOS's Automation permission
    // tracking doesn't attach to it, so the event gets silently dropped
    // with no prompt and no error. NSWorkspace doesn't need that
    // permission, and avoids the fork/exec cost of shelling out to `open`.
    // A freshly created window is already frontmost by default, so no
    // AXRaise (and no waiting for the AX server to catch up) is needed.
    NSWorkspace.shared.open(URL(fileURLWithPath: NSHomeDirectory()))
}

finder.activate()
