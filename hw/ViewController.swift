//
//  ViewController.swift
//  hw
//
//  Created by 虚幻 on 2022/6/16.
//

import Cocoa
import Carbon

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let selfNumber = self.view.window?.windowNumber
        print("selfNumber: \(selfNumber)")
        
        let nums = NSWindow.windowNumbers(options: .allApplications)
        print(nums)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func getFrontMostApp () -> AXUIElement? {
        if let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier {
            let app = AXUIElementCreateApplication(pid)
            var focusedWin: CFTypeRef?
            AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute as CFString, &focusedWin)
        }
        return nil
    }

    override func viewDidAppear() {
    }

}

