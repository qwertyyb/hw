//
//  MaskController.swift
//  hw
//
//  Created by 虚幻 on 2022/6/18.
//

import Cocoa
import SwiftUI

class MaskWindow: NSWindow {
    struct MaskView: View {
        var body: some View {
            VStack {
            }
            .frame(width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height, alignment: .center)
            .background(Color.black)
            .clipped()
            .cornerRadius(0)
            .transition(.opacity)
        }
    }

    struct ToastView_Previews: PreviewProvider {
        static var previews: some View {
            MaskView()
        }
    }

    private let hostingView = NSHostingView(rootView: MaskView())

    override var acceptsFirstResponder: Bool {
       return false
    }

    private func initWindow() {
        isOpaque = false
        backgroundColor = NSColor.clear
        styleMask = .init(arrayLiteral: .borderless, .fullSizeContentView)
        hasShadow = false
        ignoresMouseEvents = true
        isReleasedWhenClosed = false
        level = NSWindow.Level.normal
        // 不显示在mission control中
        collectionBehavior = .transient
        isExcludedFromWindowsMenu = true
        // alt-tab 使用subrole来过滤窗口，此处需要设置subrole为nil
        self.setAccessibilitySubrole(nil)
        self.setFrame(NSScreen.main!.frame, display: true)
        self.orderFront(nil)
        self.alphaValue = 0
        self.animationBehavior = .none
    }
    
    func fadeIn(_ frontMostWinNo: Int) {
        NSLog("fadeIn")
        self.order(.below, relativeTo: frontMostWinNo)
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            context.timingFunction = .init(name: .linear)
            self.animator().alphaValue = 0.3
            }, completionHandler: nil)
    }
    
    func fadeOut() {
        NSLog("fadeOut")
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            context.timingFunction = .init(name: .linear)
            self.animator().alphaValue = 0
        }, completionHandler: nil)
    }
    
    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        contentView = hostingView
        initWindow()
    }
}
