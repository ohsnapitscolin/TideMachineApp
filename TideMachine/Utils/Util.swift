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

func sineEaseInOut(x: CGFloat) -> CGFloat {
    return 1 / 2 * ((1 - cos(x * .pi)))
}
