//
//  ViewController.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit
import Vision
import AVFoundation

protocol ChangeStatusValue: class {
    func changeValue(to value: CGFloat)
}

class CameraView: UIView {
    
var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    guard let layer = layer as? AVCaptureVideoPreviewLayer else {
        fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
    }
    return layer
}
var session: AVCaptureSession? {
    get {
        return videoPreviewLayer.session
    }
    set {
        videoPreviewLayer.session = newValue
    }
}
// MARK: UIView
override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
}
}
class ViewController: UIViewController {
    
    @IBOutlet weak var darkBlurEffect: UIVisualEffectView!
    @IBOutlet weak var darkBlurEffectHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var menuButton: JJFloatingActionButton!
    @IBOutlet weak var newShutterButton: NewShutterButton!
    
    
    //MARK: Toolbar
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var autoCompleteButton: UIButton!
    @IBOutlet weak var cancelButtonNew: UIButton!
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.ramReel.textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        }, completion: { _ in
            self.ramReel.textField.text = ""
            self.ramReel.textField.textColor = UIColor.white
        })
        view.endEditing(true)
    }
    @IBAction func autocompButtonPressed(_ sender: UIButton) {
        if let selectedItem = ramReel.wrapper.selectedItem {
            ramReel.textField.text = nil
            ramReel.textField.insertText(selectedItem.render())
            view.endEditing(true)
        }
    }
    
    //MARK: Matches HUD
    
    var previousNumberOfMatches: Int = 0
    var shouldScale = true
    var currentNumber = 0
    var startGettingNearestFeaturePoints = false
    let fastSceneConfiguration = AROrientationTrackingConfiguration()
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    weak var changeDelegate: ChangeStatusValue?
    
    var blurView = UIVisualEffectView()
    ///Detect if the view controller attempted to dismiss, but didn't
    var hasStartedDismissing = false
    var cancelSeconds = 0
    var cancelTimer : Timer?
    //var isCancelTimerRunning = false //This will be used to make sure only one timer is created at a time.
    
    
    //MARK: FAST MODE
//    enum FastFinding {
//        case busy
//        case notBusy
//        case inactive
//    }
    var busyFastFinding = false
    var startFastFinding = false
    var tempComponents = [Component]()
    var currentComponents = [Component]()
    var nextComponents = [Component]()
    var numberOfFastMatches: Int = 0

    var aspectRatioWidthOverHeight : CGFloat = 0
    var aspectRatioSucceeded : Bool = false
    var sizeOfPixelBufferFast : CGSize = CGSize(width: 0, height: 0)
    
    //MARK: Every mode (Universal)
    var statusBarHidden : Bool = false
    //var scanModeToggle = CurrentModeToggle.fast
    var finalTextToFind : String = ""
    let deviceSize = UIScreen.main.bounds.size
    
    ///Save the image
    var globalUrl : URL = URL(fileURLWithPath: "")
    
    
    //MARK: Ramreel
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    
    let data: [String] = {
        do {
            guard let dataPath = Bundle.main.path(forResource: "data", ofType: "txt") else {
                return []
            }
            
            let data = try WordReader(filepath: dataPath)
            return data.words
        }
        catch let error {
            print(error)
            return []
        }
    }()
    
    //MARK: New Camera no Sceneview
    let avSession = AVCaptureSession()
    var snapshotImageOrientation = UIImage.Orientation.upMirrored
    private var captureCompletionBlock: ((UIImage) -> Void)?
    
    @IBOutlet weak var cameraView: CameraView!
    let videoDataOutput = AVCaptureVideoDataOutput()
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
       guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
           return nil
       }
       CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
       let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
       let width = CVPixelBufferGetWidth(pixelBuffer)
       let height = CVPixelBufferGetHeight(pixelBuffer)
       let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
       let colorSpace = CGColorSpaceCreateDeviceRGB()
       let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
       guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
           return nil
       }
       guard let cgImage = context.makeImage() else {
           return nil
       }
       let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
       CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    private func getCamera() -> AVCaptureDevice? {
        if let cameraDevice = AVCaptureDevice.default(.builtInDualCamera,
                                                for: .video, position: .back) {
            return cameraDevice
        } else if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video, position: .back) {
            return cameraDevice
        } else {
            fatalError("Missing expected back camera device.")
            //return nil
        }
    }
    private func configureCamera() {
        cameraView.session = avSession
        let cameraDevice = getCamera()
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
            if avSession.canAddInput(captureDeviceInput) {
                avSession.addInput(captureDeviceInput)
            }
        }
        catch {
            print("Error occured \(error)")
            return
        }
        avSession.sessionPreset = .high
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        if avSession.canAddOutput(videoDataOutput) {
            avSession.addOutput(videoDataOutput)
        }
        cameraView.videoPreviewLayer.videoGravity = .resizeAspect
        cameraView.videoPreviewLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        DispatchQueue.main.async {
            self.cameraView.videoPreviewLayer.frame = self.view.bounds
        }
        avSession.startRunning()
    }
    private func isAuthorized() -> Bool {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                          completionHandler: { (granted:Bool) -> Void in
                                            if granted {
                                                DispatchQueue.main.async {
                                                   // self.configureTextDetection()
                                                    self.configureCamera()
                                                }
                                            }
            })
            return true
        case .authorized:
            return true
        case .denied, .restricted: return false
        }
    }
    func capturePhoto(completion: ((UIImage) -> Void)?) {
        captureCompletionBlock = completion
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        changeDelegate = statusView as? ChangeStatusValue
        numberLabel.isHidden = false
        updateMatchesNumber(to: 0)
       
        setUpButtons()
        setUpTimers()
        setUpRamReel()
        setUpFilePath()
        if isAuthorized() {
            configureCamera()
        }
        busyFastFinding = false
        print("resume?")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //classicHasFoundOne = false
        print("diss")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


}



extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Camera Delegate and Setup
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if busyFastFinding == false {
            fastFind(in: pixelBuffer)
        }
        guard captureCompletionBlock != nil,
            let outputImage = UIImage(pixBuffer: pixelBuffer) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let captureCompletionBlock = self.captureCompletionBlock {
                //print("askdh")
                captureCompletionBlock(outputImage)
                //AudioServicesPlayAlertSound(SystemSoundID(1108))
            }
            self.captureCompletionBlock = nil
        }
        
    }
}
extension UIImage {

    convenience init?(pixBuffer: CVPixelBuffer) {
        var ciImage = CIImage(cvPixelBuffer: pixBuffer)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        let size = ciImage.extent.size

        let screenSize: CGRect = UIScreen.main.bounds
        let imageRect = CGRect(x: screenSize.origin.x, y: screenSize.origin.y, width: size.width, height: size.height)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
