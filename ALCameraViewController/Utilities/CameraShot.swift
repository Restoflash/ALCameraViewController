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
        
        completion(fixOrientation(img: image))
    })
}

func fixOrientation(img: UIImage) -> UIImage {
    guard img.imageOrientation != .up else { return img }
    
    var transform = CGAffineTransform.identity
    let width = img.size.width, height = img.size.height
    
    switch img.imageOrientation {
    case .down, .downMirrored:
        transform = transform.translatedBy(x: width, y: height)
        transform = transform.rotated(by: .pi)
    case .left, .leftMirrored:
        transform = transform.translatedBy(x: width, y: 0)
        transform = transform.rotated(by: .pi/2)
    case .right, .rightMirrored:
        transform = transform.translatedBy(x: 0, y: height)
        transform = transform.rotated(by: -.pi/2)
    default:
        break
    }
    
    switch img.imageOrientation {
    case .upMirrored, .downMirrored:
        transform = transform.translatedBy(x: width, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    case .leftMirrored, .rightMirrored:
        transform = transform.translatedBy(x: height, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    default:
        break
    }
    
    guard let cgImg = img.cgImage,
          let ctx = CGContext(data: nil,
                              width: Int(width),
                              height: Int(height),
                              bitsPerComponent: cgImg.bitsPerComponent,
                              bytesPerRow: 0,
                              space: cgImg.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: cgImg.bitmapInfo.rawValue)
    else { return img }
    
    ctx.concatenate(transform)
    switch img.imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
        ctx.draw(cgImg, in: CGRect(x: 0, y: 0, width: height, height: width))
    default:
        ctx.draw(cgImg, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    if let cgimg = ctx.makeImage() {
        return UIImage(cgImage: cgimg)
    }
    return img
}
