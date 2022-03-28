//
//  Gradient.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import AppKit
import Foundation

class Gradient {
    private var gradients: [GradientData] = []
    public var gradient: NSGradient! = nil
    
    init(gradients: [GradientData], date: Date) {
        self.gradients = gradients
        self.gradient = getGradient(date: date)
    }
    
    func tick(date: Date) {
        gradient = getGradient(date: date)
    }
    
    func getGradient(date: Date) -> NSGradient {
        var milliseconds = millisecondsPastMidnight(date: date)
        var data = gradients.first(where: {
            $0.startMillseconds <= milliseconds && $0.endMilliseconds > milliseconds
        })
        
        if (data == nil) {
            data = gradients.first(where: { $0.endMilliseconds < milliseconds })
            return NSGradient(colors: data!.endColors,
                              atLocations: data!.locations,
                              colorSpace: NSColorSpace.deviceRGB)!
        }
        
        milliseconds = milliseconds - data!.startMillseconds
        let transitionMilliseconds = data!.endMilliseconds - data!.startMillseconds
        
        var newColors: [NSColor] = [];
        
        for (index, _) in data!.startColors.enumerated() {
            let startColor = data!.startColors[index]
            let endColor = data!.endColors[index]
            
            let startComponents = colorComponents(color: startColor)
            let endComponents = colorComponents(color: endColor)
                      
            
            var newColorComponents: [CGFloat] = [];
            
            for (index, _) in startComponents.enumerated() {
                let startFloat = startComponents[index]
                let endFloat = endComponents[index]
                
                let delta = (startFloat - endFloat) * (CGFloat(milliseconds) / CGFloat(transitionMilliseconds))
                newColorComponents.append(startFloat - delta)
            }
            
            newColors.append(NSColor(red: newColorComponents[0],
                                     green: newColorComponents[1],
                                     blue: newColorComponents[2],
                                     alpha: newColorComponents[3]))
        }
        
        return NSGradient(colors: newColors,
                          atLocations: data!.locations,
                          colorSpace: NSColorSpace.deviceRGB)!
    }
}

func rgbsToColors(rgbs: [[Int]]) -> [NSColor] {
    return rgbs.map({
        return NSColor(red: CGFloat($0[0]) / 255,
                       green: CGFloat($0[1]) / 255,
                       blue: CGFloat($0[2]) / 255,
                       alpha: 1.0)
    })
}

func millisecondsPastMidnight(date: Date) -> Double {
    let startOfDay = Calendar.current.startOfDay(for: date)
    return (date.timeIntervalSince1970 - startOfDay.timeIntervalSince1970) * 1000
}

func colorComponents(color: NSColor) -> [CGFloat] {
    return [color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent]
}

struct GradientData {
    let startMillseconds: Double
    let endMilliseconds: Double
    let startColors: [NSColor]
    let endColors: [NSColor]
    let locations: [CGFloat]
}
