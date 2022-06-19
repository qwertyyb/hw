//
//  StatusButton.swift
//  hw
//
//  Created by 虚幻 on 2022/6/19.
//

import Foundation
import AppKit
import Sparkle

class StatusButton {
    private let statusItem: NSStatusItem

    @objc func quitApp() {
        NSApp.terminate(self)
    }
    @objc func toggle() {
        WindowHighlight.shared.toggleDisable();
        statusItem.menu?.item(at: 0)?.title = WindowHighlight.shared.disabled ? "启用" : "禁用"
    }

    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let image = NSImage(named: "StatusIcon")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.isVisible = true
        
        let menu = NSMenu()
        menu.minimumWidth = 120
        var item = menu.addItem(withTitle: "禁用", action: #selector(StatusButton.toggle), keyEquivalent: "")
        item.target = self
        item = menu.addItem(withTitle: "检查更新", action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)), keyEquivalent: "")
        item.target = (NSApp.delegate as! AppDelegate).updater
        item = menu.addItem(withTitle: "退出", action: #selector(StatusButton.quitApp), keyEquivalent: "q")
        item.target = self
        statusItem.menu = menu
    }
    
    static let shared = StatusButton()
}
