//
//  ZoomView.swift
//  Camera
//
//  Created by Zheng on 11/19/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct DotSpacerView: View {
    var numberOfDots: Int
    var body: some View {
        Color.clear.overlay(
            HStack(spacing: 0) {
                ForEach(0..<numberOfDots, id: \.self) { _ in
                    HStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
                .drawingGroup()
                .opacity(0.5)
        )
            .clipped()
    }
}


struct ZoomFactorView: View {
    @ObservedObject var zoomViewModel: ZoomViewModel
    let draggingAmount: CGFloat
    let zoomFactor: ZoomFactor
    let index: Int
    
    @GestureState private var isTapped = false
    
    var body: some View {
        let isActive = zoomFactor.zoomRange.contains(zoomViewModel.zoom)
        
        /// projection
        Button(action: activate) {
            ZoomFactorContent(
                zoomViewModel: zoomViewModel,
                index: index,
                text: isActive ? zoomViewModel.zoom.string : zoomFactor.zoomRange.lowerBound.string
            )
        }
        .disabled(isActive || !zoomViewModel.allowingButtonPresses) /// only press-able when not already pressed
        .scaleEffect(
            zoomViewModel.isExpanded && !isActive ?
            zoomViewModel.getActivationProgress(for: zoomFactor, draggingAmount: draggingAmount)
            : 1
        )
        .scaleEffect(isActive ? 1 : 0.7)
        .offset(x: zoomViewModel.isExpanded && isActive ? zoomViewModel.activeZoomFactorOffset(for: zoomFactor, draggingAmount: draggingAmount) : 0, y: 0)
        .background(
            Button(action: activate) {
                ZoomFactorContent(
                    zoomViewModel: zoomViewModel,
                    index: index,
                    text: zoomFactor.zoomRange.lowerBound.string
                )
            }
                .scaleEffect(zoomViewModel.getActivationProgress(for: zoomFactor, draggingAmount: draggingAmount))
                .scaleEffect(0.7)
                .opacity(isActive && zoomViewModel.isExpanded ? 1 : 0) /// show when passed preset and dragging left, increasing zoom value
                .disabled(!zoomViewModel.allowingButtonPresses)
        )
    }
    
    func activate() {
        withAnimation {
            zoomViewModel.zoom = zoomFactor.zoomRange.lowerBound
            zoomViewModel.savedExpandedOffset = -zoomFactor.positionRange.lowerBound * zoomViewModel.sliderWidth
            zoomViewModel.isExpanded = false
            zoomViewModel.keepingExpandedUUID = nil
        }
    }
}

struct ZoomFactorContent: View {
    @ObservedObject var zoomViewModel: ZoomViewModel
    let index: Int
    let text: String
    
    var body: some View {
        ZStack {
            Color(UIColor(hex: 0x002F3B))
                .opacity(0.8)
                .cornerRadius(24)
            
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: C.zoomFactorLength, height: C.zoomFactorLength)
    }
}



struct ZoomView: View {
    
    @ObservedObject var zoomViewModel: ZoomViewModel
    @GestureState var draggingAmount = CGFloat(0)
    
    
    var body: some View {
        Color.green.overlay(
            Color(UIColor(hex: 0x002F3B))
                .opacity(0.25)
                .frame(width: zoomViewModel.isExpanded ? nil : C.zoomFactorLength * 3 + C.edgePadding * 2, height: C.zoomFactorLength + C.edgePadding * 2)
                .overlay(
                    
                    HStack(spacing: 0) {
                        ForEach(C.zoomFactors.indices, id: \.self) { index in
                            let zoomFactor = C.zoomFactors[index]
                            
                            
                            ZoomFactorView(
                                zoomViewModel: zoomViewModel,
                                draggingAmount: draggingAmount,
                                zoomFactor: zoomFactor,
                                index: index
                            )
                                .zIndex(1)
                            
                            DotSpacerView(numberOfDots: Int(zoomViewModel.dotViewWidth(for: zoomFactor)) / 12)
                                .frame(width: zoomViewModel.isExpanded ? zoomViewModel.dotViewWidth(for: zoomFactor) : 0, height: 30)
                                .zIndex(0)
                        }
                    }
                        .frame(width: zoomViewModel.isExpanded ? zoomViewModel.sliderWidth : nil, alignment: .leading)
                        .offset(x: zoomViewModel.isExpanded ? (zoomViewModel.savedExpandedOffset + draggingAmount + zoomViewModel.sliderLeftPadding) : 0, y: 0)
                    , alignment: zoomViewModel.isExpanded ? .leading : .center
                )
                .cornerRadius(50)
                .padding(.horizontal, C.containerEdgePadding)
        )
            .onAppear {
                zoomViewModel.savedExpandedOffset = -C.zoomFactors[1].positionRange.lowerBound * zoomViewModel.sliderWidth
                /// This will be from 0 to 1, from slider leftmost to slider rightmost
                let positionInSlider = zoomViewModel.positionInSlider(draggingAmount: draggingAmount)
                zoomViewModel.setZoom(positionInSlider: positionInSlider)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: zoomViewModel.isExpanded ? 0 : 0.2, maximumDistance: .infinity)
                    .onEnded { _ in
                        print("end..")
                        withAnimation { zoomViewModel.isExpanded = true }
                        //                        zoomViewModel.startTimeout()
                    }
                    .sequenced(
                        before:
                            DragGesture(minimumDistance: 2)
                            .updating($draggingAmount) { value, draggingAmount, transaction in
                                
                                
                                /// temporary stop button presses to prevent conflicts with the gestures
                                DispatchQueue.main.async {
                                    zoomViewModel.allowingButtonPresses = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        zoomViewModel.allowingButtonPresses = true
                                    }
                                }
                                
                                zoomViewModel.update(translation: value.translation.width, draggingAmount: &draggingAmount)
                                
                            }
                            .onEnded { value in
                                if value.translation.width != 0 {
                                    let offset = zoomViewModel.savedExpandedOffset + value.translation.width
                                    if offset >= 0 {
                                        zoomViewModel.savedExpandedOffset = 0
                                    } else if -offset >= zoomViewModel.sliderWidth {
                                        zoomViewModel.savedExpandedOffset = -zoomViewModel.sliderWidth
                                    } else {
                                        zoomViewModel.savedExpandedOffset += value.translation.width
                                    }
                                    
                                    /// This will be from 0 to 1, from slider leftmost to slider rightmost
                                    let positionInSlider = zoomViewModel.positionInSlider(draggingAmount: draggingAmount)
                                    zoomViewModel.setZoom(positionInSlider: positionInSlider)
                                }
                                
                                zoomViewModel.startTimeout()
                            }
                            .simultaneously( /// if the user pressed down and up without dragging
                                with:
                                    TapGesture()
                                    .onEnded { _ in
                                        zoomViewModel.startTimeout()
                                    }
                            )
                    )
            )
    }
}

struct ZoomView_Previews: PreviewProvider {
    static var previews: some View {
        ZoomView(zoomViewModel: ZoomViewModel(containerView: UIView()))
            .frame(maxWidth: .infinity)
            .padding(50)
            .background(Color.gray)
    }
}

