//
//  AppDelegate.swift
//  hw
//
//  Created by 虚幻 on 2022/6/16.
//

import Cocoa
import Sparkle

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var windowHighlight: WindowHighlight?
    var statusButton: StatusButton?
    @IBOutlet weak var updater: SPUStandardUpdaterController!
    
    func toGrant() {
        Accessibility.requestPermission {
            self.windowHighlight = WindowHighlight.shared
            self.statusButton = StatusButton.shared
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if Accessibility.hasPermission {
            windowHighlight = WindowHighlight.shared
            statusButton = StatusButton.shared
        } else {
            let alert = NSAlert()
            alert.messageText = "需要辅助功能权限才能正常使用此应用"
            alert.addButton(withTitle: "去授权")
            alert.addButton(withTitle: "退出应用")
            NSApp.activate(ignoringOtherApps: true)
            alert.buttons[1].refusesFirstResponder = true
            let result = alert.runModal()
            if result == .alertFirstButtonReturn {
                toGrant()
            } else {
                NSApp.terminate(self)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

