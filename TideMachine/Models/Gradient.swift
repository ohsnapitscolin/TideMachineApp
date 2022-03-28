//
//  Gradient.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import AppKit
import Foundation

class Gradient {
    private var gradients: [Season: [TimeOfDay:GradientData]] = [:]
    public var gradient: NSGradient! = nil
    
    init(colors: [TimeOfDay: [Season:[(Int, Int, Int)]]],
         locations: [CGFloat],
         customDate: CustomDate) {
        self.gradients = createGradients(colors: colors, locations: locations)
        self.gradient = getGradient(customDate: customDate)
    }
    
    func tick(customDate: CustomDate) {
        gradient = getGradient(customDate: customDate)
    }
    
    func getGradient(customDate: CustomDate) -> NSGradient {
        let metadata = customDate.metadata

        let ms = metadata.msPastMidnight

        let startGradient = gradients[metadata.season]![metadata.timeOfDay]!
        let endGradient = gradients[metadata.nextSeason]![metadata.nextTimeOfDay]!
        
        var newColors: [NSColor] = [];
        
        for (index, _) in startGradient.colors.enumerated() {
            let startColor = startGradient.colors[index]
            let endColor = endGradient.colors[index]
            
            let startComponents = colorComponents(color: startColor)
            let endComponents = colorComponents(color: endColor)
                      
            var newColorComponents: [CGFloat] = [];
            
            for (index, _) in startComponents.enumerated() {
                let startFloat = startComponents[index]
                let endFloat = endComponents[index]
                
               let progress = getProgress(current: ms,
                            window: (start: startGradient.startMilliseconds,
                                     end: endGradient.startMilliseconds),
                            extremes: (min: 0, max: 86400000))

                let delta = (startFloat - endFloat) * progress
                newColorComponents.append(startFloat - delta)
            }
            
            newColors.append(NSColor(red: newColorComponents[0],
                                     green: newColorComponents[1],
                                     blue: newColorComponents[2],
                                     alpha: newColorComponents[3]))
        }
        
//        if (ms == 0) {
//            print(newColors)
//        }
        
        return NSGradient(colors: newColors,
                          atLocations: startGradient.locations,
                          colorSpace: NSColorSpace.deviceRGB)!
    }
}



func rgbsToColors(rgbs: [(Int, Int, Int)]) -> [NSColor] {
    return rgbs.map({
        return NSColor(red: CGFloat($0.0) / 255,
                       green: CGFloat($0.1) / 255,
                       blue: CGFloat($0.2) / 255,
                       alpha: 1.0)
    })
}

func createGradients(colors: [TimeOfDay: [Season: [(Int, Int, Int)]]],
                     locations: [CGFloat]) -> [Season: [TimeOfDay:GradientData]]  {
    var gradients: [Season: [TimeOfDay:GradientData]] = [:]
    
    for season in Seasons {
        for timeOfDay in TimesOfDay {
            gradients[season] = gradients[season] ?? [:]
            gradients[season]![timeOfDay] = createGradient(colors: colors[timeOfDay]![season]!,
                                            locations: locations,
                                            season: SeasonRanges[season]!,
                                            time: TimeRanges[timeOfDay]!)
                           
        }
    }
                           
    return gradients;
}

func createGradient(colors: [(Int, Int, Int)],
                    locations: [CGFloat],
                    season: (start:String, end:String),
                    time: (start:String, end:String)) -> GradientData {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "MM-dd'T'HH"
    
    let startDate = dateFormatter.date(from: "\(season.start)T\(time.start)")!
    let endDate = dateFormatter.date(from: "\(season.end)T\(time.end)")!
    
    return GradientData(
            startMilliseconds: millisecondsPastMidnight(date: startDate),
            endMilliseconds: millisecondsPastMidnight(date: endDate),
            colors: rgbsToColors(rgbs: colors),
            locations: locations)
}


func colorComponents(color: NSColor) -> [CGFloat] {
    return [color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent]
}
  
struct GradientData {
    let startMilliseconds: Double
    let endMilliseconds: Double
    let colors: [NSColor]
    let locations: [CGFloat]
}
