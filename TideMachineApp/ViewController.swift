//
//  ViewController.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/5/22.
//

import Cocoa
import ScreenSaver

class ViewController: NSViewController {

    private var saver: ScreenSaverView?
    private var timer: Timer?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let margin = 30.0;
        view.setFrameSize(CGSize(width:NSScreen.main!.frame.width - margin * 2.0,
                                 height:NSScreen.main!.frame.height - margin * 2.0))
        addScreensaver()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30, repeats: true) { timer in
            self.saver?.animateOneFrame()
       }
    }
    
    deinit {
        timer?.invalidate()
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

