//
//  Tide.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation
import AppKit

public struct TideData: Codable {
    var heights: [HeightData]
    var station: String
}

public struct HeightData: Codable {
    let date: Date
    let height: Double
}

struct Wobble {
    var progress: CGFloat
    var rising: Bool
}

let MinHeightRatio = 0.25
let MaxHeightRatio = 1.75
let TideWidthRatio = 1.25

let MaxWobble: CGFloat = 20.0
let WobbleSpeed: CGFloat = 0.5

class Tide {
    private var data: TideData!
    private var wobble: Wobble!
    private var gradient: Gradient!
    
    private var extremes: (min: Double, max: Double)
    private var heightPercent: Double = 1.0
    
    public var heights: [HeightData] = []
        
    init(data: TideData, customDate: CustomDate) {
        self.data = data
        wobble = Wobble(progress: 0.5, rising: true)
        gradient = TideGradient(customDate: customDate);
        
        if data.heights.count == 0 {
            extremes = (0.0, 0.0)
        } else {
            var heights = data.heights.map { $0.height }
            heights.sort()
            extremes = (heights[0], heights[heights.count-1])
        }
        
        heights = data.heights
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
        updateWobble()
    }
    
    func getHeightPercent(date: Date) -> Double {
        guard let closestHeights = closestHeights(date: date) else {
            return 1.0
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
        let currentHeight = closestHeights.prev.height + heightDelta * -1;

        return getProgress(
            current: currentHeight,
            window: (start: extremes.min, end: extremes.max),
            extremes: (min: extremes.min, max: extremes.max))
    }
    
    func getPercentage() -> Double {
        return round(heightPercent * 100 * 100) / 100.0
    }
    
    func updateWobble() {
        if (wobble.progress >= 1 || wobble.progress <= 0) {
            wobble.rising = !wobble.rising
        }
        
        let increment =  WobbleSpeed / (MaxWobble * 2) * (wobble.rising ? 1 : -1)
        wobble.progress += increment
    }
    
    public func draw(frame: NSRect) {
        let heightRatio = MinHeightRatio + (MaxHeightRatio - MinHeightRatio) * heightPercent;
        let wobbleCount = -MaxWobble + (MaxWobble * 2) * sineEaseInOut(x: wobble.progress)
        
        let tideWidth = frame.width * TideWidthRatio
        let tideHeight = frame.height * heightRatio
        let widthOffset = (frame.width - tideWidth) / 2.0
        let heightOffset = tideHeight * -1.0 + (tideHeight / 2.0)

        let tideRect = NSRect(x: widthOffset,
                              y: heightOffset + wobbleCount,
                              width: tideWidth,
                              height: tideHeight)

        let arc = NSBezierPath(ovalIn: tideRect)
        gradient.gradient.draw(in: arc, angle: 90)
    }
}
