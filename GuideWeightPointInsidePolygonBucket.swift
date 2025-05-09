//
//  GuideWeightPointInsidePolygonBucket.swift
//  Guide3
//
//  Created by Nicholas Raptis on 5/9/25.
//

import Foundation

public final class GuideWeightPointInsidePolygonBucket {
    
    private class GuideWeightPointInsidePolygonBucketNode {
        
        var guideWeightSegments = [GuideWeightSegment]()
        var guideWeightSegmentCount = 0
        
        func remove(_ guideWeightSegment: GuideWeightSegment) {
            for checkIndex in 0..<guideWeightSegmentCount {
                if guideWeightSegments[checkIndex] === guideWeightSegment {
                    remove(checkIndex)
                    return
                }
            }
        }
        
        func remove(_ index: Int) {
            if index >= 0 && index < guideWeightSegmentCount {
                let guideWeightSegmentCount1 = guideWeightSegmentCount - 1
                var guideWeightSegmentIndex = index
                while guideWeightSegmentIndex < guideWeightSegmentCount1 {
                    guideWeightSegments[guideWeightSegmentIndex] = guideWeightSegments[guideWeightSegmentIndex + 1]
                    guideWeightSegmentIndex += 1
                }
                guideWeightSegmentCount -= 1
            }
        }
        
        func add(_ guideWeightSegment: GuideWeightSegment) {
            while guideWeightSegments.count <= guideWeightSegmentCount {
                guideWeightSegments.append(guideWeightSegment)
            }
            guideWeightSegments[guideWeightSegmentCount] = guideWeightSegment
            guideWeightSegmentCount += 1
        }
        
    }
    
    private static let countH = 24
    
    private var nodes = [GuideWeightPointInsidePolygonBucketNode]()
    private var gridX: [Float]
    
    public init() {
        gridX = [Float](repeating: 0.0, count: Self.countH)
        var x = 0
        while x < Self.countH {
            let node = GuideWeightPointInsidePolygonBucketNode()
            nodes.append(node)
            x += 1
        }
    }
    
    public func reset() {
        var x = 0
        while x < Self.countH {
            nodes[x].guideWeightSegmentCount = 0
            x += 1
        }
    }
    
    public func build(guideWeightSegments: [GuideWeightSegment], guideWeightSegmentCount: Int) {
        
        reset()
        
        guard guideWeightSegmentCount > 0 else {
            return
        }
        
        let referenceGuideWeightSegment = guideWeightSegments[0]
        
        var minX = min(referenceGuideWeightSegment.x1, referenceGuideWeightSegment.x2)
        var maxX = max(referenceGuideWeightSegment.x1, referenceGuideWeightSegment.x2)
        
        var guideWeightSegmentIndex = 1
        while guideWeightSegmentIndex < guideWeightSegmentCount {
            let guideWeightSegment = guideWeightSegments[guideWeightSegmentIndex]
            
            minX = min(minX, guideWeightSegment.x1); minX = min(minX, guideWeightSegment.x2)
            maxX = max(maxX, guideWeightSegment.x1); maxX = max(maxX, guideWeightSegment.x2)
            
            guideWeightSegmentIndex += 1
        }
        
        minX -= 1.0
        maxX += 1.0
        
        var x = 0
        while x < Self.countH {
            let percent = Float(x) / Float(Self.countH - 1)
            gridX[x] = minX + (maxX - minX) * percent
            x += 1
        }
        
        for guideWeightSegmentIndex in 0..<guideWeightSegmentCount {
            let guideWeightSegment = guideWeightSegments[guideWeightSegmentIndex]
            
            let _minX = min(guideWeightSegment.x1, guideWeightSegment.x2)
            let _maxX = max(guideWeightSegment.x1, guideWeightSegment.x2)
            
            let lowerBoundX = lowerBoundX(value: _minX)
            let upperBoundX = upperBoundX(value: _maxX)
            
            x = lowerBoundX
            while x <= upperBoundX {
                nodes[x].add(guideWeightSegment)
                x += 1
            }
        }
    }
    
    public func query(x: Float, y: Float) -> Bool {
        var result = false
        let indexX = lowerBoundX(value: x)
        if indexX < Self.countH {
            for guideWeightSegmentIndex in 0..<nodes[indexX].guideWeightSegmentCount {
                let guideWeightSegment = nodes[indexX].guideWeightSegments[guideWeightSegmentIndex]
                let x1: Float
                let y1: Float
                let x2: Float
                let y2: Float
                if guideWeightSegment.x1 < guideWeightSegment.x2 {
                    x1 = guideWeightSegment.x1
                    y1 = guideWeightSegment.y1
                    x2 = guideWeightSegment.x2
                    y2 = guideWeightSegment.y2
                } else {
                    x1 = guideWeightSegment.x2
                    y1 = guideWeightSegment.y2
                    x2 = guideWeightSegment.x1
                    y2 = guideWeightSegment.y1
                }
                if x > x1 && x <= x2 {
                    if (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1) < 0.0 {
                        result = !result
                    }
                }
            }
        }
        return result
    }
    
    private func lowerBoundX(value: Float) -> Int {
        var start = 0
        var end = Self.countH
        while start != end {
            let mid = (start + end) >> 1
            if value > gridX[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
    }
    
    private func upperBoundX(value: Float) -> Int {
        var start = 0
        var end = Self.countH
        while start != end {
            let mid = (start + end) >> 1
            if value >= gridX[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return min(start, Self.countH - 1)
    }
}
