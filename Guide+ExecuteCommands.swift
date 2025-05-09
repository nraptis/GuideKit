//
//  Guide+ExecuteCommands.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 11/9/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit
import TriangleKit
import TypeKit
import RenderKit

public extension Guide {
    
    func execute(guideCommand: GuideCommand,
                 worldScaleStandard: Float,
                 worldScalePrecise: Float,
                 creatorMode: CreatorMode,
                 weightMode: WeightMode,
                 isDarkMode: Bool,
                 isJiggleSelected: Bool,
                 isJiggleFrozen: Bool,
                 jiggleCenter: Point,
                 jiggleScale: Float,
                 jiggleRotation: Float,
                 isGuideSelected: Bool,
                 isGuideFrozen: Bool,
                 weightDepthIndex: Int,
                 guideCount: Int,
                 lineThicknessType: RenderLineThicknessType,
                 lineThicknessStroke: Float,
                 lineThicknessFill: Float,
                 tanFactorJiggleControlPoint: Float) {
        
        if guideCommand.spline {
            refreshSpline(tanFactorJiggleControlPoint: tanFactorJiggleControlPoint)
        } else {
            if Guide.DEBUG_FLOW {
                print("(FLOW) {W-Ring \(ObjectIdentifier(self))} SKIPPED Spline: \(currentHashSpline)")
            }
        }
        
        var checkHashOutline = OutlineHashGuide()
        checkHashOutline.change(splineHash: currentHashSpline,
                                centerX: center.x,
                                centerY: center.y,
                                scale: scale,
                                rotation: rotation,
                                jiggleCenterX: jiggleCenter.x,
                                jiggleCenterY: jiggleCenter.y,
                                jiggleScale: jiggleScale,
                                jiggleRotation: jiggleRotation,
                                lineThicknessType: lineThicknessType)
        
        if checkHashOutline != currentHashOutline {
            refreshOutline(jiggleCenter: jiggleCenter,
                           jiggleScale: jiggleScale,
                           jiggleRotation: jiggleRotation,
                           lineThicknessType: lineThicknessType)
        } else {
            if Guide.DEBUG_FLOW {
                print("(FLOW) {W-Ring \(ObjectIdentifier(self))} SKIPPED Outline: \(currentHashOutline)")
            }
        }
        
        var checkHashSolidLineBufferStandard = SolidLineBufferGuideHash()
        checkHashSolidLineBufferStandard.change(splineHash: currentHashSpline,
                                                centerX: center.x,
                                                centerY: center.y,
                                                scale: scale,
                                                rotation: rotation,
                                                worldScale: worldScaleStandard,
                                                creatorMode: creatorMode,
                                                weightMode: weightMode,
                                                isGuideSelected: isGuideSelected,
                                                isJiggleSelected: isJiggleSelected,
                                                isJiggleFrozen: isJiggleFrozen,
                                                isGuideFrozen: isGuideFrozen,
                                                isDarkMode: isDarkMode,
                                                weightDepthIndex: weightDepthIndex,
                                                guideCount: guideCount,
                                                jiggleCenterX: jiggleCenter.x,
                                                jiggleCenterY: jiggleCenter.y,
                                                jiggleScale: jiggleScale,
                                                jiggleRotation: jiggleRotation,
                                                lineThicknessType: lineThicknessType)
        
        if checkHashSolidLineBufferStandard != currentHashSolidLineBufferStandard {
            refreshSolidLineBuffersStandard(worldScaleStandard: worldScaleStandard,
                                            creatorMode: creatorMode,
                                            weightMode: weightMode,
                                            isJiggleSelected: isJiggleSelected,
                                            isGuideSelected: isGuideSelected,
                                            isJiggleFrozen: isJiggleFrozen,
                                            isGuideFrozen: isGuideFrozen,
                                            isDarkMode: isDarkMode,
                                            jiggleCenter: jiggleCenter,
                                            jiggleScale: jiggleScale,
                                            jiggleRotation: jiggleRotation,
                                            weightDepthIndex: weightDepthIndex,
                                            guideCount: guideCount,
                                            lineThicknessType: lineThicknessType,
                                            lineThicknessStroke: lineThicknessStroke,
                                            lineThicknessFill: lineThicknessFill)
        } else {
            if Guide.DEBUG_FLOW {
                print("(FLOW) {W-Ring \(ObjectIdentifier(self))} SKIPPED Solid Line: \(currentHashSolidLineBufferStandard)")
            }
        }
        
        var checkHashSolidLineBufferPrecise = SolidLineBufferGuideHash()
        checkHashSolidLineBufferPrecise.change(splineHash: currentHashSpline,
                                               centerX: center.x,
                                               centerY: center.y,
                                               scale: scale,
                                               rotation: rotation,
                                               worldScale: worldScalePrecise,
                                               creatorMode: creatorMode,
                                               weightMode: weightMode,
                                               isGuideSelected: isGuideSelected,
                                               isJiggleSelected: isJiggleSelected,
                                               isJiggleFrozen: isJiggleFrozen,
                                               isGuideFrozen: isGuideFrozen,
                                               isDarkMode: isDarkMode,
                                               weightDepthIndex: weightDepthIndex,
                                               guideCount: guideCount,
                                               jiggleCenterX: jiggleCenter.x,
                                               jiggleCenterY: jiggleCenter.y,
                                               jiggleScale: jiggleScale,
                                               jiggleRotation: jiggleRotation,
                                               lineThicknessType: lineThicknessType)
        
        if checkHashSolidLineBufferPrecise != currentHashSolidLineBufferPrecise {
            refreshSolidLineBuffersPrecise(worldScalePrecise: worldScalePrecise,
                                           creatorMode: creatorMode,
                                           weightMode: weightMode,
                                           isJiggleSelected: isJiggleSelected,
                                           isGuideSelected: isGuideSelected,
                                           isJiggleFrozen: isJiggleFrozen,
                                           isGuideFrozen: isGuideFrozen,
                                           isDarkMode: isDarkMode,
                                           jiggleCenter: jiggleCenter,
                                           jiggleScale: jiggleScale,
                                           jiggleRotation: jiggleRotation,
                                           weightDepthIndex: weightDepthIndex,
                                           guideCount: guideCount,
                                           lineThicknessType: lineThicknessType)
        } else {
            if Guide.DEBUG_FLOW {
                print("(FLOW) {W-Ring \(ObjectIdentifier(self))} SKIPPED Solid Line: \(currentHashSolidLineBufferPrecise)")
            }
        }
    }
    
    private func refreshSpline(tanFactorJiggleControlPoint: Float) {
        
        isBroken = false
        purgeGuideWeightPoints()
        purgeGuideWeightSegments()
        
        spline.removeAll(keepingCapacity: true)
        for guideControlPointIndex in 0..<guideControlPointCount {
            let guideControlPoint = guideControlPoints[guideControlPointIndex]
            spline.addControlPoint(guideControlPoint.x, guideControlPoint.y)
            if guideControlPoint.isManualTanHandleEnabled {
                let magnitudeIn = guideControlPoint.tanMagnitudeIn / tanFactorJiggleControlPoint
                let magnitudeOut = guideControlPoint.tanMagnitudeOut / tanFactorJiggleControlPoint
                let inDirX = sinf(guideControlPoint.tanDirectionIn)
                let inDirY = -cosf(guideControlPoint.tanDirectionIn)
                let outDirX = sinf(guideControlPoint.tanDirectionOut)
                let outDirY = -cosf(guideControlPoint.tanDirectionOut)
                spline.enableManualControlTan(at: guideControlPointIndex,
                                              inTanX: -inDirX * magnitudeIn,
                                              inTanY: -inDirY * magnitudeIn,
                                              outTanX: outDirX * magnitudeOut,
                                              outTanY: outDirY * magnitudeOut)
            } else {
                spline.disableManualControlTan(at: guideControlPointIndex)
            }
        }
        
        spline.solve(closed: true)
        
        for guideControlPointIndex in 0..<guideControlPointCount {
            let guideControlPoint = guideControlPoints[guideControlPointIndex]
            if guideControlPoint.isManualTanHandleEnabled == false {
                _ = guideControlPoint.attemptAngleFromTansUnified(inTanX: spline.inTanX[guideControlPointIndex],
                                                                  inTanY: spline.inTanY[guideControlPointIndex],
                                                                  outTanX: spline.outTanX[guideControlPointIndex],
                                                                  outTanY: spline.outTanY[guideControlPointIndex],
                                                                  tanFactorJiggleControlPoint: tanFactorJiggleControlPoint)
            }
        }
        
        borderTool.build(spline: spline,
                         preferredStepSize: PolyMeshConstants.borderPreferredStepSize,
                         skipInterpolationDistance: PolyMeshConstants.borderSkipInterpolationDistance,
                         lowFiSampleDistance: PolyMeshConstants.borderLowFiSampleDistance,
                         medFiSampleDistance: PolyMeshConstants.borderMedFiSampleDistance)
        
        for borderIndex in 0..<borderTool.borderCount {
            let x = borderTool.borderX[borderIndex]
            let y = borderTool.borderY[borderIndex]
            let guideWeightPoint = GuidePartsFactory.shared.withdrawGuideWeightPoint()
            guideWeightPoint.x = x
            guideWeightPoint.y = y
            addGuideWeightPoint(guideWeightPoint)
        }
        
        // Finally, we will UN-transform these...
        for guideWeightPointIndex in 0..<guideWeightPointCount {
            let guideWeightPoint = guideWeightPoints[guideWeightPointIndex]
            var transformedPoint = Point(x: guideWeightPoint.x,
                                         y: guideWeightPoint.y)
            transformedPoint = transformPoint(guideWeightPoint.x, guideWeightPoint.y)
            guideWeightPoint.x = transformedPoint.x
            guideWeightPoint.y = transformedPoint.y
        }
        
        
        var area = Float(0.0)
        for index1 in 0..<guideWeightPointCount {
            var index2 = index1 + 1
            if index2 == guideWeightPointCount {
                index2 = 0
            }
            let guideWeightPoint1 = guideWeightPoints[index1]
            let guideWeightPoint2 = guideWeightPoints[index2]
            let point1 = guideWeightPoint1.point
            let point2 = guideWeightPoint2.point
            area += Math.cross(x1: point1.x, y1: point1.y,
                                       x2: point2.x, y2: point2.y)
        }
        isGuideClockwise = (area > 0.0)
        
        if guideWeightPointCount < 3 {
            isBroken = true
            return
        }
        
        var guideWeightPointIndex1 = 0
        var guideWeightPointIndex2 = 1
        while guideWeightPointIndex1 < guideWeightPointCount {
            let guideWeightPoint1 = guideWeightPoints[guideWeightPointIndex1]
            let guideWeightPoint2 = guideWeightPoints[guideWeightPointIndex2]
            let guideWeightSegment = GuidePartsFactory.shared.withdrawGuideWeightSegment()
            guideWeightSegment.x1 = guideWeightPoint1.x
            guideWeightSegment.y1 = guideWeightPoint1.y
            guideWeightSegment.x2 = guideWeightPoint2.x
            guideWeightSegment.y2 = guideWeightPoint2.y
            guideWeightSegment.precompute()
            
            addGuideWeightSegment(guideWeightSegment)
            if guideWeightSegment.isIllegal {
                isBroken = true
            }
            
            guideWeightPointIndex1 += 1
            guideWeightPointIndex2 += 1
            if guideWeightPointIndex2 == guideWeightPointCount {
                guideWeightPointIndex2 = 0
            }
        }
        
        guideWeightPointInsidePolygonBucket.build(guideWeightSegments: guideWeightSegments,
                                                   guideWeightSegmentCount: guideWeightSegmentCount)
        guideWeightSegmentBucket.build(guideWeightSegments: guideWeightSegments,
                                        guideWeightSegmentCount: guideWeightSegmentCount)
        currentHashSpline.change()
        if Guide.DEBUG_FLOW {
            print("(FLOW) {W-Ring \(ObjectIdentifier(self))} CRUNCHED Spline: \(currentHashSpline)")
        }
    }
    
    private func refreshOutline(jiggleCenter: Point,
                                jiggleScale: Float,
                                jiggleRotation: Float,
                                lineThicknessType: RenderLineThicknessType) {
        
        purgeOutlineGuideWeightPoints()
        purgeOutlineGuideWeightSegments()
        
        for guideWeightPointIndex in 0..<guideWeightPointCount {
            let guideWeightPoint = guideWeightPoints[guideWeightPointIndex]
            let outlineGuideWeightPoint = GuidePartsFactory.shared.withdrawGuideWeightPoint()
            var point = guideWeightPoint.point
            
            point = Math.transformPoint(point: point,
                                                translation: jiggleCenter,
                                                scale: jiggleScale,
                                                rotation: jiggleRotation)
            
            outlineGuideWeightPoint.x = point.x
            outlineGuideWeightPoint.y = point.y
            addOutlineGuideWeightPoint(outlineGuideWeightPoint)
        }
        
        
        var guideWeightPointIndex1 = outlineGuideWeightPointCount - 1
        var guideWeightPointIndex2 = 0
        while guideWeightPointIndex2 < outlineGuideWeightPointCount {
            let guideWeightPoint1 = outlineGuideWeightPoints[guideWeightPointIndex1]
            let guideWeightPoint2 = outlineGuideWeightPoints[guideWeightPointIndex2]
            let outguideWeightSegment = GuidePartsFactory.shared.withdrawGuideWeightSegment()
            outguideWeightSegment.x1 = guideWeightPoint1.x
            outguideWeightSegment.y1 = guideWeightPoint1.y
            outguideWeightSegment.x2 = guideWeightPoint2.x
            outguideWeightSegment.y2 = guideWeightPoint2.y
            outguideWeightSegment.precompute()
            
            addOutlineGuideWeightSegment(outguideWeightSegment)
            
            guideWeightPointIndex1 = guideWeightPointIndex2
            guideWeightPointIndex2 += 1
        }
        
        currentHashOutline.change(splineHash: currentHashSpline,
                                  centerX: center.x,
                                  centerY: center.y,
                                  scale: scale,
                                  rotation: rotation,
                                  jiggleCenterX: jiggleCenter.x,
                                  jiggleCenterY: jiggleCenter.y,
                                  jiggleScale: jiggleScale,
                                  jiggleRotation: jiggleRotation,
                                  lineThicknessType: lineThicknessType)
        
        if Guide.DEBUG_FLOW {
            print("(FLOW) {W-Ring \(ObjectIdentifier(self))} CRUNCHED Outline: \(currentHashOutline)")
        }
    }
    
    func refreshSolidLineBuffersStandard(worldScaleStandard: Float,
                                         creatorMode: CreatorMode,
                                         weightMode: WeightMode,
                                         isJiggleSelected: Bool,
                                         isGuideSelected: Bool,
                                         isJiggleFrozen: Bool,
                                         isGuideFrozen: Bool,
                                         isDarkMode: Bool,
                                         jiggleCenter: Point,
                                         jiggleScale: Float,
                                         jiggleRotation: Float,
                                         weightDepthIndex: Int,
                                         guideCount: Int,
                                         lineThicknessType: RenderLineThicknessType,
                                         lineThicknessStroke: Float,
                                         lineThicknessFill: Float) {
        
        if isJiggleFrozen || isGuideFrozen {
            solidLineBufferRegularStroke.rgba = RTJ.strokeDis(isDarkMode: isDarkMode)
            solidLineBufferRegularFill.rgba = RTJ.fillDis(isDarkMode: isDarkMode)
        } else {
            
            let isSelected = (isJiggleSelected && isGuideSelected)
            
            let creatorModeFormat: BorderCreatorModeFormat
            switch creatorMode {
            case .none:
                creatorModeFormat = .regular
            case .makeJiggle:
                creatorModeFormat = .alternative
            case .drawJiggle:
                creatorModeFormat = .alternative
            case .addJigglePoint:
                creatorModeFormat = .alternative
            case .removeJigglePoint:
                creatorModeFormat = .alternative
            case .makeGuide:
                creatorModeFormat = .regular
            case .drawGuide:
                creatorModeFormat = .regular
            case .addGuidePoint:
                if isSelected {
                    creatorModeFormat = .regular
                } else {
                    creatorModeFormat = .alternative
                }
            case .removeGuidePoint:
                creatorModeFormat = .regular
            case .moveJiggleCenter:
                creatorModeFormat = .alternative
            case .moveGuideCenter:
                creatorModeFormat = .alternative
            }
            
            solidLineBufferRegularBloom.rgba = RTJ.bloom(isDarkMode: isDarkMode)
            
            switch creatorModeFormat {
            case .regular:
                if isJiggleSelected {
                    solidLineBufferRegularStroke.rgba = RTJ.strokeRegSel(isDarkMode: isDarkMode)
                    if isGuideSelected {
                        switch weightMode {
                        case .guides:
                            solidLineBufferRegularFill.rgba = RTJ.fillGrb(isDarkMode: isDarkMode)
                        case .points:
                            solidLineBufferRegularFill.rgba = RTG.fillRegSelUnm(index: weightDepthIndex,
                                                                                isDarkMode: isDarkMode)
                        }
                    } else {
                        solidLineBufferRegularFill.rgba = RTG.fillRegSelUnm(index: weightDepthIndex,
                                                                            isDarkMode: isDarkMode)
                    }
                } else {
                    solidLineBufferRegularStroke.rgba = RTJ.strokeRegUns(isDarkMode: isDarkMode)
                    solidLineBufferRegularFill.rgba = RTG.fillRegUnsUnm(index: weightDepthIndex,
                                                                        isDarkMode: isDarkMode)
                }
                
            case .alternative:
                if isJiggleSelected {
                    solidLineBufferRegularStroke.rgba = RTJ.strokeAltSel(isDarkMode: isDarkMode)
                    solidLineBufferRegularFill.rgba = RTJ.fillAltSelUnm(isDarkMode: isDarkMode)
                } else {
                    solidLineBufferRegularStroke.rgba = RTJ.strokeAltUns(isDarkMode: isDarkMode)
                    solidLineBufferRegularFill.rgba = RTJ.fillAltUnsUnm(isDarkMode: isDarkMode)
                }
            }
        }
        
        
        //solidLineBloomBuffer.rgba = RTJ.bloom(isDarkMode: isDarkMode)
        
        solidLineBufferRegularBloom.removeAll(keepingCapacity: true)
        solidLineBufferRegularBloom.thickness = lineThicknessStroke

        solidLineBufferRegularStroke.removeAll(keepingCapacity: true)
        solidLineBufferRegularStroke.thickness = lineThicknessStroke

        solidLineBufferRegularFill.removeAll(keepingCapacity: true)
        solidLineBufferRegularFill.thickness = lineThicknessFill
        
        
        for guideWeightPointIndex in 0..<guideWeightPointCount {
            let guideWeightPoint = guideWeightPoints[guideWeightPointIndex]
            var point = guideWeightPoint.point
            point = Math.transformPoint(point: point, translation: jiggleCenter, scale: jiggleScale, rotation: jiggleRotation)
            let pointX = point.x
            let pointY = point.y
            solidLineBufferRegularBloom.addPoint(pointX, pointY)
            solidLineBufferRegularStroke.addPoint(pointX, pointY)
            solidLineBufferRegularFill.addPoint(pointX, pointY)
        }
        
        solidLineBufferRegularBloom.generate(scale: worldScaleStandard)
        solidLineBufferRegularStroke.generate(scale: worldScaleStandard)
        solidLineBufferRegularFill.generate(scale: worldScaleStandard)
        
        currentHashSolidLineBufferStandard.change(splineHash: currentHashSpline,
                                                  centerX: center.x,
                                                  centerY: center.y,
                                                  scale: scale,
                                                  rotation: rotation,
                                                  worldScale: worldScaleStandard,
                                                  creatorMode: creatorMode,
                                                  weightMode: weightMode,
                                                  isGuideSelected: isGuideSelected,
                                                  isJiggleSelected: isJiggleSelected,
                                                  isJiggleFrozen: isJiggleFrozen,
                                                  isGuideFrozen: isGuideFrozen,
                                                  isDarkMode: isDarkMode,
                                                  weightDepthIndex: weightDepthIndex,
                                                  guideCount: guideCount,
                                                  jiggleCenterX: jiggleCenter.x,
                                                  jiggleCenterY: jiggleCenter.y,
                                                  jiggleScale: jiggleScale,
                                                  jiggleRotation: jiggleRotation,
                                                  lineThicknessType: lineThicknessType)
        
        if Guide.DEBUG_FLOW {
            print("(FLOW) {W-Ring \(ObjectIdentifier(self))} CRUNCHED Solid Line (Standard): \(currentHashSolidLineBufferStandard)")
        }
    }
    
    func refreshSolidLineBuffersPrecise(worldScalePrecise: Float,
                                        creatorMode: CreatorMode,
                                        weightMode: WeightMode,
                                        isJiggleSelected: Bool,
                                        isGuideSelected: Bool,
                                        isJiggleFrozen: Bool,
                                        isGuideFrozen: Bool,
                                        isDarkMode: Bool,
                                        jiggleCenter: Point,
                                        jiggleScale: Float,
                                        jiggleRotation: Float,
                                        weightDepthIndex: Int,
                                        guideCount: Int,
                                        lineThicknessType: RenderLineThicknessType) {
        
        solidLineBufferPreciseBloom.removeAll(keepingCapacity: true)
        solidLineBufferPreciseBloom.thickness = solidLineBufferRegularBloom.thickness
        solidLineBufferPreciseBloom.rgba = solidLineBufferRegularBloom.rgba
        
        solidLineBufferPreciseStroke.removeAll(keepingCapacity: true)
        solidLineBufferPreciseStroke.thickness = solidLineBufferRegularStroke.thickness
        solidLineBufferPreciseStroke.rgba = solidLineBufferRegularStroke.rgba
        
        solidLineBufferPreciseFill.removeAll(keepingCapacity: true)
        solidLineBufferPreciseFill.thickness = solidLineBufferRegularFill.thickness
        solidLineBufferPreciseFill.rgba = solidLineBufferRegularFill.rgba
        
        for guideWeightPointIndex in 0..<guideWeightPointCount {
            let guideWeightPoint = guideWeightPoints[guideWeightPointIndex]
            var point = guideWeightPoint.point
            //point = jiggle.transformPoint(point: point)
            point = Math.transformPoint(point: point, translation: jiggleCenter, scale: jiggleScale, rotation: jiggleRotation)
            
            
            let pointX = point.x
            let pointY = point.y
            solidLineBufferPreciseBloom.addPoint(pointX, pointY)
            solidLineBufferPreciseStroke.addPoint(pointX, pointY)
            solidLineBufferPreciseFill.addPoint(pointX, pointY)
        }
        
        
        solidLineBufferPreciseBloom.generate(scale: worldScalePrecise)
        solidLineBufferPreciseStroke.generate(scale: worldScalePrecise)
        solidLineBufferPreciseFill.generate(scale: worldScalePrecise)
        
        currentHashSolidLineBufferPrecise.change(splineHash: currentHashSpline,
                                                 centerX: center.x,
                                                 centerY: center.y,
                                                 scale: scale,
                                                 rotation: rotation,
                                                 worldScale: worldScalePrecise,
                                                 creatorMode: creatorMode,
                                                 weightMode: weightMode,
                                                 isGuideSelected: isGuideSelected,
                                                 isJiggleSelected: isJiggleSelected,
                                                 isJiggleFrozen: isJiggleFrozen,
                                                 isGuideFrozen: isGuideFrozen,
                                                 isDarkMode: isDarkMode,
                                                 weightDepthIndex: weightDepthIndex,
                                                 guideCount: guideCount,
                                                 jiggleCenterX: jiggleCenter.x,
                                                 jiggleCenterY: jiggleCenter.y,
                                                 jiggleScale: jiggleScale,
                                                 jiggleRotation: jiggleRotation,
                                                 lineThicknessType: lineThicknessType)
        
        if Guide.DEBUG_FLOW {
            print("(FLOW) {W-Ring \(ObjectIdentifier(self))} CRUNCHED Solid Line (Precise): \(currentHashSolidLineBufferPrecise)")
        }
        
    }
    
    private func applySolidLineFillColor_Selected(guideCount: Int, weightDepthIndex: Int, isDarkMode: Bool) {
        
    }
    
    private func applySolidLineFillColor_Unselected(guideCount: Int, weightDepthIndex: Int, isDarkMode: Bool) {
        
    }
    
}
