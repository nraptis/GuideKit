//
//  GuideWeightSegment.swift
//  Guide3
//
//  Created by Nicholas Raptis on 5/9/25.
//

import Foundation
import MathKit
import TypeKit

public class GuideWeightSegment: PrecomputedLineSegment {
    
    public var isIllegal = false
    public var isBucketed = false
    public var isVisited = false
    
    public var x1: Float = 0.0
    public var y1: Float = 0.0
    public var x2: Float = 0.0
    public var y2: Float = 0.0
    
    public var controlIndex1 = 0
    public var controlIndex2 = 0
    
    public var centerX: Float = 0.0
    public var centerY: Float = 0.0
    
    public var directionX = Float(0.0)
    public var directionY = Float(-1.0)
    
    public var normalX = Float(1.0)
    public var normalY = Float(0.0)
    
    public var lengthSquared = Float(1.0)
    public var length = Float(1.0)
    
    public var directionAngle = Float(0.0)
    public var normalAngle = Float(0.0)
    
    public static func neighborControlPointCheck(pointControlPointIndex: Int,
                                                 polygonControlPointCount: Int,
                                                 segmentControlPointIndex1: Int,
                                                 segmentControlPointIndex2: Int) -> NeighborControlPointsResult {
        
        // If we are 0, with 8 points:
        // [7 | 0] and [7 | 7] are directly left
        // [0 | 0] and [0 | 1] are directly right
        
        let pointControlPointIndex_MinusOne: Int
        if pointControlPointIndex == 0 {
            pointControlPointIndex_MinusOne = polygonControlPointCount - 1
        } else {
            pointControlPointIndex_MinusOne = pointControlPointIndex - 1
        }
        if segmentControlPointIndex1 == pointControlPointIndex_MinusOne {
            return NeighborControlPointsResult.neighborToTheLeft
        }
        
        if segmentControlPointIndex1 == pointControlPointIndex {
            return NeighborControlPointsResult.neighborToTheRight
        }
        
        return NeighborControlPointsResult.notDirectNeighbor
    }
    
}
