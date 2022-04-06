//
//  ViewController.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/5/22.
//

import Cocoa
import ScreenSaver

let posterWidth = 664.0
let posterHeight = 952.0

let Poster = false

let AppDates = [
    ["2022-04-01T05:00:00", "2022-04-01T09:00:00", "2022-04-01T17:00:00", "2022-04-01T21:00:00"],
    ["2022-07-01T05:30:00", "2022-07-01T10:00:00", "2022-07-01T17:30:00", "2022-07-01T22:00:00"],
    ["2022-10-01T06:00:00", "2022-10-01T11:00:00", "2022-10-01T18:00:00", "2022-10-01T23:00:00"],
    ["2022-02-01T06:30:00", "2022-02-01T12:00:00", "2022-02-01T18:30:00", "2022-02-01T00:00:00"],
]

let AppLocations = [
    ["Boston Harbor", "Canal Sueste", "East River", "Galveston Bay"],
    ["Hudson River", "Incheon", "Long Island", "Mumbai"],
    ["Narragansett Bay", "New Canal", "New Rochelle", "Passaic River"],
    ["Puget Sound", "Red Sea", "Rijeka", "Santa Barbara"],
]

class ViewController: NSViewController {

    private var savers: [ScreenSaverView] = []
    private var timer: Timer?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        if Poster {
            let rows = AppDates.count
            let columns = AppDates[0].count
            
            for row in (0...rows - 1) {
                for column in (0...columns - 1) {
                    addPosterScreensaver(row: row,
                                         column: column,
                                         width: posterWidth / Double(columns),
                                         height: posterHeight / Double(rows))
                }
            }
            
            view.setFrameSize(CGSize(width:posterWidth, height:posterHeight))
        } else {
            let margin = 30.0;
            view.setFrameSize(CGSize(width:NSScreen.main!.frame.width - margin * 2.0,
                                     height:NSScreen.main!.frame.height - margin * 2.0))
            addScreensaver()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30, repeats: true) { timer in
            for saver in self.savers {
                saver.animateOneFrame()
            }
       }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        if Poster {
            self.view.window?.title = "Tide Machine Poster"
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func addScreensaver() {
        if let saver = TideMachineView(frame: view.frame, isPreview: false) {
            view.addSubview(saver)
            self.savers.append(saver)
        }
    }
    
    private func addPosterScreensaver(row: Int, column: Int, width: Double, height: Double) {
        let y = AppDates.count - row - 1
        
        if let saver = TideMachineView(frame: NSRect(x: Double(column) * width,
                                                     y: Double(y) * height,
                                                     width: width,
                                                     height: height),
                                       isPreview: false,
                                       useRealData: false,
                                       date: AppDates[row][column],
                                       locationName: AppLocations[row][column]) {
            view.addSubview(saver)
            self.savers.append(saver)
        }
    }
}

