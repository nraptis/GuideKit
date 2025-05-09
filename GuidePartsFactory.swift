//
//  GuidePartsFactory.swift
//  Guide3
//
//  Created by Nicholas Raptis on 5/9/25.
//

import Foundation
import TriangleKit
import MathKit
import RenderKit

public class GuidePartsFactory {
    
    public nonisolated(unsafe) static let shared = GuidePartsFactory()
    
    private init() {
        
    }
    
    public func dispose() {
        guideControlPoints.removeAll(keepingCapacity: false)
        guideControlPointCount = 0
        
        guideControlPoints.removeAll(keepingCapacity: false)
        guideControlPointCount = 0
        
        guideWeightPoints.removeAll(keepingCapacity: false)
        guideWeightPointCount = 0
        
        guideWeightSegments.removeAll(keepingCapacity: false)
        guideWeightSegmentCount = 0
        
        precomputedLineSegments.removeAll(keepingCapacity: false)
        precomputedLineSegmentCount = 0
    }
    
    ////////////////
    ///
    ///
    private var guideControlPoints = [GuideControlPoint]()
    var guideControlPointCount = 0
    public func depositGuideControlPoint(_ guideControlPoint: GuideControlPoint) {
        while guideControlPoints.count <= guideControlPointCount {
            guideControlPoints.append(guideControlPoint)
        }
        
        guideControlPoint.isManualTanHandleEnabled = false
        guideControlPoint.isUnifiedTan = true
        guideControlPoint.isTanHandleEverModifiedByUserDrag = false
        guideControlPoint.selectedTanType = .none
        
        guideControlPoints[guideControlPointCount] = guideControlPoint
        guideControlPointCount += 1
    }
    
    public func withdrawGuideControlPoint() -> GuideControlPoint {
        if guideControlPointCount > 0 {
            guideControlPointCount -= 1
            let result = guideControlPoints[guideControlPointCount]
            
            return result
        }
        return GuideControlPoint()
    }
    ///
    ///
    ////////////////
        
    ////////////////
    ///
    ///
    private var guideWeightPoints = [GuideWeightPoint]()
    var guideWeightPointCount = 0
    public func depositGuideWeightPoint(_ guideWeightPoint: GuideWeightPoint) {
        while guideWeightPoints.count <= guideWeightPointCount {
            guideWeightPoints.append(guideWeightPoint)
        }
        guideWeightPoints[guideWeightPointCount] = guideWeightPoint
        guideWeightPointCount += 1
    }
    public func withdrawGuideWeightPoint() -> GuideWeightPoint {
        if guideWeightPointCount > 0 {
            guideWeightPointCount -= 1
            return guideWeightPoints[guideWeightPointCount]
        }
        return GuideWeightPoint()
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var guideWeightSegments = [GuideWeightSegment]()
    var guideWeightSegmentCount = 0
    public func depositGuideWeightSegment(_ guideWeightSegment: GuideWeightSegment) {
        guideWeightSegment.isIllegal = false
        guideWeightSegment.isBucketed = false // This may well have been the midding nugget
        
        while guideWeightSegments.count <= guideWeightSegmentCount {
            guideWeightSegments.append(guideWeightSegment)
        }
        guideWeightSegments[guideWeightSegmentCount] = guideWeightSegment
        guideWeightSegmentCount += 1
    }
    public func withdrawGuideWeightSegment() -> GuideWeightSegment {
        if guideWeightSegmentCount > 0 {
            guideWeightSegmentCount -= 1
            return guideWeightSegments[guideWeightSegmentCount]
        }
        return GuideWeightSegment()
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var precomputedLineSegments = [AnyPrecomputedLineSegment]()
    var precomputedLineSegmentCount = 0
    public func depositPrecomputedLineSegment(_ precomputedLineSegment: AnyPrecomputedLineSegment) {
        while precomputedLineSegments.count <= precomputedLineSegmentCount {
            precomputedLineSegments.append(precomputedLineSegment)
        }
        precomputedLineSegments[precomputedLineSegmentCount] = precomputedLineSegment
        precomputedLineSegmentCount += 1
    }
    public func withdrawPrecomputedLineSegment() -> AnyPrecomputedLineSegment {
        if precomputedLineSegmentCount > 0 {
            precomputedLineSegmentCount -= 1
            return precomputedLineSegments[precomputedLineSegmentCount]
        }
        return AnyPrecomputedLineSegment()
    }
    ///
    ///
    ////////////////
}
