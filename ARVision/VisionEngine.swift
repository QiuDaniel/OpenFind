//
//  VisionEngine.swift
//  ARVision
//
//  Created by Zheng on 11/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

protocol VisionEngineDelegate: AnyObject {
    func textFound(observations: [VNRecognizedTextObservation])
    func cameraMoved(by translation: CGSize)
}
class VisionEngine {
    
    weak var delegate: VisionEngineDelegate?
    
    let trackingEngine = VisionTrackingEngine()
    let findingEnding = VisionFindingEngine()
    
    
    // MARK: Tracking
    /// not nil if tracking gave an updated rect
    
    var startTime: Date?
    var canFind: Bool {
        var canFind = true
        if findingEnding.startTime != nil {
            print("Currently finding")
            canFind = false
        }
        if !startTime.isPastCoolDown(Constants.findCoolDownTime) {
            print("Still in cooldown!")
            canFind = false
        }
        
        print("Can find? \(canFind)")
        return canFind
    }
    
    func startToFind(_ text: [String], in pixelBuffer: CVPixelBuffer) {
        print("start")
        startTime = Date()
        findingEnding.fastFind(text, in: pixelBuffer) { [weak self] observations in
            guard let self = self else { return }
            self.delegate?.textFound(observations: observations)
            self.trackingEngine.beginTracking(with: pixelBuffer, observations: observations)
        }
        
    }
    func updatePixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        _ = VisionConstants.highlightCandidateAreas
        
        
        let startTime = startTime
        trackingEngine.updateTracking(with: pixelBuffer) { [weak self] translation in

            guard
                let self = self,
                startTime == self.startTime
            else {
                print("start time diff.. \(startTime) vs before \(self?.startTime)")
                return
            }
            self.delegate?.cameraMoved(by: translation)
        }
    }
}
