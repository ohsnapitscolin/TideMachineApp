//
//  ViewController.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Cocoa
import ScreenSaver

class ViewController: NSViewController {

    private var saver: ScreenSaverView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addScreensaver()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func addScreensaver() {
        if let saver = TideMachineView(frame: view.frame, isPreview: false) {
            view.addSubview(saver)
            self.saver = saver
        }
    }
}

