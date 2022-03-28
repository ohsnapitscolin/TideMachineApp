//
//  TideGradient.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

class TideGradient: Gradient {
    let Gradients = [
        TimeOfDay.Morning: [
            Season.Spring: [(1, 29, 65), (7, 141, 184), (249, 249, 203)],
            Season.Summer: [(1, 29, 65), (7, 141, 184), (249, 249, 203)],
            Season.Fall: [(1, 29, 65), (7, 141, 184), (249, 249, 203)],
            Season.Winter:  [(1, 29, 65), (7, 141, 184), (249, 249, 203)],
        ],
        TimeOfDay.Day: [
            Season.Spring: [(1, 29, 65), (243, 243, 213), (249, 226, 226)],
            Season.Summer: [(1, 29, 65), (7, 141, 184), (204, 251, 229)],
            Season.Fall: [(1, 29, 65), (7, 141, 184), (247, 242, 179)],
            Season.Winter: [(1, 29, 65), (7, 141, 184), (255, 255, 255)]
        ],
        TimeOfDay.Evening: [
            Season.Spring: [(1, 29, 65), (1, 83, 115), (164, 196, 185)],
            Season.Summer: [(1, 29, 65), (1, 83, 115), (164, 196, 185)],
            Season.Fall: [(1, 29, 65), (1, 83, 115), (164, 196, 185)],
            Season.Winter: [(1, 29, 65), (1, 83, 115), (164, 196, 185)]
        ],
        TimeOfDay.Night: [
            Season.Spring: [(1, 29, 65), (1, 83, 115), (155, 155, 113)],
            Season.Summer: [(1, 29, 65), (1, 83, 115), (200, 166, 155)],
            Season.Fall: [(1, 29, 65), (1, 83, 115), (134, 96, 88)],
            Season.Winter: [(1, 29, 65), (1, 83, 115), (149, 130, 174)]
        ]
    ]

    let Locations: [CGFloat] = [0.5, 0.65, 0.95]
    
    init(customDate: CustomDate) {        
        super.init(colors: Gradients,
                   locations: Locations,
                   customDate: customDate)
    }
}
