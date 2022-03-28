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
    var count: CGFloat
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
        
    init(data: TideData, date: Date) {
        self.data = data
        wobble = Wobble(count: 0, rising: true)
        gradient = TideGradient(date: date);
        
        if data.heights.count == 0 {
            extremes = (0.0, 0.0)
        } else {
            var heights = data.heights.map { $0.height }
            heights.sort()
            extremes = (heights[0], heights[heights.count-1])
        }
        
        heights = data.heights
        heightPercent = getHeightPercent(date: date)
    }
    
    func closestHeights(date: Date) -> (prev: HeightData, next: HeightData)? {
        let index = heights.firstIndex(where: { $0.date > date })

        if (index == nil || index! <= 0) {
            return nil
        }
        
        return (heights[index!-1], heights[index!])
    }
    
    func tick(date: Date) {
        heightPercent = getHeightPercent(date: date)
        gradient.tick(date: date)
        updateWobble()
    }
    
    func getHeightPercent(date: Date) -> Double {
        guard let closestHeights = closestHeights(date: date) else {
            return 1.0
        }

        let timeComponents = Calendar.current.dateComponents([.second],
                                                             from: date,
                                                             to: closestHeights.next.date)

        let dateDiffSecs = 30.0 * 60.0;
        let currentDiffSecs = timeComponents.second;
        
        let heightDiff = closestHeights.prev.height - closestHeights.next.height;
        let heightDelta = heightDiff / dateDiffSecs;
        
        let secondsPastPrevious = dateDiffSecs - Double(currentDiffSecs!);
        
        let currentHeight = closestHeights.prev.height + heightDelta * secondsPastPrevious * -1;

        let offset = abs(min(extremes.min, 0))
        let range = extremes.max - extremes.min
    
        return (currentHeight + offset) / range
    }
    
    func getPercentage() -> Double {
        return round(heightPercent * 100 * 100) / 100.0
    }
    
    func updateWobble() {
        if (abs(wobble.count) >= MaxWobble) {
            wobble.rising = !wobble.rising
        }
        wobble.count += WobbleSpeed * (wobble.rising ? 1 : -1)
    }
    
    public func draw(frame: NSRect) {
        var heightRatio = MinHeightRatio + (MaxHeightRatio - MinHeightRatio) * heightPercent;

        let tideWidth = frame.width * TideWidthRatio
        let tideHeight = frame.height * heightRatio
        let widthOffset = (frame.width - tideWidth) / 2.0
        heightRatio = tideHeight * -1.0 + (tideHeight / 2.0)

        let tideRect = NSRect(x: widthOffset,
                          y: heightRatio + wobble.count,
                          width: tideWidth,
                          height: tideHeight)

        let arc = NSBezierPath(ovalIn: tideRect)
        gradient.gradient.draw(in: arc, angle: 90)
    }
}
