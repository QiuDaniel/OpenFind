//
//  LivePreviewVC+Setup.swift
//  Camera
//
//  Created by Zheng on 11/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

extension LivePreviewViewController {
    
    func configureCamera() {
        if let cameraDevice = getCamera() {
            self.cameraDevice = cameraDevice
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.configureSession()
            }
        } else {
            let fallbackView = FallbackView()
            view.addSubview(fallbackView)
            fallbackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            fallbackView.goToPhotos = { [weak self] in
                self?.findFromPhotosButtonPressed?()
            }
        }
    }
    
    func configureSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
            if session.canAddInput(captureDeviceInput) {
                session.addInput(captureDeviceInput)
            }
        } catch {
            print("Error occurred: \(error)")
            return
        }
        session.sessionPreset = .photo
        videoDataOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(
                label: "Buffer Queue",
                qos: .userInteractive,
                attributes: .concurrent,
                autoreleaseFrequency: .inherit,
                target: nil
            )
        )
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        DispatchQueue.main.async {
            self.livePreviewView.session = self.session
            let viewBounds = self.view.layer.bounds
            self.livePreviewView.videoPreviewLayer.bounds = viewBounds
            self.livePreviewView.videoPreviewLayer.position = CGPoint(x: viewBounds.midX, y: viewBounds.midY)
            self.livePreviewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        }
        
        session.startRunning()
    }
    func getCamera() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .back
        )
        let devices = discoverySession.devices
        //        for device in devices {
        //            print("""
        //            ---> Device \(device.uniqueID):
        //            manufacturer: \(device.manufacturer)
        //            name: \(device.localizedName)
        //            isVirtualDevice: \(device.isVirtualDevice)
        //            connect: \(device.isConnected)
        //            constituentDevices: \(device.constituentDevices)
        //            position: \(device.position)
        //
        //            """
        //            )
        //        }
        
        let bestDevice = devices.first
//        if let b = bestDevice {
//            print("""
//
//                ---> Device \(b.uniqueID):
//                minfocus: \(b.minimumFocusDistance)
//                minzoom: \(b.minAvailableVideoZoomFactor)
//                maxzoo: \(b.maxAvailableVideoZoomFactor)
//                fac: \(b.virtualDeviceSwitchOverVideoZoomFactors)
//                """
//            )
//
//            for device in b.constituentDevices {
//                print("""
//                    --->
//                    lens: \(device.localizedName)
//                    factors \(device.virtualDeviceSwitchOverVideoZoomFactors)
//                    videoZoomFactor \(device.videoZoomFactor)
//                    """
//                )
//            }
//        }
//
        return bestDevice
    }
}
