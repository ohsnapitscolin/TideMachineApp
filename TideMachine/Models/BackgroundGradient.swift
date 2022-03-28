//
//  BackgroundGradient.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

class BackgroundGradient: Gradient {
    let Gradients = [
        TimeOfDay.Morning: [
            Season.Spring: [(251, 244, 162), (193, 199, 134)],
            Season.Summer: [(243, 243, 213), (197, 150, 131)],
            Season.Fall: [(243, 243, 213), (204, 134, 93)],
            Season.Winter: [(49, 134, 156), (197, 150, 131)]
        ],
        TimeOfDay.Day: [
            Season.Spring: [(249, 241, 160), (243, 243, 213)],
            Season.Summer: [(223, 198, 195), (243, 243, 213)],
            Season.Fall: [(214, 160, 138), (243, 243, 213)],
            Season.Winter: [(107, 190, 193), (243, 243, 213)]
        ],
        TimeOfDay.Evening: [
            Season.Spring: [(151, 155, 83), (179, 221, 198)],
            Season.Summer: [(215, 169, 150), (179, 221, 198)],
            Season.Fall: [(208, 144, 107), (179, 221, 198)],
            Season.Winter: [(95, 64, 134), (179, 221, 198)]
        ],
        TimeOfDay.Night: [
            Season.Spring: [(0, 0, 0), (141, 141, 139)],
            Season.Summer: [(0, 0, 0), (152, 128, 127)],
            Season.Fall: [(0, 0, 0), (147, 122, 108)],
            Season.Winter: [(0, 0, 0), (141, 141, 139)]
        ]
    ]

    let Locations: [CGFloat] = [0.5, 1.0]
    
    init(customDate: CustomDate) {
        super.init(colors: Gradients,
                   locations: Locations,
                   customDate: customDate)
    }
}
