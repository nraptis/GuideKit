//
//  GuideControlPoint.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 11/21/24.
//

import Foundation
import MathKit
import TypeKit

public class GuideControlPoint {
    
    public typealias Point = Math.Point
    
    public var selectedTanType = TanTypeOrNone.none
    
    public var x = Float(0.0)
    public var y = Float(0.0)
    public var tanDirectionIn = Float(0.0)
    public var tanDirectionOut = Float(0.0)
    public var tanMagnitudeIn = Float(10.0)
    public var tanMagnitudeOut = Float(10.0)
    public var isManualTanHandleEnabled = false
    public var isUnifiedTan = true
    
    public var isTanHandleEverModifiedByUserDrag = false
    
    public var storedUserDragTanUnified = true
    public var storedUserDragTanDirectionIn = Float(0.0)
    public var storedUserDragTanDirectionOut = Float(0.0)
    public var storedUserDragTanMagnitudeIn = Float(10.0)
    public var storedUserDragTanMagnitudeOut = Float(10.0)
    
    public var renderPointSelected = RenderPointSelectedStrategy.ignore
    public var renderTanInSelected = false
    public var renderTanOutSelected = false
    
    public var renderX = Float(0.0)
    public var renderY = Float(0.0)
    public var renderTanInX = Float(0.0)
    public var renderTanInY = Float(0.0)
    public var renderTanOutX = Float(0.0)
    public var renderTanOutY = Float(0.0)
    public var renderTanNormalInX = Float(0.0)
    public var renderTanNormalInY = Float(-1.0)
    public var renderTanNormalOutX = Float(0.0)
    public var renderTanNormalOutY = Float(-1.0)
    
    public var point: Point {
        Point(x: x, y: y)
    }
    
    public func disableManualTanHandle() {
        isManualTanHandleEnabled = false
    }
    
    public func setManualTanHandleIn(direction: Float,
                                     magnitude: Float,
                                     isUnified: Bool) {
        tanDirectionIn = direction
        if isUnified {
            tanDirectionOut = tanDirectionIn
        }
        tanMagnitudeIn = magnitude
        isManualTanHandleEnabled = true
        isUnifiedTan = isUnified
        isTanHandleEverModifiedByUserDrag = true
        storedUserDragTanDirectionIn = tanDirectionIn
        storedUserDragTanDirectionOut = tanDirectionOut
        storedUserDragTanMagnitudeIn = tanMagnitudeIn
        storedUserDragTanMagnitudeOut = tanMagnitudeOut
        storedUserDragTanUnified = isUnified
    }
    
    public func setManualTanHandleOut(direction: Float,
                                      magnitude: Float,
                                      isUnified: Bool) {
        tanDirectionOut = -direction
        if isUnified {
            tanDirectionIn = tanDirectionOut
        }
        tanMagnitudeOut = magnitude
        isManualTanHandleEnabled = true
        isUnifiedTan = isUnified
        isTanHandleEverModifiedByUserDrag = true
        storedUserDragTanDirectionIn = tanDirectionIn
        storedUserDragTanDirectionOut = tanDirectionOut
        storedUserDragTanMagnitudeIn = tanMagnitudeIn
        storedUserDragTanMagnitudeOut = tanMagnitudeOut
        storedUserDragTanUnified = isUnified
    }
    
    public func getTanHandles() -> TanHandles {
        return TanHandles(inX: x - sinf(tanDirectionIn) * tanMagnitudeIn,
                          inY: y + cosf(tanDirectionIn) * tanMagnitudeIn,
                          outX: x + sinf(tanDirectionOut) * tanMagnitudeOut,
                          outY: y - cosf(tanDirectionOut) * tanMagnitudeOut)
    }
    
    public func getTanHandleIn() -> Point {
        return Point(x: x - sinf(tanDirectionIn) * tanMagnitudeIn,
                     y: y + cosf(tanDirectionIn) * tanMagnitudeIn)
    }
    
    public func getTanHandleOut() -> Point {
        return Point(x: x + sinf(tanDirectionOut) * tanMagnitudeOut,
                     y: y - cosf(tanDirectionOut) * tanMagnitudeOut)
    }
    
    public func getTanHandleNormalsIn() -> Math.Vector {
        return Math.Vector(x: cosf(tanDirectionIn),
                           y: sinf(tanDirectionIn))
    }
    
    public func getTanHandleNormalsOut() -> Math.Vector {
        return Math.Vector(x: cosf(tanDirectionOut),
                           y: sinf(tanDirectionOut))
    }
    
    public func attemptAngleFromTansUnified(inTanX: Float,
                                            inTanY: Float,
                                            outTanX: Float,
                                            outTanY: Float,
                                            tanFactorJiggleControlPoint: Float) -> Bool {
        
        var inDist = inTanX * inTanX + inTanY * inTanY
        var outDist = outTanX * outTanX + outTanY * outTanY
        
        let epsilon1 = Float(32.0 * 32.0)
        let epsilon2 = Float( 4.0 *  4.0)
        let epsilon3 = Float(0.1 * 0.1)
        
        var rotation = Float(0.0)
        var isValidReading = true
        
        if inDist > epsilon1 {
            rotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
        } else if outDist > epsilon1 {
            rotation = Math.face(target: .init(x: outTanX, y: outTanY))
        } else if inDist > epsilon2 {
            rotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
        } else if outDist > epsilon2 {
            rotation = Math.face(target: .init(x: outTanX, y: outTanY))
        } else if inDist > epsilon3 {
            rotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
        } else if outDist > epsilon3 {
            rotation = Math.face(target: .init(x: outTanX, y: outTanY))
        } else {
            isValidReading = false
        }
        
        if inDist > Math.epsilon {
            inDist = sqrtf(inDist)
        }
        
        if outDist > Math.epsilon {
            outDist = sqrtf(outDist)
        }
        
        if isValidReading {
            tanDirectionIn = rotation
            tanDirectionOut = rotation
            isUnifiedTan = true
            tanMagnitudeIn = inDist * tanFactorJiggleControlPoint
            tanMagnitudeOut = outDist * tanFactorJiggleControlPoint
            return true
        } else {
            return false
        }
    }
    
    public func attemptAngleFromTansNotUnified(inTanX: Float,
                                               inTanY: Float,
                                               outTanX: Float,
                                               outTanY: Float,
                                               tanFactorJiggleControlPoint: Float) -> Bool {
        
        var inDist = inTanX * inTanX + inTanY * inTanY
        var outDist = outTanX * outTanX + outTanY * outTanY
        
        let epsilon1 = Float(32.0 * 32.0)
        let epsilon2 = Float( 4.0 *  4.0)
        let epsilon3 = Float(0.1 * 0.1)
        
        var inRotation = Float(0.0)
        var outRotation = Float(0.0)
        
        var isValidReadingIn = true
        var isValidReadingOut = true
        
        
        if inDist > epsilon1 {
            inRotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
        } else if inDist > epsilon2 {
            inRotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
        } else if inDist > epsilon3 {
            inRotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
        } else {
            isValidReadingIn = false
        }
        
        if outDist > epsilon1 {
            outRotation = Math.face(target: .init(x: outTanX, y: outTanY))
        } else if outDist > epsilon2 {
            outRotation = Math.face(target: .init(x: outTanX, y: outTanY))
        } else if outDist > epsilon3 {
            outRotation = Math.face(target: .init(x: outTanX, y: outTanY))
        } else {
            isValidReadingOut = false
        }
        
        if inDist > Math.epsilon {
            inDist = sqrtf(inDist)
        }
        
        if outDist > Math.epsilon {
            outDist = sqrtf(outDist)
        }
        
        if isValidReadingIn && isValidReadingOut {
            tanDirectionIn = inRotation
            tanDirectionOut = outRotation
            tanMagnitudeIn = inDist * tanFactorJiggleControlPoint
            tanMagnitudeOut = outDist * tanFactorJiggleControlPoint
            isManualTanHandleEnabled = true
            isUnifiedTan = false
            return true
        } else {
            return false
        }
    }
}
