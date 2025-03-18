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
              let image = UIImage(data: imageData)
        else {
            completion(nil)
            return
        }
        
        completion(rotateImageToPortrait(image: image))
    })
}


func rotateImageToPortrait(image: UIImage) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    var transform = CGAffineTransform.identity

    switch image.imageOrientation {
    case .right:
        transform = CGAffineTransform(rotationAngle: -.pi / 2)
    case .left:
        transform = CGAffineTransform(rotationAngle: .pi / 2)
    case .down:
        transform = CGAffineTransform(rotationAngle: .pi)
    default:
        transform = .identity
    }

    // Apply the transform to the image context
    UIGraphicsBeginImageContext(CGSize(width: image.size.height, height: image.size.width))
    if let context = UIGraphicsGetCurrentContext() {
        context.translateBy(x: image.size.height / 2, y: image.size.width / 2)
        context.rotate(by: transform.a)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
    }

    let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return rotatedImage
}
