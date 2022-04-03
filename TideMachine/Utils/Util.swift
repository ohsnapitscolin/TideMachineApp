//
//  Util.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/28/22.
//

import Foundation

func getProgress(current: Double,
                 window: (start: Double, end: Double),
                 extremes: (min: Double, max: Double)) -> Double {
    let start = window.start
    let end = window.end
    
    var diff = current - start;
        
    if end < start && current < end {
        diff = (extremes.max - start) + (extremes.min + current)
    }
        
    let distance = end < start ? (extremes.max - start) + (end - extremes.min) : end - start
    return diff / distance
}

func clamp(percent: Double, extremes: (min: Double, max: Double)) -> Double {
    return extremes.min + (extremes.max - extremes.min) * percent
}

func sineEaseInOut(x: CGFloat) -> CGFloat {
    return 1 / 2 * ((1 - cos(x * .pi)))
}

class Incrementor {
    public var progress: Double
    public var rising: Bool = true
    public var extremes: (min: Double, max: Double)
    public var increment: Double
    public var uuid: Int
    
    init(progress: Double, extremes: (min: Double, max: Double), increment: Double) {
        self.uuid = Int.random(in: 1..<100000)
        self.progress = progress
        self.extremes = extremes
        self.increment = increment
    }
    
    func tick() {
        if (progress >= extremes.max || progress <= extremes.min) {
            rising = !rising
        }
        
        let delta =  increment / (extremes.max - extremes.min) * (rising ? 1 : -1)
        progress += delta
    }
    
    var value: Double {
        get { return clamp(percent: sineEaseInOut(x: progress), extremes: extremes) }
    }
}
