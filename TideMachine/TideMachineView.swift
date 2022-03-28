//
//  TideMachineView.swift
//  TideMachineView
//
//  Created by Colin Dunn on 3/18/22.
//

import AVFoundation
import CoreLocation
import MapKit
import Foundation
import ScreenSaver

var player: AVAudioPlayer!

public class TideMachineView: ScreenSaverView {

    private var persister: Persister! = nil
    private var textView: NSTextView! = nil
    private var debugOutput: [String] = []
    private var dateFormatter: DateFormatter! = nil
    
    private var tide: Tide!
    private var skyGraident: Gradient!
    
    private var isLoading: Bool = false
    private var customDate: CustomDate!

    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        debugOutput.append("\(locations)")
//         //This is where you can update the MapView when the computer is moved (locations.last!.coordinate)
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        debugOutput.append(error.localizedDescription)
//    }
//
//    func locationManager(_ manager: CLLocationManager,
//                       didChangeAuthorization status: CLAuthorizationStatus) {
//             print("location manager auth status changed to: " )
//             switch status {
//                 case .restricted:
//                    debugOutput.append("restricted")
//                 case .denied:
//                    debugOutput.append("denied")
//                 case .authorized:
//                    debugOutput.append("authorized")
//                 case .notDetermined:
//                    debugOutput.append("not yet determined")
//                 default:
//                    debugOutput.append("Unknown")
//         }
//    }
    
//    private var images: Dictionary<String, String>! = [:]
//    private var images: Dictionary<String, NSImage>! = [:]
    
    // MARK: - Initialization
    public override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
 
        customDate = CustomDate(date: dateFormatter.date(from: "2022-01-01T21:00:00"))
//        customDate = CustomDate(date: nil)

        skyGraident = BackgroundGradient(customDate: customDate)
        
        dateFormatter.dateFormat = "HH:mm:ss"
        persister = Persister()
        
//        let locationManager = CLLocationManager()
//        locationManager.requestWhenInUseAuthorization()
        
//        debugOutput.append("\(CLLocationManager.locationServicesEnabled())")
//
//        if CLLocationManager.locationServicesEnabled() {
//            debugOutput.append("DELEGATING")
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.requestLocation()
//            debugOutput.append("REQUESTED")
//        }

        let marginX = 15.0;
        let marginY = 20.0
        textView = NSTextView(frame: NSRect(x: marginX,
                                            y: marginY,
                                            width: frame.width - (marginX * 2),
                                            height: frame.height - (marginY * 2)))
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.font = NSFont.systemFont(ofSize: 10.5)
        self.addSubview(textView)

//        debugOutput.append(persister.data.tideData.station)

        tide = Tide(data: persister.data.tideData, customDate: customDate)
        
        if !isPreview {
            let heights = tide.heights;

            if heights.count == 0 || heights[heights.count - 1].date < Date() {
                isLoading = true
                fetchTides(date: customDate.date, completion: handleFetchTides)
            }

//            if let url = bundle.url(forResource: "birds", withExtension: "m4a") {
//                do {
//                    player = try AVAudioPlayer(contentsOf: url)
//                    player.volume = 1.0
//                    player.numberOfLoops = -1
//                    player.play()
//                } catch {}
//            }
        }
    }
    
    func handleFetchTides(data: PersistData?) {
        isLoading = false
       
        if data != nil {
            persister.write(data: data!)
            tide = Tide(data: data!.tideData, customDate: customDate)
        }
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawing
    private func drawBackground() {
        let background = NSBezierPath(rect: bounds)
        skyGraident.gradient.draw(in: background, angle: 90)
    }
    
    // MARK: - Lifecycle
    public override func draw(_ rect: NSRect) {
        drawBackground()
        
        textView.string = "\(dateFormatter.string(from: customDate.date))\n"
//            + "\(customDate.metadata.season)\n"
//            + "\(customDate.metadata.timeOfDay)\n"
//            + "\(customDate.metadata.lastDayOfSeason)\n"
//            + "\(customDate.metadata.nextSeason)\n"
//            + "\(customDate.metadata.nextTimeOfDay)\n"
        
//        dateFormmater
        
        for output in debugOutput {
            textView.string += output + "\n"
        }
        
        if (isLoading) { return }

        tide.draw(frame: rect)
        if !tide.isEmpty {
            let arrowText = tide.rising ? "↑" : "↓"
            textView.string += "\(tide.station)\n"
            textView.string += "\(arrowText) \(tide.currentHeightFeet)ft \(tide.percentage)%"
        }
    }
    
    public override func animateOneFrame() {
        super.animateOneFrame()
        
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
