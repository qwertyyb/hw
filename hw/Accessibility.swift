//
//  Accessibility.swift
//  hw
//
//  Created by 虚幻 on 2022/6/19.
//

import Foundation
import Carbon

class Accessibility {
    static var hasPermission: Bool {
        AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeUnretainedValue(): false
        ] as CFDictionary)
    }
    
    private static func checkPermission(callback: @escaping () -> Void) {
        guard hasPermission else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("request Permission")
                checkPermission(callback: callback)
            }
            return
        }
        callback()
    }
    
    static func requestPermission(callback: @escaping () -> Void) {
        if hasPermission {
            callback()
            return
        }
        AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true
        ] as CFDictionary)
        checkPermission(callback: callback)
        return
    }
}
