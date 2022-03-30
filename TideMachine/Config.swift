//
//  Config.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/29/22.
//

import Foundation

let TestDate: String? = nil

let TestIntervalSeconds: Int = 1 * 60

let LocationName = "Vienna"

let Location: (lat: Double, lon: Double) = Locations[LocationName]!

let Locations: [String: (lat: Double, lon: Double)] = [
    "Rhode Island": (lat: 41.725040, lon: -71.324036),
    "Goleta": (lat: 34.406827, lon: -119.878323),
    "Brazil": (lat: -25.4295963, lon: -49.2712724),
    "Vienna": (lat: 48.208176, lon: -16.373819)
]

let Reset = true
