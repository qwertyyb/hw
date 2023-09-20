//
//  StatusButton.swift
//  hw
//
//  Created by 虚幻 on 2022/6/19.
//

import Foundation
import AppKit
import Sparkle

extension UserDefaults {
    @objc var maskOpacity: Float {
        get {
            let opacity = float(forKey: "mask_opacity")
            return opacity == 0 ? 0.3 : opacity
        }
        set {
            set(newValue, forKey: "mask_opacity")
        }
    }
}

class StatusButton {
    private let statusItem: NSStatusItem
    let appMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")

    @objc func quitApp() {
        NSApp.terminate(self)
    }
    @objc func toggle() {
        WindowHighlight.shared.toggleDisable();
        statusItem.menu?.item(at: 0)?.title = WindowHighlight.shared.disabled ? "启用" : "禁用"
    }
    @objc func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel()
    }
    
    @objc func sliderValueChange(slider: NSSlider) {
        UserDefaults.standard.maskOpacity = slider.floatValue
        MaskWindow.updateOpacity()
    }
    
    private func createProgressMenuItem() -> NSMenuItem {
        let container = NSStackView(frame: NSRect(x: 0, y: 0, width: 300, height: 30))
        container.orientation = .horizontal
        container.edgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0)
        
        let slider = NSSlider(frame: NSRect(x: 0, y: 0, width: 300, height: 30))
        slider.sizeToFit()
        slider.controlSize = .large
        slider.minValue = 0
        slider.maxValue = 1
        slider.floatValue = 0.3
        slider.target = self
        slider.action = #selector(sliderValueChange)
        
        container.addView(slider, in: .center)
        
        let item = NSMenuItem()
        item.view = container
        
        return item
    }

    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let image = NSImage(named: "StatusIcon")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.isVisible = true
        
        appMenuItem.target = WindowHighlight.shared
        appMenuItem.action = #selector(WindowHighlight.shared.ignoreApplication)
        
        let menu = NSMenu()
        menu.minimumWidth = 120
        var item = menu.addItem(withTitle: "禁用", action: #selector(StatusButton.toggle), keyEquivalent: "")
        item.target = self
        
        menu.addItem(createProgressMenuItem())
        
        menu.addItem(appMenuItem)
        
        item = menu.addItem(withTitle: "检查更新", action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)), keyEquivalent: "")
        item.target = (NSApp.delegate as! AppDelegate).updater
        item = menu.addItem(withTitle: "关于HW", action: #selector(StatusButton.openAbout), keyEquivalent: "")
        item.target = self
        item = menu.addItem(withTitle: "退出", action: #selector(StatusButton.quitApp), keyEquivalent: "q")
        item.target = self
        statusItem.menu = menu
    }
    
    
    
    static let shared = StatusButton()
}
