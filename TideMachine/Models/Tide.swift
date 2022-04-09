//
//  Tide.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation
import AppKit

public struct TideData: Codable {
    var name: String
    var heights: [HeightData]
    var station: String
    var timezone: String
}

public struct HeightData: Codable {
    let date: Date
    let height: Double
}

class Tide {
    private var data: TideData!
    private var gradient: Gradient!

    public var wobble: Incrementor!
    private var fallback: Incrementor!
    
    private var fallbackPerfect: Double = 0.5
    private var heightPercent: Double = 0.5
    
    private var _rising: Bool =  true
    public var extremes: (min: Double, max: Double)
    public var currentHeight: Double = 0.0

    init(data: TideData, customDate: CustomDate) {
        self.data = data
        customDate.timezone = TimeZone(identifier: data.timezone) ?? TimeZone.current
        
        wobble = Incrementor(progress: 0.5,
                             extremes: (min: -20.0, max: 20.0),
                             increment: 0.5)
        
        let fallbackIncrement = 1.0 / 1000000
        let fallbackOffset = Double.random(in: 0.25..<0.75)
        let fallbackExtreme = Double.random(in: 0.5..<2.5)
        
        fallback = Incrementor(progress: fallbackOffset,
                               extremes: (min: fallbackExtreme * -1, max: fallbackExtreme),
                               increment: fallbackIncrement)
        
        gradient = TideGradient(customDate: customDate);
        
        if data.heights.count == 0 {
            extremes = (0.0, 0.0)
        } else {
            var heights = data.heights.map { $0.height }
            heights.sort()
            extremes = (heights[0], heights[heights.count-1])
        }
        

        heightPercent = getHeightPercent(date: customDate.date)
    }
    
    func closestHeights(date: Date) -> (prev: HeightData, next: HeightData)? {
        let index = heights.firstIndex(where: { $0.date > date })

        if (index == nil || index! <= 0) {
            return nil
        }
        
        return (heights[index!-1], heights[index!])
    }
    
    func tick(customDate: CustomDate) {
        heightPercent = getHeightPercent(date: customDate.date)
        gradient.tick(customDate: customDate)
        wobble.tick()
        fallback.tick()
    }
    
    func getHeightPercent(date: Date) -> Double {
        guard let closestHeights = closestHeights(date: date) else {
            return fallback.progress
        }

        let currentMs = date.timeIntervalSince1970 * 1000
        let prevMs = closestHeights.prev.date.timeIntervalSince1970 * 1000
        let nextMs = closestHeights.next.date.timeIntervalSince1970 * 1000
                
        let progress = getProgress(
            current: currentMs,
            window: (start: prevMs, end: nextMs),
            extremes: (min: prevMs, max: nextMs))
        
        let heightDiff = closestHeights.prev.height - closestHeights.next.height;
        let heightDelta = heightDiff * progress;
        
        _rising = heightDelta < 0
        currentHeight = closestHeights.prev.height + heightDelta * -1;

        return getProgress(
            current: currentHeight,
            window: (start: extremes.min, end: extremes.max),
            extremes: (min: extremes.min, max: extremes.max))
    }
   
     
    var name: String {
        get { data.name }
    }
    
    var heights: [HeightData] {
        get { data.heights }
    }
    
    var timezone: String {
        get { data.timezone }
    }
    
    var isEmpty: Bool {
        get { heights.count == 0 }
    }
    
    var rising: Bool {
        get {
            let rising = isEmpty ? fallback.rising : _rising
            return rising
        }
    }
    
    var currentHeightFeet: Double {
        get {
            let height = isEmpty ? fallback.value : currentHeight * 3.28084
            return round(height * 1000) / 1000.0
        }
    }
    
    var percentage: Double {
        get {
            let progress = isEmpty ? fallback.progress : heightPercent
            return round(progress * 100 * 100) / 100.0
        }
    }
    
    var station: String {
        get { data.station }
    }
    
    
    public func draw(frame: NSRect) {
        let heightRatio = clamp(percent: heightPercent,
                                extremes: (min: MinHeightRatio, max: MaxHeightRatio))
        
        let tideWidth = frame.width * TideWidthRatio
        let tideHeight = frame.height * heightRatio
        let widthOffset = (frame.width - tideWidth) / 2.0
        let heightOffset = tideHeight * -1.0 + (tideHeight / 2.0)

        let tideRect = NSRect(x: widthOffset,
                              y: heightOffset + wobble.value,
                              width: tideWidth,
                              height: tideHeight)

        let arc = NSBezierPath(ovalIn: tideRect)
        gradient.gradient.draw(in: arc, angle: 90)
    }
}
