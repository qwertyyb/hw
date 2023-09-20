//
//  WindowHightlight.swift
//  hw
//
//  Created by 虚幻 on 2022/6/19.
//

import Foundation
import Carbon
import Cocoa
import Combine

extension UserDefaults {
    @objc var ignoreApplications: [String] {
        get {
            return stringArray(forKey: "ignore_applications") ?? []
        }
        set {
            set(newValue, forKey: "ignore_applications")
        }
    }
}

class WindowHighlight {
    private var focusedWindowChangedObserver: AXObserver?
    private var subscriptions = Set<AnyCancellable>()

    var disabled: Bool = false
    var frontMostWin: NSDictionary?
    
    private func removeFocusedAppObserver() {
        subscriptions.forEach { cancellable in
            cancellable.cancel()
        }
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
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { _ in
                self.onFocusedApplicationChanged()
            }
            .store(in: &subscriptions)
        DispatchQueue.main.async {
            self.onFocusedWindowChanged()
        }
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
            MaskWindow.fadeOut()
            self.frontMostWin = nil
        } else {
            startObserver()
        }
    }
    
    func onFocusedWindowChanged() {
        NSLog("onFocusedWindowChanged")
        let options = CGWindowListOption(arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements, .optionIncludingWindow)
        let windows = CGWindowListCopyWindowInfo(options, kCGNullWindowID)! as NSArray
        let nws = windows.filter({ item in
            let win = item as! NSDictionary
            return win[kCGWindowLayer] as? Int == 0 && win[kCGWindowOwnerName] as! String != "Window Server"
        })
        if let frontMostWin = nws.first as? NSDictionary,
            let frontMostWinNo = frontMostWin[kCGWindowNumber] as? Int,
            self.frontMostWin != frontMostWin {
            self.frontMostWin = frontMostWin
            NSLog("frontMostWin: \(frontMostWin)")
            MaskWindow.fadeIn(frontMostWinNo: frontMostWinNo)
            
            let _ = refreshAppMenuItem()
        }
    }
    
    private func addFrontmostAppFocusedWindowObserver() {
        guard let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier else {
            return
        }
        NSLog("frontMostApplication: \(String(describing: NSWorkspace.shared.frontmostApplication?.localizedName))")
        
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
        
        let ignored = refreshAppMenuItem()
        
        if ignored {
            return
        }
        
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
    
    @objc
    func ignoreApplication() {
        guard let id = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else { return }
        let ignored = UserDefaults.standard.ignoreApplications.count > 0 && UserDefaults.standard.ignoreApplications.contains(id)
        if ignored {
            UserDefaults.standard.ignoreApplications = UserDefaults.standard.ignoreApplications.filter({ str in
                str != id
            })
            onFocusedWindowChanged()
        } else {
            UserDefaults.standard.ignoreApplications.append(id)
            MaskWindow.fadeOut()
            frontMostWin = nil
        }
        
        let _ = refreshAppMenuItem()
    }
    
    func refreshAppMenuItem() -> Bool {
        let ignored = UserDefaults.standard.ignoreApplications.contains(NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "unknown")
        StatusButton.shared.appMenuItem.title = "使用\(NSWorkspace.shared.frontmostApplication?.localizedName ?? "未知")时\(ignored ? "启用" : "禁用")"
        return ignored
    }
}
