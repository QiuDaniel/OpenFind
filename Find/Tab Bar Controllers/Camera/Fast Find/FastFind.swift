//
//  FastFind.swift
//  Find
//
//  Created by Andrew on 12/21/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import Vision

extension CameraViewController {
    
    func fastFind(in pixelBuffer: CVPixelBuffer? = nil, orIn cgImage: CGImage? = nil) {
        
        /// busy finding
        busyFastFinding = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            if let pixelBuffer = pixelBuffer {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let width = ciImage.extent.width
                let height = ciImage.extent.height
                
                self.aspectRatioWidthOverHeight = height / width ///opposite
            } else if let cgImage = cgImage {
                self.howManyTimesFastFoundSincePaused += 1
                
                let width = cgImage.width
                let height = cgImage.height
                
                self.aspectRatioWidthOverHeight = CGFloat(width) / CGFloat(height)
            }
            
            let request = VNRecognizeTextRequest { request, error in
                self.handleFastDetectedText(request: request, error: error)
            }
            
            var customFindArray = [String]()
            for list in self.selectedLists {
                for cont in list.contents {
                    customFindArray.append(cont)
                    customFindArray.append(cont.lowercased())
                    customFindArray.append(cont.uppercased())
                    customFindArray.append(cont.capitalizingFirstLetter())
                }
            }
            
            request.customWords = [self.finalTextToFind, self.finalTextToFind.lowercased(), self.finalTextToFind.uppercased(), self.finalTextToFind.capitalizingFirstLetter()] + customFindArray
            
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["en_GB"]
            
            
            if let pixelBuffer = pixelBuffer {
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
                do {
                    try imageRequestHandler.perform([request])
                } catch let error {
                    self.busyFastFinding = false
                    print("Error: \(error)")
                }
            } else if let cgImage = cgImage {
                let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
                do {
                    try imageRequestHandler.perform([request])
                } catch let error {
                    self.busyFastFinding = false
                    print("Error: \(error)")
                }
            }
        }
    }
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
