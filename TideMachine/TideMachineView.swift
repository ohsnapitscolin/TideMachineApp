//
//  TideMachineView.swift
//  TideMachineView
//
//  Created by Colin Dunn on 3/18/22.
//

import Foundation
import ScreenSaver

// var player: AVAudioPlayer!

public class TideMachineView: ScreenSaverView {
    private var persister: Persister? = nil

    private var textView: NSTextView! = nil
    
    private var tide: Tide!
    private var skyGraident: Gradient!
    
    private var isLoading: Bool = false
    private var customDate: CustomDate!
    
    private var startDate: Date! = nil
    private var frames: Double = 0.0
    private var uuid: Int = 0
    
    private var locationName: String = ""
   
    public override convenience init?(frame: NSRect, isPreview: Bool) {
        self.init(frame: frame,
                  isPreview: isPreview,
                  useRealData: UseRealData,
                  date: TestDate,
                  locationName: LocationName)
    }
        
    // MARK: - Initialization
    public init?(frame: NSRect, isPreview: Bool, useRealData: Bool, date: String?,locationName: String) {
        super.init(frame: frame, isPreview: isPreview)
        
        uuid = Int.random(in: 1..<100000)
        
        self.locationName = locationName;

        debugOutput.append("Running as a preview: \(isPreview)")  
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        let testDate = date != nil ? dateFormatter.date(from: date!) : nil
        customDate = CustomDate(date: testDate)
        
        startDate = Date()
                
        if useRealData {
            debugOutput.append("Reading saved data")
            persister = Persister(locationName: locationName)
        }

        let marginX = 15.0;
        let marginY = 20.0
        textView = NSTextView(frame: NSRect(x: marginX,
                                            y: marginY,
                                            width: frame.width - (marginX * 2),
                                            height: frame.height - (marginY * 2)))
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: 10.5)
        
        self.addSubview(textView)
        
        // Always reset the persisted data when using a test date.
        if (testDate != nil || ResetData) {
            debugOutput.append("Reseting saved data")
            persister?.reset()
        }

        var tideData = TideData(name: "", heights: [], station: "", timezone: "")
            
        if persister != nil {
            tideData = persister!.data.tideData
            debugOutput.append("Found \(tideData.heights.count) persisted heights")
        }
        
        tide = Tide(data: tideData, customDate: customDate)
        skyGraident = BackgroundGradient(customDate: customDate)
        
        if useRealData {
            let heights = tide.heights;
            let name = tide.name

            let shouldFetchData = name != locationName
                || heights.count == 0
                || heights[heights.count - 1].date < customDate.date
            let shouldRefereshData = !shouldFetchData
                && heights[heights.count - 1].date < customDate.date

            if shouldFetchData {
                isLoading = true
                debugOutput.append("Fetching tide data")
                fetchTides(date: testDate, completion: handleFetchTides)
            } else if shouldRefereshData {
                debugOutput.append("Refreshing tide data")
                // Refetch the tide data if the data will soon be stale.
                fetchTides(date: testDate, completion: handleFetchTides)
            }
        }
        
//        // Sound
//        if !isPreview {
//            if let url = bundle.url(forResource: "birds", withExtension: "m4a") {
//                do {
//                    player = try AVAudioPlayer(contentsOf: url)
//                    player.volume = 1.0
//                    player.numberOfLoops = -1
//                    player.play()
//                } catch {}
//            }
//        }
    }
    
    func handleFetchTides(data: PersistData?, error: String?) {
        isLoading = false
       
        if (error != nil) {
            debugOutput.append("Failed to fetch tide data: \(error!)")
        }
        
        if persister != nil && data != nil && data!.tideData.heights.count > 0 {
            persister!.write(data: data!)
            customDate.timezone = TimeZone(identifier: data!.tideData.timezone)!
            debugOutput.append("Successfully fetched \(data!.tideData.heights.count) heights")
            tide = Tide(data: data!.tideData, customDate: customDate)
        } else {
            debugOutput.append("No data found when fetching tides")
        }
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawing
    private func drawBackground(rect: NSRect) {
        if (isLoading) {
            let color: NSColor = .black
            color.setFill()
            rect.fill()
        } else {
            let background = NSBezierPath(rect: bounds)
            skyGraident.gradient.draw(in: background, angle: 90)
        }
    }
    
    var framesPerSecond: Double {
        get {
            let seconds = Date().timeIntervalSince(startDate)
            return frames / seconds
        }
    }
    
    // MARK: - Lifecycle
    public override func draw(_ rect: NSRect) {
        drawBackground(rect: rect)
        
        textView.string = "\(customDate.formattedDate)\n"
        textView.string += "\(locationName)\n"

        if ShowDebugOutput {
            // Season & Time of Day Testing
            textView.string += "\(customDate.metadata.season) \(customDate.metadata.timeOfDay)\n"
            
            for output in debugOutput {
                textView.string += output + "\n"
            }
            
            // Frame Rate Testing
            let roundedSeconds = round(Date().timeIntervalSince(startDate) * 100) / 100.0
            let roundedFramesPerSecond = round(framesPerSecond * 100) / 100.0
            textView.string += "\(roundedFramesPerSecond) \(frames) \(roundedSeconds)\n"
        }
        
        if (isLoading) { return }

        tide.draw(frame: rect)

        if ShowDebugOutput && tide.station != "" {
            textView.string += "\(tide.station)\n"
        }

        if !tide.isEmpty {
            let arrowText = tide.rising ? "↑" : "↓"
            textView.string += "\(arrowText) \(tide.currentHeightFeet)ft \(tide.percentage)%\n"
        }
    }
    
    public override func animateOneFrame() {
        super.animateOneFrame()
        
        frames += 1
        
        // Advance Time
        customDate.tick()
        tide.tick(customDate: customDate)
        skyGraident.tick(customDate: customDate)
        
        setNeedsDisplay(bounds)
    }
    
    public override func stopAnimation() {
        super.stopAnimation()
    }
}
