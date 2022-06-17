//
//  AppDelegate.swift
//  hw
//
//  Created by 虚幻 on 2022/6/16.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var maskWindow: MaskWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        maskWindow = MaskWindow()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let options = CGWindowListOption(arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements, .optionIncludingWindow)
            let windows = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID)! as NSArray
            let nws = windows.filter({ win in
                return (win as! NSDictionary)[kCGWindowLayer] as? Int == 0
            })
            print(nws.first)
            if let num = ((nws.first as! NSDictionary)[kCGWindowNumber] as? Int), num != self.maskWindow?.windowNumber {
                self.maskWindow?.order(.below, relativeTo: num)
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

