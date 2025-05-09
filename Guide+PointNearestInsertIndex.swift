//
//  Guide+PointNearestInsertIndex.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 5/16/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit

public extension Guide {
    
    func calculateNearestInsertIndex(_ x: Float, _ y: Float) -> Int? {
        
        purgeTempPrecomputedLineSegments()
        var area = Float(0.0)
        for index1 in 0..<guideControlPointCount {
            var index2 = index1 + 1
            if index2 == guideControlPointCount {
                index2 = 0
            }
            let jiggleControlPoint1 = guideControlPoints[index1]
            let jiggleControlPoint2 = guideControlPoints[index2]
            let point1 = jiggleControlPoint1.point
            let point2 = jiggleControlPoint2.point
            area += Math.cross(x1: point1.x, y1: point1.y,
                               x2: point2.x, y2: point2.y)
            addTempPrecomputedLineSegment(x1: point1.x,
                                          y1: point1.y,
                                          x2: point2.x,
                                          y2: point2.y)
        }
        let isClockwise = (area > 0.0)
        purgeTempIntegers()
        var bestDistanceSquared = Float(100_000_000.0)
        for tempPrecomputedLineSegmentIndex in 0..<tempPrecomputedLineSegmentCount {
            let precomputedLineSegment = tempPrecomputedLineSegments[tempPrecomputedLineSegmentIndex]
            let distanceSquared = precomputedLineSegment.distanceSquaredToClosestPoint(x, y)
            if distanceSquared < bestDistanceSquared {
                bestDistanceSquared = distanceSquared
                
                purgeTempIntegers()
                addTempInteger(tempPrecomputedLineSegmentIndex)
                
            } else if distanceSquared == bestDistanceSquared {
                addTempInteger(tempPrecomputedLineSegmentIndex)
            }
        }
        
        if tempIntegerCount > 3 {
            // This should very rarely happen...
            // There is no mathematically 'right' answer here...
            return tempIntegers[0] + 1
        } else if tempIntegerCount == 2 {
            
            // This is a common case, where are are at an elbow...
            // We use voodoo level 99 to determine how the
            // point should be positioned based on the elbow...
            
            let lineSegmentLeft = tempPrecomputedLineSegments[tempIntegers[0]]
            let lineSegmentRight = tempPrecomputedLineSegments[tempIntegers[1]]
            
            if lineSegmentLeft.isIllegal {
                if lineSegmentRight.isIllegal {
                    return tempIntegers[0]
                } else {
                    return tempIntegers[1]
                }
            } else if lineSegmentRight.isIllegal {
                return tempIntegers[0]
            } else {
                var normalX = lineSegmentLeft.normalX + lineSegmentRight.normalX
                var normalY = lineSegmentLeft.normalY + lineSegmentRight.normalY
                if isClockwise == true {
                    normalX = -normalX
                    normalY = -normalY
                }
                
                var normalLengthSquared = normalX * normalX + normalY * normalY
                if normalLengthSquared < Math.epsilon {
                    
                    // In this case, we have probably a 180 degree angle,
                    // so, we will need to make a small adjustment to both angles...
                    
                    let angle1 = lineSegmentLeft.normalAngle + Math.pi_8
                    let angle2 = lineSegmentRight.normalAngle - Math.pi_8
                    let diffX = sinf(angle1) + sinf(angle2)
                    let diffY = -(cosf(angle1) + cosf(angle2))
                    normalLengthSquared = diffX * diffX + diffY * diffY
                    if normalLengthSquared > Math.epsilon {
                        let normalLength = sqrtf(normalLengthSquared)
                        normalX = diffX / normalLength
                        normalY = diffY / normalLength
                        if isClockwise == true {
                            normalX = -normalX
                            normalY = -normalY
                        }
                    } else {
                        return tempIntegers[0]
                    }
                } else {
                    let normalLength = sqrtf(normalLengthSquared)
                    normalX /= normalLength
                    normalY /= normalLength
                }
                
                let normalAngle = -atan2f(normalX, normalY)
                
                let kinkX: Float
                let kinkY: Float
                let isEnd: Bool
                if isClockwise {
                    if tempIntegers[0] == 0 && (tempIntegers[1] == guideControlPointCount - 1) {
                        kinkX = lineSegmentRight.x2
                        kinkY = lineSegmentRight.y2
                        isEnd = true
                    } else {
                        kinkX = lineSegmentRight.x1
                        kinkY = lineSegmentRight.y1
                        isEnd = false
                    }
                } else {
                    if tempIntegers[0] == 0 && (tempIntegers[1] == guideControlPointCount - 1) {
                        kinkX = lineSegmentLeft.x1
                        kinkY = lineSegmentLeft.y1
                        isEnd = true
                    } else {
                        kinkX = lineSegmentLeft.x2
                        kinkY = lineSegmentLeft.y2
                        isEnd = false
                    }
                }
                
                let divineX = (x - kinkX)
                let divineY = (y - kinkY)
                
                let divineLengthAquared = divineX * divineX + divineY * divineY
                if divineLengthAquared <= Math.epsilon {
                    return nil
                }
                
                let divineAngle = -atan2f(divineX, divineY)
                let angleDiff = Math.distanceBetweenAngles(divineAngle, normalAngle)
                if angleDiff > 0.0 {
                    if isClockwise {
                        if isEnd {
                            var result = tempIntegers[0]
                            if result > guideControlPointCount {
                                result = 0
                            }
                            return result
                        } else {
                            var result = tempIntegers[0] + 1
                            if result > guideControlPointCount {
                                result = 0
                            }
                            return result
                        }
                    } else {
                        if isEnd {
                            var result = tempIntegers[0] + 1
                            if result > guideControlPointCount {
                                result = 0
                            }
                            return result
                        } else {
                            var result = tempIntegers[1] + 1
                            if result > guideControlPointCount {
                                result = 0
                            }
                            return result
                        }
                    }
                } else {
                    if isClockwise {
                        if isEnd {
                            var result = tempIntegers[0] + 1
                            if result > guideControlPointCount {
                                result = 0
                            }
                            return result
                        } else {
                            var result = tempIntegers[1] + 1
                            if result > guideControlPointCount {
                                result = 0
                            }
                            return result
                        }
                    } else {
                        if isEnd {
                            let result = tempIntegers[0]
                            return result
                        } else {
                            let result = tempIntegers[1]
                            return result
                        }
                    }
                }
            }
        } else if tempIntegerCount == 1 {
            
            // This is a common case, we have 1 line segment that
            // we are the closest to, e.g. add between these points.
            // Seems like tempIntegers[0] is the right answer, but
            // in test, it seems like tempIntegers[0] + 1 is the
            // right answer. For both clockwise and counter clockwise.
            
            return tempIntegers[0] + 1
        }
        return nil
    }
    
}
