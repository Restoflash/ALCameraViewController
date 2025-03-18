//
//  CameraShot.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

public typealias CameraShotCompletion = (UIImage?) -> Void

public func takePhoto(_ stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cameraPosition: AVCaptureDevice.Position, cropSize: CGSize, completion: @escaping CameraShotCompletion) {
    
    guard let videoConnection: AVCaptureConnection = stillImageOutput.connection(with: AVMediaType.video) else {
        completion(nil)
        return
    }
    
    var image : UIImage? = nil
    
    // Always force portrait orientation for the captured image regardless of input orientation
    videoConnection.videoOrientation = .portrait
    
    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { buffer, error in
        
        guard let buffer = buffer,
              let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
        else {
            completion(nil)
            return
        }
        image = UIImage(data: imageData)
        
        if let cgImage = image!.cgImage {
            // Determine the correct image orientation based on the current device orientation
            
            let deviceOrientation = UIDevice.current.orientation
            let imageOrientation: UIImage.Orientation
            
            switch deviceOrientation {
            case .portrait:
                imageOrientation = .right
            case .portraitUpsideDown:
                imageOrientation = .left
            case .landscapeLeft:
                imageOrientation = .up
            case .landscapeRight:
                imageOrientation = .down
            default:
                imageOrientation = .right
            }
            image = UIImage(cgImage: cgImage, scale: 1.0, orientation: imageOrientation)
        }
    
        
        completion(image)
    })
}
