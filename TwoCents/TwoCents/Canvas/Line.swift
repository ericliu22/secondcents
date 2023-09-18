//
//  Line.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/9/8.
//

import Foundation
import SwiftUI

struct Line {
    var points = [CGPoint]()
    var color: Color = .red
    var lineWidth: Double = 10.0
    
    func pointsArray() -> [NSNumber] {
        var output: [NSNumber] = []
        for i in self.points {
            output.append(NSNumber(value: i.x))
            output.append(NSNumber(value: i.y))
        }
        return output
    }
    
    init() {}
    
    init(pointsArray: [NSNumber]) {
        var cgpoints: [CGPoint] = []
        var copy: [NSNumber] = pointsArray
        
        while !copy.isEmpty {
            let y: Double = copy.popLast()!.doubleValue
            let x: Double = copy.popLast()!.doubleValue
            cgpoints.append(CGPoint(x: x, y: y))
        }
        
        self.points = cgpoints
    }
    
    func toFirebase() -> Dictionary<String, Any>{
        var output: Dictionary<String, Any> = [:]
        output["points"] = pointsArray()
        output["color"] = self.color.description
        output["lineWidth"] = NSNumber(value: self.lineWidth)
        return output
    }
}

