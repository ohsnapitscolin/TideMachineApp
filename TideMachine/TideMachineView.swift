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

let BundleIdentifier = "lian.land.TideMachine"

let MaxWobble: CGFloat = 20.0
let WobbleSpeed: CGFloat = 0.5

let MinHeightRatio = 0.25
let MaxHeightRatio = 1.75

let TideColor1: NSColor = NSColor(red:1/255, green:29/255, blue:65/255, alpha:1)
let TideColor2: NSColor = NSColor(red:7/255, green:141/255, blue:184/255, alpha:1)
let TideColor3: NSColor = NSColor(red:241/255, green:241/255, blue:178/255, alpha:1)

let TideWidthRatio = 1.25
let UseTestData = false

let Locations: [Location] = [
    Location(name: "Rhode Island", coordinates: CGPoint(x: 41.725040, y: -71.324036)),
    Location(name: "California", coordinates: CGPoint(x: 34.407043, y: -119.878510))
]

// MARK: - Data
struct TideData: Codable {
    var heights: [HeightData]
    var station: String
}

struct HeightData: Codable {
    let date: Date
    let height: Double
}

struct Wobble {
    var count: CGFloat
    var rising: Bool
}

struct Location {
    let name: String
    let coordinates: CGPoint
}

public class TideMachineView: ScreenSaverView {
    private var saveFileURL: URL! = nil
    private var saveData: SaveData! = nil
    private var bundle: Bundle! = nil
    
    private var textView: NSTextView! = nil
    private var debugOutput: [String] = []
    private var dateFormatter: DateFormatter! = nil
    
    private var wobble: Wobble!;
    
    private var skyGraident: Gradient!;
    
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

        skyGraident = BackgroundGradient();
//
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
            
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm:ss"

        wobble = Wobble(count: 0, rising: true)

        textView = NSTextView(frame: frame)
        textView.textColor = .white
        textView.backgroundColor = .clear
        self.addSubview(textView)
//
        bundle = Bundle.init(identifier: BundleIdentifier) ?? Bundle.main
        saveFileURL = getDocumentsDirectory().appendingPathComponent("lian.land.TideMachine_v1.txt")

        if (!FileManager.default.fileExists(atPath: saveFileURL.path)) {
            resetSaveData()
        }

        saveData = readSaveData()
        debugOutput.append(saveData.tideData.station)

        let heights = saveData.tideData.heights;

        if (heights.count == 0) {
            if (!isPreview) { fetchTides() }
        } else if (heights[heights.count - 1].date < Date()) {
            saveData.tideData.heights = [];
            if (!isPreview) { fetchTides() }
        }

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
    
    // MARK: - Data Management
    private func fetchTides() {
        let host = "https://www.worldtides.info/api/v3?heights"
        let date = "today"
        let days = "7"
        let lat = "41.725040"
        let lon = "-71.324036"
        let key = "02b04d61-c363-4a63-98af-99f544a0521b"
        
        let url = URL(string: "\(host)&date=\(date)&days=\(days)&lat=\(lat)&lon=\(lon)&key=\(key)")!
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data, error == nil else { return }

            do{
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                self.persistTideData(json: json)
            } catch {
                self.debugOutput.append(error.localizedDescription)
            }
        }.resume()
    }
    
    private func persistTideData(json: [String: Any]?) {
        do {
            debugOutput.append("Persisting Tide Data");
            
            var updatedSaveData = try saveData.copy()
            
            let heights = json?["heights"] as? [[String: Any]] ?? []
            let station = json?["station"] as! String

            let heightData = heights.map({ (height: [String:Any]) -> HeightData in
                let dt = height["dt"] as! Int
                let height = height["height"] as! Double
                let date = Date(timeIntervalSince1970: Double(dt))
                return HeightData(date: date, height: height)
            })

            updatedSaveData.tideData.heights = heightData
            updatedSaveData.tideData.station = station;
            
            saveData = updatedSaveData
            writeSaveData(saveData: updatedSaveData)
        } catch {
            debugOutput.append("Unable to persist tide data")
        }
    }
    
    // MARK: - File Management
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func readSaveData() -> SaveData? {
        do {
            let stringData = try String(contentsOf: saveFileURL, encoding: .utf8)
            let data = stringData.data(using: .utf8)!
            return try JSONDecoder().decode(SaveData.self, from: data)
        } catch {
            debugOutput.append("Unable to read from save file!")
            return nil
        }
    }
    
    private func writeSaveData(saveData: SaveData) {
        do {
            let data = try JSONEncoder().encode(saveData)
            let stringData = String(data: data, encoding: .utf8)!
            try stringData.write(to: saveFileURL, atomically: true, encoding: .utf8)
        } catch {
            debugOutput.append("Unable to write to save file!")
        }
    }

    private func resetSaveData() {
        let tideData = TideData(heights: [], station: "")
        let saveData = SaveData(tideData: tideData)
        writeSaveData(saveData: saveData)
    }
    
//    private func updateSaveData() {
//        do {
//            var updatedSaveData = try saveData.copy()
//            updatedSaveData.lastTended = Date()
//
//            let aliveFlowers = updatedSaveData.flowers.filter { $0.alive }
//            updatedSaveData.flowers = aliveFlowers
//
//            writeSaveData(saveData: updatedSaveData)
//        } catch {}
//    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawing
    private func drawBackground() {
        let background = NSBezierPath(rect: bounds)
        skyGraident.gradient()!.draw(in: background, angle: 90)
    }
    
    func wobbleTide() {
        if (abs(wobble.count) >= MaxWobble) {
            wobble.rising = !wobble.rising
        }

        wobble.count += WobbleSpeed * (wobble.rising ? 1 : -1)
    }


    // MARK: - Lifecycle
    public override func draw(_ rect: NSRect) {
        drawBackground()
        
        textView.string = "\(dateFormatter.string(from: Date()))\n"
        
        for output in debugOutput {
            textView.string += output + "\n"
        }

        if (saveData.tideData.heights.count == 0) {
            return
        }

        wobbleTide()

        let heightRatio = heightOffset()

        let tideWidth = frame.width * TideWidthRatio
        let tideHeight = frame.height * heightRatio
        let widthOffset = (frame.width - tideWidth) / 2.0
        let heightOffset = tideHeight * -1.0 + (tideHeight / 2.0)

        let tideRect = NSRect(x: widthOffset,
                          y: heightOffset + wobble.count,
                          width: tideWidth,
                          height: tideHeight)

        let TideGradient: NSGradient! = NSGradient(colorsAndLocations: (TideColor1, 0.5),
                                                   (TideColor2, 0.65),
                                                   (TideColor3, 0.95))

        let arc = NSBezierPath(ovalIn: tideRect)

        TideGradient.draw(in: arc, angle: 90)

        let percentage = (heightRatio - MinHeightRatio) / (MaxHeightRatio-MinHeightRatio);
        textView.string += "\(round(percentage * 100 * 100) / 100.0)%"
    }
    
    public override func animateOneFrame() {
        super.animateOneFrame()
        setNeedsDisplay(bounds)
    }
    
    public override func stopAnimation() {
        super.stopAnimation()
    }
    
    // MARK: - Helper Functions
    func heightExtremes() -> Array<Double> {
        var heights = saveData.tideData.heights.map { $0.height }
        heights.sort()
        return [heights[0], heights[heights.count-1]]
    }
    
    func closestHeights() -> Array<HeightData> {
        let now = Date()
        let index = saveData.tideData.heights.firstIndex(where: { $0.date > now })

        if (index == nil || index == 0) {
            return []
        }
        return [saveData.tideData.heights[index!-1], saveData.tideData.heights[index!]]
    }
    
    func heightOffset() -> Double {
        if (saveData == nil) {
            return 1.0;
        }

        let closestHeights = closestHeights()
        let heightExtremes = heightExtremes()
        let heightRange = CGPoint(x: heightExtremes[0], y: heightExtremes[1]);

        let now = Date()
        let timeComponents = Calendar.current.dateComponents([.second], from: now, to: closestHeights[1].date)
        
        let dateDiffSecs = 30.0 * 60.0;
        let currentDiffSecs = timeComponents.second;
        
        let heightDiff = closestHeights[0].height - closestHeights[1].height;
        let heightDelta = heightDiff / dateDiffSecs;
        
        let secondsPastPrevious = dateDiffSecs - Double(currentDiffSecs!);
        
        let currentHeight = closestHeights[0].height + heightDelta * secondsPastPrevious * -1;

        let offset = abs(min(heightRange.x, 0))
        let range = heightRange.y - heightRange.x
        let percentPastLow = (currentHeight + offset) / range
        return MinHeightRatio + (MaxHeightRatio - MinHeightRatio) * percentPastLow;
    }
    
    // MARK: - Save Data
    struct SaveData: Codable {
        var tideData: TideData
        
        func copy() throws -> SaveData {
            let data = try JSONEncoder().encode(self)
            let copy = try JSONDecoder().decode(SaveData.self, from: data)
            return copy
        }
    }
}
