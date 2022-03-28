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
