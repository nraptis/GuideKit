//
//  GuideWeightSegmentBucket.swift
//  Guide3
//
//  Created by Nicholas Raptis on 5/9/25.
//

import Foundation

public final class GuideWeightSegmentBucket {
    
    private class GuideWeightSegmentBucketNode {
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
    private static let countV = 24
    
    private var grid = [[GuideWeightSegmentBucketNode]]()
    private var gridX: [Float]
    private var gridY: [Float]
    
    public private(set) var guideWeightSegments: [GuideWeightSegment]
    public private(set) var guideWeightSegmentCount = 0
    
    public init() {
        
        gridX = [Float](repeating: 0.0, count: Self.countH)
        gridY = [Float](repeating: 0.0, count: Self.countV)
        guideWeightSegments = [GuideWeightSegment]()
        
        var x = 0
        while x < Self.countH {
            var column = [GuideWeightSegmentBucketNode]()
            var y = 0
            while y < Self.countV {
                let node = GuideWeightSegmentBucketNode()
                column.append(node)
                y += 1
            }
            grid.append(column)
            x += 1
        }
    }
    
    public func reset() {
        var x = 0
        var y = 0
        while x < Self.countH {
            y = 0
            while y < Self.countV {
                grid[x][y].guideWeightSegmentCount = 0
                y += 1
            }
            x += 1
        }
        
        guideWeightSegmentCount = 0
    }
    
    public func build(guideWeightSegments: [GuideWeightSegment], guideWeightSegmentCount: Int) {
        
        reset()
        
        guard guideWeightSegmentCount > 0 else {
            return
        }
        
        let referenceGuideWeightSegment = guideWeightSegments[0]
        
        var minX = min(referenceGuideWeightSegment.x1, referenceGuideWeightSegment.x2)
        var maxX = max(referenceGuideWeightSegment.x1, referenceGuideWeightSegment.x2)
        var minY = min(referenceGuideWeightSegment.y1, referenceGuideWeightSegment.y2)
        var maxY = max(referenceGuideWeightSegment.y1, referenceGuideWeightSegment.y2)
        
        var guideWeightSegmentIndex = 1
        while guideWeightSegmentIndex < guideWeightSegmentCount {
            let guideWeightSegment = guideWeightSegments[guideWeightSegmentIndex]
            minX = min(minX, guideWeightSegment.x1); minX = min(minX, guideWeightSegment.x2)
            maxX = max(maxX, guideWeightSegment.x1); maxX = max(maxX, guideWeightSegment.x2)
            minY = min(minY, guideWeightSegment.y1); minY = min(minY, guideWeightSegment.y2)
            maxY = max(maxY, guideWeightSegment.y1); maxY = max(maxY, guideWeightSegment.y2)
            guideWeightSegmentIndex += 1
        }
        
        minX -= 32.0
        maxX += 32.0
        minY -= 32.0
        maxY += 32.0
        
        var x = 0
        while x < Self.countH {
            let percent = Float(x) / Float(Self.countH - 1)
            gridX[x] = minX + (maxX - minX) * percent
            x += 1
        }
        
        var y = 0
        while y < Self.countV {
            let percent = Float(y) / Float(Self.countV - 1)
            gridY[y] = minY + (maxY - minY) * percent
            y += 1
        }
        
        for guideWeightSegmentIndex in 0..<guideWeightSegmentCount {
            let guideWeightSegment = guideWeightSegments[guideWeightSegmentIndex]
            
            let _minX = min(guideWeightSegment.x1, guideWeightSegment.x2)
            let _maxX = max(guideWeightSegment.x1, guideWeightSegment.x2)
            let _minY = min(guideWeightSegment.y1, guideWeightSegment.y2)
            let _maxY = max(guideWeightSegment.y1, guideWeightSegment.y2)
            
            let lowerBoundX = lowerBoundX(value: _minX)
            let upperBoundX = upperBoundX(value: _maxX)
            let lowerBoundY = lowerBoundY(value: _minY)
            let upperBoundY = upperBoundY(value: _maxY)
            
            x = lowerBoundX
            while x <= upperBoundX {
                y = lowerBoundY
                while y <= upperBoundY {
                    grid[x][y].add(guideWeightSegment)
                    y += 1
                }
                x += 1
            }
        }
    }
    
    public func remove(guideWeightSegment: GuideWeightSegment) {
        let _minX = min(guideWeightSegment.x1, guideWeightSegment.x2)
        let _maxX = max(guideWeightSegment.x1, guideWeightSegment.x2)
        let _minY = min(guideWeightSegment.y1, guideWeightSegment.y2)
        let _maxY = max(guideWeightSegment.y1, guideWeightSegment.y2)
        
        let lowerBoundX = lowerBoundX(value: _minX)
        let upperBoundX = upperBoundX(value: _maxX)
        let lowerBoundY = lowerBoundY(value: _minY)
        let upperBoundY = upperBoundY(value: _maxY)
        
        var x = 0
        var y = 0
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                grid[x][y].remove(guideWeightSegment)
                y += 1
            }
            x += 1
        }
    }
    
    public func add(guideWeightSegment: GuideWeightSegment) {
            
        let _minX = min(guideWeightSegment.x1, guideWeightSegment.x2)
        let _maxX = max(guideWeightSegment.x1, guideWeightSegment.x2)
        let _minY = min(guideWeightSegment.y1, guideWeightSegment.y2)
        let _maxY = max(guideWeightSegment.y1, guideWeightSegment.y2)
        
        let lowerBoundX = lowerBoundX(value: _minX)
        let upperBoundX = upperBoundX(value: _maxX)
        let lowerBoundY = lowerBoundY(value: _minY)
        let upperBoundY = upperBoundY(value: _maxY)
        
        var x = 0
        var y = 0
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                grid[x][y].add(guideWeightSegment)
                y += 1
            }
            x += 1
        }
    }
    
    public func query(guideWeightSegment: GuideWeightSegment) {
        let x1 = guideWeightSegment.x1
        let y1 = guideWeightSegment.y1
        let x2 = guideWeightSegment.x2
        let y2 = guideWeightSegment.y2
        query(minX: min(x1, x2),
              maxX: max(x1, x2),
              minY: min(y1, y2),
              maxY: max(y1, y2))
    }
    
    public func query(guideWeightSegment: GuideWeightSegment, padding: Float) {
        let x1 = guideWeightSegment.x1
        let y1 = guideWeightSegment.y1
        let x2 = guideWeightSegment.x2
        let y2 = guideWeightSegment.y2
        query(minX: min(x1, x2) - padding,
              maxX: max(x1, x2) + padding,
              minY: min(y1, y2) - padding,
              maxY: max(y1, y2) + padding)
    }
    
    public func query(minX: Float, maxX: Float, minY: Float, maxY: Float) {
        
        guideWeightSegmentCount = 0
        
        let lowerBoundX = lowerBoundX(value: minX)
        var upperBoundX = upperBoundX(value: maxX)
        let lowerBoundY = lowerBoundY(value: minY)
        var upperBoundY = upperBoundY(value: maxY)
        
        if upperBoundX >= Self.countH {
            upperBoundX = Self.countH - 1
        }
        
        if upperBoundY >= Self.countV {
            upperBoundY = Self.countV - 1
        }
        
        var x = 0
        var y = 0
        
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                for guideWeightSegmentIndex in 0..<grid[x][y].guideWeightSegmentCount {
                    grid[x][y].guideWeightSegments[guideWeightSegmentIndex].isBucketed = false
                }
                y += 1
            }
            x += 1
        }
        
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                for guideWeightSegmentIndex in 0..<grid[x][y].guideWeightSegmentCount {
                    let guideWeightSegment = grid[x][y].guideWeightSegments[guideWeightSegmentIndex]
                    if guideWeightSegment.isBucketed == false {
                        guideWeightSegment.isBucketed = true
                        
                        while guideWeightSegments.count <= guideWeightSegmentCount {
                            guideWeightSegments.append(guideWeightSegment)
                        }
                        guideWeightSegments[guideWeightSegmentCount] = guideWeightSegment
                        guideWeightSegmentCount += 1
                    }
                }
                y += 1
            }
            x += 1
        }
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
    
    private func lowerBoundY(value: Float) -> Int {
        var start = 0
        var end = Self.countV
        while start != end {
            let mid = (start + end) >> 1
            if value > gridY[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
        
    }
    
    private func upperBoundY(value: Float) -> Int {
        var start = 0
        var end = Self.countV
        while start != end {
            let mid = (start + end) >> 1
            if value >= gridY[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return min(start, Self.countV - 1)
    }
}
