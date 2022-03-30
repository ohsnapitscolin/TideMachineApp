//
//  Config.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/29/22.
//

import Foundation

let TestDate: String? = nil
//let TestDate: String? = "2022-02-01T17:00:00"

let TestIntervalSeconds: Int = 1 * 60

let LocationName = "Conimicut Light, Narragansett Bay, Rhode Island"

let Location: (lat: Double, lon: Double) = Locations[LocationName]!

let Locations: [String: (lat: Double, lon: Double)] = [
    "Conimicut Light, Narragansett Bay, Rhode Island": (lat: 41.725040, lon: -71.324036),
    "Santa Barbara, California": (lat: 34.406827, lon: -119.878323),
    "Barra de Paranagua, Canal Sueste, Brazil": (lat: -25.4295963, lon: -49.2712724),
    "Rijeka, Croatia": (lat: 45.319518, lon: 14.470757),
    "Daeyeonpyeongdo, Incheon, South Korea": (lat: 37.434548, lon: 126.617700),
    "Bandra, Mumbai, India": (lat: 19.088038, lon: 72.828305),
    "Gig Harbor, Puget Sound, Washington": (lat: 47.326944, lon: -122.586389),
    "New Canal, Lake Pontchartrain, Louisiana": (lat: 29.9759983, lon: -90.0782127),
    "Chelsea St. Bridge, Boston Harbor, Massachusetts": (lat: 42.358930, lon: -71.003937),
    "Houston Ship Channel, Galveston Bay, Texas": (lat: 29.7589382, lon: -95.3676974),
    "Tarrytown, Hudson River, New York": (lat: 41.1328736, lon: -73.7926335),
    "New Rochelle, New York": (lat: 40.9115386, lon: -73.7826363),
    "Queensboro Bridge, East River, New York": (lat: 40.7587979, lon: -73.9623427),
    "Belleville, Passaic River, New Jersey": (lat: 40.7474966, lon: -74.2635376),
    "Sawakin, Red Sea, Sudan": (lat: 19.312146, lon: 37.254728),
]

let Reset = false
