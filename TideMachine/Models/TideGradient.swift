//
//  TideGradient.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

class TideGradient: Gradient {
    let Morning = [
        [1, 29, 65],
        [7, 141, 184],
        [249, 249, 203],
    ]

    let Day = [
        [1, 29, 65],
        [7, 141, 184],
        [249, 226, 226]
    ]

    let Evening = [
        [1, 29, 65],
        [1, 83, 115],
        [164, 196, 185]
    ]

    let Night = [
        [1, 29, 65],
        [1, 83, 115],
        [155, 155, 113]
    ]

    let Locations: [CGFloat] = [0.5, 0.65, 0.95]
    
    init() {
        let MorningColors = rgbsToColors(rgbs: Morning)
        let DayColors = rgbsToColors(rgbs: Day)
        let EveningColors = rgbsToColors(rgbs: Evening)
        let NightColors = rgbsToColors(rgbs: Night)

        let date = Date()
        
        let gradients = [
            GradientData(
                startMillseconds: millisecondsPastMidnight(date: date),
                endMilliseconds: millisecondsPastMidnight(date: date.addingTimeInterval(1 * 10)),
                startColors: MorningColors,
                endColors: DayColors,
                locations: Locations),
            GradientData(
                startMillseconds: millisecondsPastMidnight(date: date.addingTimeInterval(10)),
                endMilliseconds: millisecondsPastMidnight(date: date.addingTimeInterval(2 * 10)),
                startColors: DayColors,
                endColors: EveningColors,
                locations: Locations),
            GradientData(
                startMillseconds: millisecondsPastMidnight(date: date.addingTimeInterval(2 * 10)),
                endMilliseconds: millisecondsPastMidnight(date: date.addingTimeInterval(3 * 10)),
                startColors: EveningColors,
                endColors: NightColors,
                locations: Locations),
            GradientData(
                startMillseconds: millisecondsPastMidnight(date: date.addingTimeInterval(3 * 10)),
                endMilliseconds: millisecondsPastMidnight(date: date),
                startColors: NightColors,
                endColors: MorningColors,
                locations: Locations)
        ]
        
        super.init(gradients: gradients)
    }
}
