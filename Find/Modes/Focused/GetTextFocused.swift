//
//  GetTextClassic.swift
//  Find
//
//  Created by Andrew on 10/15/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit

extension ViewController {
    func getTextFocused(stringToFind: String, component: Component, alternate: Bool) {
        let point = CGPoint(x: component.x, y: component.y)
        //print("point is \(point)")
        var newPoint = CGPoint()
        newPoint.x = extentOfPerspectiveImage.width * point.x
        newPoint.y = extentOfPerspectiveImage.height - (extentOfPerspectiveImage.height * point.y)
        
        if let theAnchor = detectedPlanes[blueNode] {
            referenceImageSizeInRealWorld = theAnchor.referenceImage.physicalSize
        }
        
        let width = component.width
        let height = component.height
        let realWidth = width * extentOfPerspectiveImage.width
        let realHeight = height * extentOfPerspectiveImage.height
        
        let textWidth = realWidth / CGFloat(component.text.count)
        let wordWidth = CGFloat(stringToFind.count) * textWidth
        let textHeight = CGFloat(realHeight * 0.8)
        
        let focusSizeRatio = focusImageSize.width / focusImageSize.height
       var realWorldShouldBeWidth = focusSizeRatio * referenceImageSizeInRealWorld.height
       
       let relativePointRatioX = point.x / focusImageSize.width
       let relativePointRatioY = point.y / focusImageSize.height
       newPoint.x = relativePointRatioX * realWorldShouldBeWidth
       newPoint.y = relativePointRatioY * referenceImageSizeInRealWorld.height
       let relativeWidth = width / focusImageSize.width
       let newFocusWidth = relativeWidth * realWorldShouldBeWidth
       
       let relativeHeight = height / focusImageSize.height
       let newFocusHeight = relativeHeight * referenceImageSizeInRealWorld.height
                       
        let focusTextWidth = newFocusWidth / CGFloat(component.text
            .count)
                       let focusWordWidth = CGFloat(stringToFind.count) * focusTextWidth
                       let focusTextHeight = CGFloat(newFocusHeight * 0.8)
        
        let realComponentWidth = component.width * deviceSize.width
        let realComponentHeight = component.height * deviceSize.height
        let individualCharacterWidth = realComponentWidth / CGFloat(component.text.count)
    
        //print("NEWpoint is \(newPoint)")
        let indicies = component.text.indicesOf(string: stringToFind)
        if indicies.count >= 0 {
            var amountOfMatches: Int = 0
            
            for index in indicies {
                let finalPoint = CGPoint(x: newPoint.x + individualCharacterWidth, y: newPoint.y)
                let addedWidth = CGFloat(index) * individualCharacterWidth
        //        let results = sceneView.hitTest(finalPoint, types: .existingPlaneUsingExtent)
                
               // if let hitResult = results.first {
                    print("asdfsgdsgs")
                    let realTextWidth = (individualCharacterWidth * CGFloat(stringToFind.count)) / CGFloat(2000)
                    
                    let highlight = SCNBox(width: realTextWidth, height: 0.001, length: realComponentHeight / 2000, chamferRadius: 0.001)
                    
//                    let sizeForHighlight = CGSize(width: realComponentWidth/2000, height: realComponentHeight/2000)
//                    let highlight = makeHighlightShape(size: sizeForHighlight)
                    let material = SCNMaterial()
                    let highlightColor : UIColor = #colorLiteral(red: 0, green: 0.7389578223, blue: 0.9509587884, alpha: 1)
                    material.diffuse.contents = highlightColor.withAlphaComponent(0.95)
                    highlight.materials = [material]
                     let node = SCNNode(geometry: highlight)
                
                   node.position.y += Float(newPoint.x)
                    node.position.x += Float(newPoint.y)
                    node.eulerAngles.x = -.pi/2
//                    let billboardConstraint = SCNBillboardConstraint()
//                    billboardConstraint.freeAxes = [.Y]
//                    node.constraints = [billboardConstraint]
                    focusHasFoundOne = true
                blueNode.addChildNode(node)
                    amountOfMatches += 1
                    if matchesCanAcceptNewValue == true {
                        DispatchQueue.main.async {
                            self.numberLabel.text = "\(amountOfMatches)"
                        }
                    }
                    if alternate == true {
                        //print("normal---------")
                        focusHighlightArray.append(node)
                        let action = SCNAction.fadeOpacity(to: 0.8, duration: 0.3)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                node.runAction(action)
                            }
                        
                    } else {
                        //print("alternate-------")
                        secondFocusHighlightArray.append(node)
                        let action = SCNAction.fadeOpacity(to: 0.8, duration: 0.3)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                node.runAction(action)
                            }
                    }
                    fadeHighlights()
                //}
            }
        }
        
    }
}
