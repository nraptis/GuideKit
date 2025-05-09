//
//  Guide+Transform.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 11/16/23.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit
import TypeKit

public extension Guide {
    
    func transformPoint(_ x: Float, _ y: Float) -> Point {
        transformPoint(point: Point(x: x, y: y))
    }
    
    func transformPoint(point: Point) -> Point {
        Math.transformPoint(point: point, translation: center, scale: scale, rotation: rotation)
    }
    
    func transformPointScaleAndRotationOnly(_ x: Float, _ y: Float) -> Point {
        transformPointScaleAndRotationOnly(point: Point(x: x, y: y))
    }
    
    func transformPointScaleAndRotationOnly(point: Point) -> Point {
        Math.transformPoint(point: point, scale: scale, rotation: rotation)
    }
    
    func transformPointRotationOnly(_ x: Float, _ y: Float) -> Point {
        transformPointRotationOnly(point: Point(x: x, y: y))
    }
    
    func transformPointRotationOnly(point: Point) -> Point {
        Math.transformPoint(point: point, scale: 1.0, rotation: rotation)
    }
    
    func transformPointRotationOnly(vector: Vector) -> Vector {
        let _point = Math.transformPoint(point: vector.point, scale: 1.0, rotation: rotation)
        return Vector(x: _point.x, y: _point.y)
    }
    
    func transformTanHandles(_ tanHandles: TanHandles) -> TanHandles {
        var inPoint = Point(x: tanHandles.inX, y: tanHandles.inY)
        inPoint = transformPoint(point: inPoint)
        var outPoint = Point(x: tanHandles.outX, y: tanHandles.outY)
        outPoint = transformPoint(point: outPoint)
        return .init(inX: inPoint.x,
                     inY: inPoint.y,
                     outX: outPoint.x,
                     outY: outPoint.y)
    }
    
    func untransformPoint(_ x: Float, _ y: Float) -> Point {
        untransformPoint(point: Point(x: x, y: y))
    }
    
    func untransformPoint(point: Point) -> Point {
        Math.untransformPoint(point: point, translation: center, scale: scale, rotation: rotation)
    }
    
    func untransformPointScaleAndRotationOnly(_ x: Float, _ y: Float) -> Point {
        untransformPointScaleAndRotationOnly(point: Point(x: x, y: y))
    }
    
    func untransformPointScaleAndRotationOnly(point: Point) -> Point {
        Math.untransformPoint(point: point, scale: scale, rotation: rotation)
    }
    
    func untransformPointRotationOnly(_ x: Float, _ y: Float) -> Point {
        untransformPointRotationOnly(point: Point(x: x, y: y))
    }
    
    func untransformPointRotationOnly(point: Point) -> Point {
        Math.untransformPoint(point: point, scale: 1.0, rotation: rotation)
    }
    
    func transformRotation(_ rotation: Float) -> Float {
        rotation + self.rotation
    }
    
    func untransformRotation(_ rotation: Float) -> Float {
        rotation - self.rotation
    }
    
    func transformMagnitude(_ magnitude: Float) -> Float {
        return magnitude * scale
    }
    
    func untransformMagnitude(_ magnitude: Float) -> Float {
        if fabsf(scale) > Math.epsilon {
            return magnitude / scale
        } else {
            return magnitude
        }
    }
}
