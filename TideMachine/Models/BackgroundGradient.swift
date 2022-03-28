//
//  BackgroundGradient.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

class BackgroundGradient: Gradient {
    let Morning = [
        [251, 244, 162],
        [193, 199, 134]
    ]

    let Day = [
        [249, 241, 160],
        [243, 243, 213]
    ]

    let Evening = [
        [151, 155, 83],
        [179, 221, 198]
    ]

    let Night = [
        [1, 29, 65],
        [141, 141, 139]
    ]

    let Locations: [CGFloat] = [0.5, 1.0]
    
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
