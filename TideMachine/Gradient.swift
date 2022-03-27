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
    
    init(gradients: [GradientData]) {
        self.gradients = gradients
    }
    
    func gradient() -> NSGradient? {
        var seconds = secondsPastMidnight(date: Date())
        var data = gradients.first(where: { $0.startSeconds <= seconds && $0.endSeconds > seconds })
        
        if (data == nil) {
            data = gradients.first(where: { $0.endSeconds < seconds })
            return NSGradient(colors: data!.endColors,
                              atLocations: data!.locations,
                              colorSpace: NSColorSpace.deviceRGB)
        }
        
        seconds = seconds - data!.startSeconds
        let transitionSeconds = data!.endSeconds - data!.startSeconds
        
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
                
                let delta = (startFloat - endFloat) * (CGFloat(seconds) / CGFloat(transitionSeconds))
                newColorComponents.append(startFloat - delta)
            }
            
            newColors.append(NSColor(red: newColorComponents[0],
                                     green: newColorComponents[1],
                                     blue: newColorComponents[2],
                                     alpha: newColorComponents[3]))
        }
        
//        print("red \(newColors[0].redComponent), green \(newColors[0].greenComponent) blue \(newColors[0].blueComponent)")
        return NSGradient(colors: newColors,
                          atLocations: data!.locations,
                          colorSpace: NSColorSpace.deviceRGB)
    }
    
    
 
    private func colorComponents(color: NSColor) -> [CGFloat] {
        return [color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent]
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

func secondsPastMidnight(date: Date) -> Int {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let components = Calendar.current.dateComponents([.second], from: startOfDay, to: date)
    return components.second!;
}

struct GradientData {
    let startSeconds: Int
    let endSeconds: Int
    let startColors: [NSColor]
    let endColors: [NSColor]
    let locations: [CGFloat]
}
