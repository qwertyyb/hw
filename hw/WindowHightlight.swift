//
//  WindowHightlight.swift
//  hw
//
//  Created by 虚幻 on 2022/6/19.
//

import Foundation
import Carbon
import Cocoa

class WindowHighlight {
    private var focusedAppObserver: Any?
    private var focusedWindowChangedObserver: AXObserver?
    let maskWindow: MaskWindow = MaskWindow()
    var disabled: Bool = false
    
    private func removeFocusedAppObserver() {
        guard let focusedAppObserver = focusedAppObserver else {
            return
        }
        NSWorkspace.shared.notificationCenter.removeObserver(focusedAppObserver)
        self.focusedAppObserver = nil
    }
    
    private func removeFocusedWindowObserver() {
        guard let observer = focusedWindowChangedObserver else {
            return
        }
        CFRunLoopRemoveSource(
            RunLoop.current.getCFRunLoop(),
            AXObserverGetRunLoopSource(observer),
            CFRunLoopMode.defaultMode
        )
        self.focusedWindowChangedObserver = nil
    }
    
    private func stopObserver() {
        removeFocusedAppObserver()
        removeFocusedWindowObserver()
    }
    
    private func startObserver() {
        focusedAppObserver = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil) { notification in
            print("focusedApplicationChanged")
            self.onFocusedApplicationChanged()
        }
        onFocusedWindowChanged()
    }
    
    private func getAXObserverCreate(_ application: pid_t, _ callback: @escaping ApplicationServices.AXObserverCallback) -> AXObserver? {
        var observer: AXObserver?
        guard AXObserverCreate(application, callback, &observer) == .success else {
            print("AXObserverCreate error: \(application)")
            return nil
        }
        return observer
    }
    
    func toggleDisable(_ disabled: Bool? = nil) {
        if disabled != nil {
            self.disabled = disabled!
        } else {
            self.disabled = !self.disabled
        }
        if self.disabled {
            stopObserver()
        } else {
            startObserver()
        }
    }
    
    func onFocusedWindowChanged() {
        let options = CGWindowListOption(arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements, .optionIncludingWindow)
        let windows = CGWindowListCopyWindowInfo(options, kCGNullWindowID)! as NSArray
        let nws = windows.filter({ win in
            return (win as! NSDictionary)[kCGWindowLayer] as? Int == 0
        })
        if let frontMostWin = nws.first as? NSDictionary,
            let frontMostWinNo = frontMostWin[kCGWindowNumber] as? Int,
           frontMostWinNo != self.maskWindow.windowNumber {
            self.maskWindow.order(.below, relativeTo: frontMostWinNo)
        }
    }
    
    private func addFrontmostAppFocusedWindowObserver() {
        guard let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier else {
            return
        }
        let application = AXUIElementCreateApplication(pid)
        focusedWindowChangedObserver = getAXObserverCreate(pid) { observer, axElement, notification, userData in
            print("focusedWindowChanged")
            guard let userData = userData else {
                print("Missing userData")
                return
            }
            let selfIns = Unmanaged<WindowHighlight>.fromOpaque(userData).takeUnretainedValue()
            selfIns.onFocusedWindowChanged()
        }
        guard let observer = focusedWindowChangedObserver else {
            return
        }
        CFRunLoopAddSource(
            RunLoop.current.getCFRunLoop(),
            AXObserverGetRunLoopSource(observer),
            .defaultMode
        )
        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let result = AXObserverAddNotification(observer, application, kAXFocusedWindowChangedNotification as CFString, selfPtr)
        guard result == .success || result == .notificationAlreadyRegistered else {
            print("AXObserverAddNotification failed: \(result.rawValue)")
            return
        }
    }
    
    func onFocusedApplicationChanged() {
        removeFocusedWindowObserver()
        addFrontmostAppFocusedWindowObserver()
        onFocusedWindowChanged()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.onFocusedWindowChanged()
        }
    }
    
    private init() {
        startObserver()
    }
    
    static let shared = WindowHighlight()
}
