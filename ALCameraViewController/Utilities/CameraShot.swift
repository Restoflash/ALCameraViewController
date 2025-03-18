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
    
    // Always force portrait orientation for the captured image regardless of input orientation
    videoConnection.videoOrientation = .portrait
    
    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { buffer, error in
        
        guard let buffer = buffer,
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
            var image = UIImage(data: imageData) 
        else {
            completion(nil)
            return
        }
        
        if let cgImage = image.cgImage {
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
        
         if cameraPosition == .front, let cgImage = image.cgImage {
            switch image.imageOrientation {
            case .leftMirrored:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
            case .left:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .rightMirrored)
            case .rightMirrored:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .left)
            case .right:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
            case .up:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .upMirrored)
            case .upMirrored:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
            case .down:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .downMirrored)
            case .downMirrored:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .down)
            @unknown default:
                break
            }
        }
        
        completion(image)
    })
}
