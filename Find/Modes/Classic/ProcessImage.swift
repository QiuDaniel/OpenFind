//
//  ProcessImage.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
import ARKit
import Vision

extension ViewController {
    func processImage() {
        guard let capturedImage = sceneView.session.currentFrame?.capturedImage else {
            print("no captured image")
            return
        }
        let requests = [textDetectionRequest]
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: capturedImage, orientation: .right, options: [:])
        DispatchQueue.global().async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                print("Error: \(error)")
            }
        }
        
        
        
        
        
    }
}
