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
            .background(Color.black.opacity(0.2))
            .clipped()
            .cornerRadius(0)
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
        self.setFrame(NSScreen.main!.frame, display: true)
        self.orderFront(nil)
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
