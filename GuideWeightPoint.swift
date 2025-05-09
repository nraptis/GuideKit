//
//  GuideWeightPoint.swift
//  Jiggle3
//
//  Created by Nicholas Raptis on 5/9/25.
//

import Foundation
import MathKit

public class GuideWeightPoint: PointProtocol {
    public typealias Point = Math.Point
    public var x = Float(0.0)
    public var y = Float(0.0)
    public var controlIndex = 0
    public var point: Point {
        Point(x: x, y: y)
    }
}
