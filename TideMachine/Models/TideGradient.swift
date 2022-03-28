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
    
    init(date: Date) {
        let MorningColors = rgbsToColors(rgbs: Morning)
        let DayColors = rgbsToColors(rgbs: Day)
        let EveningColors = rgbsToColors(rgbs: Evening)
        let NightColors = rgbsToColors(rgbs: Night)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd'T'HH:mm:ss"
        
        let gradients = [
            GradientData(
                startMillseconds: millisecondsPastMidnight(
                    date: dateFormatter.date(from: "01-01T06:00:00")!),
                endMilliseconds: millisecondsPastMidnight(
                    date: dateFormatter.date(from: "01-01T11:59:59")!),
                startColors: MorningColors,
                endColors: DayColors,
                locations: Locations),
            GradientData(
                startMillseconds: millisecondsPastMidnight(
                    date: dateFormatter.date(from: "01-01T12:00:00")!),
                endMilliseconds: millisecondsPastMidnight(
                    date: dateFormatter.date(from: "01-01T17:59:59")!),
                startColors: DayColors,
                endColors: EveningColors,
                locations: Locations),
            GradientData(
                startMillseconds: millisecondsPastMidnight(
                    date: dateFormatter.date(from: "01-01T18:00:00")!),
                endMilliseconds: millisecondsPastMidnight(
                    date: dateFormatter.date(from: "01-01T23:59:59")!),
                startColors: EveningColors,
                endColors: NightColors,
                locations: Locations),
            GradientData(
                startMillseconds: millisecondsPastMidnight(
                    date: dateFormatter.date(from: "01-01T00:00:00")!),
                endMilliseconds: millisecondsPastMidnight(
                    date: dateFormatter.date(from: "01-01T05:59:59")!),
                startColors: NightColors,
                endColors: MorningColors,
                locations: Locations)
        ]
        
        super.init(gradients: gradients, date: date)
    }
}
