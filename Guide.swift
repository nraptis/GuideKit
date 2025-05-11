//
//  Guide.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 2/28/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit
import TriangleKit
import RenderKit
import WeightCurveKit
import TypeKit

public protocol SelectedGuidePointListeningConforming {
    func realizeRecentSelectionChange_GuidePoint()
}

public class Guide: WeightCurveControlPointOwning {
    
    public init() {
        
    }
    
    static let DEBUG_FLOW = false
    
    public func dispose() {
        
        guideControlPoints.removeAll(keepingCapacity: false)
        guideControlPointCount = 0
        
        processPoints.removeAll(keepingCapacity: false)
        processPointCount = 0
        
        guideWeightPoints.removeAll(keepingCapacity: false)
        guideWeightPointCount = 0
        
        guideWeightSegments.removeAll(keepingCapacity: false)
        guideWeightSegmentCount = 0
        
        outlineGuideWeightSegments.removeAll(keepingCapacity: false)
        outlineGuideWeightSegmentCount = 0
        
        outlineGuideWeightPoints.removeAll(keepingCapacity: false)
        outlineGuideWeightPointCount = 0
        
        tempPrecomputedLineSegments.removeAll(keepingCapacity: false)
        tempPrecomputedLineSegmentCount = 0
        
        tempIntegers.removeAll(keepingCapacity: false)
        tempIntegerCount = 0
    }
    
    public static let maxPointCount = 256
    public static let minPointCount = 3
    
    public var selectionPriorityNumber = 0
    
    public var originalIndex = -1
    
    public var totalSplineLength = Float(0.0)
    
    public var processPoints = [DirectedWeightPoint]()
    public var processPointCount = 0
    public func addProcessPoint(_ point: DirectedWeightPoint) {
        while processPoints.count <= processPointCount {
            processPoints.append(point)
        }
        processPoints[processPointCount] = point
        processPointCount += 1
    }
        
    public func purgeProcessPoints() {
        for processPointIndex in 0..<processPointCount {
            GuidePartsFactory.shared.depositDirectedWeightPoint(processPoints[processPointIndex])
        }
        processPointCount = 0
    }
    
    public var currentHashSpline = SplineHash()
    public var currentHashOutline = OutlineHashGuide()
    public var currentHashSolidLineBufferStandard = SolidLineBufferGuideHash()
    public var currentHashSolidLineBufferPrecise = SolidLineBufferGuideHash()
    
    public var isFrozen = false
    public var isCandidate = false
    
    public var renderSelected = false
    public var renderFrozen = false
    
    public typealias Point = Math.Point
    public typealias Vector = Math.Vector
    
    public let solidLineBufferRegularBloom = SolidLineBuffer<Shape3DVertex, UniformsShapeVertex, UniformsShapeFragment>(sentinelNode: .init())
    public let solidLineBufferRegularStroke = SolidLineBuffer<Shape2DVertex, UniformsShapeVertex, UniformsShapeFragment>(sentinelNode: .init())
    public let solidLineBufferRegularFill = SolidLineBuffer<Shape2DVertex, UniformsShapeVertex, UniformsShapeFragment>(sentinelNode: .init())

    public let solidLineBufferPreciseBloom = SolidLineBuffer<Shape3DVertex, UniformsShapeVertex, UniformsShapeFragment>(sentinelNode: .init())
    public let solidLineBufferPreciseStroke = SolidLineBuffer<Shape2DVertex, UniformsShapeVertex, UniformsShapeFragment>(sentinelNode: .init())
    public let solidLineBufferPreciseFill = SolidLineBuffer<Shape2DVertex, UniformsShapeVertex, UniformsShapeFragment>(sentinelNode: .init())
    
    public let weightCurveControlPoint = WeightCurveControlPoint()
    
    public var percent = Float(0.0)
    
    public var isBroken = false
    public var isGuideClockwise = false
    
    var spline = ManualSpline()
    let borderTool = BorderTool()
    
    public let guideWeightSegmentBucket = GuideWeightSegmentBucket()
    public let guideWeightPointInsidePolygonBucket = GuideWeightPointInsidePolygonBucket()
    
    public var minX = Float(0.0)
    public var maxX = Float(0.0)
    public var minY = Float(0.0)
    public var maxY = Float(0.0)
    public var rangeX = Float(0.0)
    public var rangeY = Float(0.0)
    public var bigness = Float(0.0)
    
    public var renderer: AnyObject!
    
    public func calculateBigness() {
        if guideWeightPointCount <= 2 {
            minX = 0.0
            maxX = 0.0
            minY = 0.0
            maxY = 0.0
            rangeX = 0.0
            rangeY = 0.0
            bigness = 0.0
            return
        }
        
        minX = guideWeightPoints[0].x
        maxX = guideWeightPoints[0].x
        minY = guideWeightPoints[0].y
        maxY = guideWeightPoints[0].y
        
        for guideWeightPointIndex in 1..<guideWeightPointCount {
            let guideWeightPoint = guideWeightPoints[guideWeightPointIndex]
            minX = min(minX, guideWeightPoint.x)
            maxX = max(maxX, guideWeightPoint.x)
            minY = min(minY, guideWeightPoint.y)
            maxY = max(maxY, guideWeightPoint.y)
        }
        
        rangeX = maxX - minX
        rangeY = maxY - minY
        bigness = rangeX + rangeY
    }
    
    public var selectedGuideControlPointIndex = -1
    public func getSelectedGuideControlPoint() -> GuideControlPoint? {
        if selectedGuideControlPointIndex >= 0 && selectedGuideControlPointIndex < guideControlPointCount {
            return guideControlPoints[selectedGuideControlPointIndex]
        }
        return nil
    }
    
    public func containsGuideControlPoint(_ guideControlPoint: GuideControlPoint) -> Bool {
        for guideControlPointIndex in 0..<guideControlPointCount {
            if guideControlPoints[guideControlPointIndex] === guideControlPoint {
                return true
            }
        }
        return false
    }
    
    public var guideControlPoints = [GuideControlPoint]()
    public var guideControlPointCount = 0
    @MainActor public func addGuideControlPoint(x: Float,
                                         y: Float,
                                         jiggleDocument: some SelectedGuidePointListeningConforming,
                                         ignoreRealize: Bool) {
        let guideControlPoint = GuidePartsFactory.shared.withdrawGuideControlPoint()
        guideControlPoint.x = x
        guideControlPoint.y = y
        addGuideControlPoint(guideControlPoint: guideControlPoint,
                             jiggleDocument: jiggleDocument,
                             ignoreRealize: ignoreRealize)
    }
    
    @MainActor public func addGuideControlPoint(directedWeightPoint: DirectedWeightPoint,
                                                jiggleDocument: some SelectedGuidePointListeningConforming,
                                                ignoreRealize: Bool) {
        let guideControlPoint = GuidePartsFactory.shared.withdrawGuideControlPoint()
        guideControlPoint.x = directedWeightPoint.x
        guideControlPoint.y = directedWeightPoint.y
        guideControlPoint.isUnifiedTan = directedWeightPoint.isUnifiedTan
        guideControlPoint.isManualTanHandleEnabled = directedWeightPoint.isManualTanHandleEnabled
        if directedWeightPoint.isManualTanHandleEnabled {
            guideControlPoint.tanDirectionIn = directedWeightPoint.tanDirectionIn
            guideControlPoint.tanDirectionOut = directedWeightPoint.tanDirectionOut
            guideControlPoint.tanMagnitudeIn = directedWeightPoint.tanMagnitudeIn
            guideControlPoint.tanMagnitudeOut = directedWeightPoint.tanMagnitudeOut
        }
        addGuideControlPoint(guideControlPoint: guideControlPoint,
                             jiggleDocument: jiggleDocument,
                             ignoreRealize: ignoreRealize)
    }
    
    @MainActor public func addGuideControlPoint(guideControlPoint: GuideControlPoint,
                                         jiggleDocument: some SelectedGuidePointListeningConforming,
                                         ignoreRealize: Bool) {
        while guideControlPoints.count <= guideControlPointCount {
            guideControlPoints.append(guideControlPoint)
        }
        let newSelectedGuideControlPointIndex = guideControlPointCount
        switchSelectedGuideControlPoint(newSelectedGuideControlPointIndex: newSelectedGuideControlPointIndex,
                                        selectedTanType: .none,
                                        jiggleDocument: jiggleDocument,
                                        ignoreRealize: ignoreRealize)
        
        guideControlPoints[guideControlPointCount] = guideControlPoint
        guideControlPointCount += 1
    }
    
    @MainActor public func switchSelectedGuideControlPoint(newSelectedGuideControlPointIndex: Int,
                                                    selectedTanType: TanTypeOrNone,
                                                    jiggleDocument: some SelectedGuidePointListeningConforming,
                                                    ignoreRealize: Bool) {
        selectedGuideControlPointIndex = newSelectedGuideControlPointIndex
        if newSelectedGuideControlPointIndex >= 0 &&
            newSelectedGuideControlPointIndex < guideControlPointCount {
            guideControlPoints[newSelectedGuideControlPointIndex].selectedTanType = selectedTanType
        }
        if !ignoreRealize {
            jiggleDocument.realizeRecentSelectionChange_GuidePoint()
        }
    }
    
    @MainActor public func insertGuideControlPoint(x: Float,
                                 y: Float,
                                 index: Int,
                                 jiggleDocument: some SelectedGuidePointListeningConforming,
                                 ignoreRealize: Bool) -> GuideControlPoint {
        let guideControlPoint = GuidePartsFactory.shared.withdrawGuideControlPoint()
        guideControlPoint.x = x
        guideControlPoint.y = y
        insertGuideControlPoint(newGuideControlPoint: guideControlPoint,
                                index: index,
                                jiggleDocument: jiggleDocument,
                                ignoreRealize: ignoreRealize)
        return guideControlPoint
    }
        
    @MainActor public func insertGuideControlPoint(newGuideControlPoint: GuideControlPoint,
                                 index: Int,
                                 jiggleDocument: some SelectedGuidePointListeningConforming,
                                            ignoreRealize: Bool) {
        while guideControlPoints.count <= guideControlPointCount {
            guideControlPoints.append(newGuideControlPoint)
        }
        var guideControlPointIndex = guideControlPointCount
        while guideControlPointIndex > index {
            guideControlPoints[guideControlPointIndex] = guideControlPoints[guideControlPointIndex - 1]
            guideControlPointIndex -= 1
        }
        
        guideControlPoints[index] = newGuideControlPoint
        guideControlPointCount += 1
        
        switchSelectedGuideControlPoint(newSelectedGuideControlPointIndex: index,
                                        selectedTanType: .none,
                                        jiggleDocument: jiggleDocument,
                                        ignoreRealize: ignoreRealize)
    }
    
    @MainActor public func removeGuideControlPoint(guideControlPoint: GuideControlPoint,
                                            jiggleDocument: some SelectedGuidePointListeningConforming,
                                            ignoreRealize: Bool) -> Bool {
        for checkIndex in 0..<guideControlPointCount {
            if guideControlPoints[checkIndex] === guideControlPoint {
                if removeGuideControlPoint(index: checkIndex,
                                           jiggleDocument: jiggleDocument,
                                           ignoreRealize: ignoreRealize) {
                    return true
                }
            }
        }
        return false
    }
    
    public func purgeGuideControlPoints() {
        for guideControlPointIndex in 0..<guideControlPointCount {
            let guideControlPoint = guideControlPoints[guideControlPointIndex]
            GuidePartsFactory.shared.depositGuideControlPoint(guideControlPoint)
        }
        guideControlPointCount = 0
    }
    
    @discardableResult
    @MainActor
    public func removeGuideControlPoint(index: Int,
                                 jiggleDocument: some SelectedGuidePointListeningConforming,
                                 ignoreRealize: Bool) -> Bool {
        if index >= 0 && index < guideControlPointCount {
            let guideControlPoint = guideControlPoints[index]
            GuidePartsFactory.shared.depositGuideControlPoint(guideControlPoint)
            let guideControlPointCount1 = guideControlPointCount - 1
            var guideControlPointIndex = index
            while guideControlPointIndex < guideControlPointCount1 {
                guideControlPoints[guideControlPointIndex] = guideControlPoints[guideControlPointIndex + 1]
                guideControlPointIndex += 1
            }
            guideControlPointCount -= 1

            var newSelectedGuideControlPointIndex = selectedGuideControlPointIndex
            if newSelectedGuideControlPointIndex >= guideControlPointCount {
                newSelectedGuideControlPointIndex = guideControlPointCount - 1
            }
            switchSelectedGuideControlPoint(newSelectedGuideControlPointIndex: newSelectedGuideControlPointIndex,
                                            selectedTanType: .none,
                                            jiggleDocument: jiggleDocument,
                                            ignoreRealize: ignoreRealize)
            return true
        }
        return false
    }
    
    public var guideWeightPoints = [GuideWeightPoint]()
    public var guideWeightPointCount = 0
    public func addGuideWeightPoint(_ guideWeightPoint: GuideWeightPoint) {
        while guideWeightPoints.count <= guideWeightPointCount {
            guideWeightPoints.append(guideWeightPoint)
        }
        guideWeightPoints[guideWeightPointCount] = guideWeightPoint
        guideWeightPointCount += 1
    }
    public func purgeGuideWeightPoints() {
        for guideWeightPointIndex in 0..<guideWeightPointCount {
            GuidePartsFactory.shared.depositGuideWeightPoint(guideWeightPoints[guideWeightPointIndex])
        }
        guideWeightPointCount = 0
    }
    
    public var guideWeightSegments = [GuideWeightSegment]()
    public var guideWeightSegmentCount = 0
    public func addGuideWeightSegment(_ guideWeightSegment: GuideWeightSegment) {
        while guideWeightSegments.count <= guideWeightSegmentCount {
            guideWeightSegments.append(guideWeightSegment)
        }
        guideWeightSegments[guideWeightSegmentCount] = guideWeightSegment
        guideWeightSegmentCount += 1
    }
    //func resetGuideWeightSegments() {
    //    guideWeightSegmentCount = 0
    //}
    public func purgeGuideWeightSegments() {
        for guideWeightSegmentsIndex in 0..<guideWeightSegmentCount {
            GuidePartsFactory.shared.depositGuideWeightSegment(guideWeightSegments[guideWeightSegmentsIndex])
        }
        guideWeightSegmentCount = 0
    }
    
    public var outlineGuideWeightSegments = [GuideWeightSegment]()
    public var outlineGuideWeightSegmentCount = 0
    public func addOutlineGuideWeightSegment(_ guideWeightSegment: GuideWeightSegment) {
        while outlineGuideWeightSegments.count <= outlineGuideWeightSegmentCount {
            outlineGuideWeightSegments.append(guideWeightSegment)
        }
        outlineGuideWeightSegments[outlineGuideWeightSegmentCount] = guideWeightSegment
        outlineGuideWeightSegmentCount += 1
    }

    public func purgeOutlineGuideWeightSegments() {
        for guideWeightSegmentsIndex in 0..<outlineGuideWeightSegmentCount {
            GuidePartsFactory.shared.depositGuideWeightSegment(outlineGuideWeightSegments[guideWeightSegmentsIndex])
        }
        outlineGuideWeightSegmentCount = 0
    }
    
    public var outlineGuideWeightPoints = [GuideWeightPoint]()
    public var outlineGuideWeightPointCount = 0
    public func addOutlineGuideWeightPoint(_ guideWeightPoint: GuideWeightPoint) {
        while outlineGuideWeightPoints.count <= outlineGuideWeightPointCount {
            outlineGuideWeightPoints.append(guideWeightPoint)
        }
        outlineGuideWeightPoints[outlineGuideWeightPointCount] = guideWeightPoint
        outlineGuideWeightPointCount += 1
    }

    public func purgeOutlineGuideWeightPoints() {
        for guideWeightPointsIndex in 0..<outlineGuideWeightPointCount {
            GuidePartsFactory.shared.depositGuideWeightPoint(outlineGuideWeightPoints[guideWeightPointsIndex])
        }
        outlineGuideWeightPointCount = 0
    }
    
    public var tempPrecomputedLineSegments = [AnyPrecomputedLineSegment]()
    public var tempPrecomputedLineSegmentCount = 0
    public func addTempPrecomputedLineSegment(x1: Float, y1: Float, x2: Float, y2: Float) {
        let precomputedLineSegment = GuidePartsFactory.shared.withdrawPrecomputedLineSegment()
        precomputedLineSegment.x1 = x1
        precomputedLineSegment.y1 = y1
        precomputedLineSegment.x2 = x2
        precomputedLineSegment.y2 = y2
        addTempPrecomputedLineSegment(precomputedLineSegment)
    }
    
    public func addTempPrecomputedLineSegment(_ precomputedLineSegment: AnyPrecomputedLineSegment) {
        while tempPrecomputedLineSegments.count <= tempPrecomputedLineSegmentCount {
            tempPrecomputedLineSegments.append(precomputedLineSegment)
        }
        tempPrecomputedLineSegments[tempPrecomputedLineSegmentCount] = precomputedLineSegment
        tempPrecomputedLineSegmentCount += 1
        
        precomputedLineSegment.precompute()
    }
    
    public func purgeTempPrecomputedLineSegments() {
        for precomputedLineSegmentIndex in 0..<tempPrecomputedLineSegmentCount {
            let precomputedLineSegment = tempPrecomputedLineSegments[precomputedLineSegmentIndex]
            GuidePartsFactory.shared.depositPrecomputedLineSegment(precomputedLineSegment)
        }
        tempPrecomputedLineSegmentCount = 0
    }
    
    var tempIntegers = [Int]()
    var tempIntegerCount = 0
    func addTempInteger(_ integer: Int) {
        while tempIntegers.count <= tempIntegerCount {
            tempIntegers.append(integer)
        }
        tempIntegers[tempIntegerCount] = integer
        tempIntegerCount += 1
    }
    
    func purgeTempIntegers() {
        tempIntegerCount = 0
    }
    
    public func purge() {
        weightCurveControlPoint.isManualHeightEnabled = false
        weightCurveControlPoint.isManualTanHandleEnabled = false
        
        purgeOutlineGuideWeightSegments()
        purgeOutlineGuideWeightPoints()
        
        purgeGuideWeightPoints()
        purgeGuideWeightSegments()
        
        purgeGuideControlPoints()
    }
    
    public var center = Point.zero
    public var scale = Float(1.0)
    public var rotation = Float(0.0)
    
    public var centerTemp = Point.zero
    
    public func outlineContainsPoint(_ point: Point) -> Bool {
        var end = outlineGuideWeightPointCount - 1
        var start = 0
        var result = false
        while start < outlineGuideWeightPointCount {
            let point1 = outlineGuideWeightPoints[start]
            let point2 = outlineGuideWeightPoints[end]
            let x1: Float
            let y1: Float
            let x2: Float
            let y2: Float
            if point1.x < point2.x {
                x1 = point1.x
                y1 = point1.y
                x2 = point2.x
                y2 = point2.y
            } else {
                x1 = point2.x
                y1 = point2.y
                x2 = point1.x
                y2 = point1.y
            }
            if point.x > x1 && point.x <= x2 {
                if (point.x - x1) * (y2 - y1) - (point.y - y1) * (x2 - x1) < 0.0 {
                    result = !result
                }
            }
            end = start
            start += 1
        }
        return result
    }
    
    public func outlineDistanceSquaredToPoint(_ point: Point) -> Float {
        var result = Float(100_000_000.0)
        for outlineGuideWeightSegmentIndex in 0..<outlineGuideWeightSegmentCount {
            let outlineGuideWeightSegment = outlineGuideWeightSegments[outlineGuideWeightSegmentIndex]
            let distanceSquared = outlineGuideWeightSegment.distanceSquaredToPoint(point)
            if distanceSquared < result {
                result = distanceSquared
            }
        }
        return result
    }
    
    public func getControlPointCenter() -> Point {
        var sumX = Float(0.0)
        var sumY = Float(0.0)
        for guideControlPointIndex in 0..<guideControlPointCount {
            let guideControlPoint = guideControlPoints[guideControlPointIndex]
            sumX += guideControlPoint.x
            sumY += guideControlPoint.y
        }
        if guideControlPointCount > 0 {
            let centerX = sumX / Float(guideControlPointCount)
            let centerY = sumY / Float(guideControlPointCount)
            return Point(x: centerX + center.x,
                         y: centerY + center.y)
        }
        return Point(x: center.x,
                     y: center.y)
    }
    
}

