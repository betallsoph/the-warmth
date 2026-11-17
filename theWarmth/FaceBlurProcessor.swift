//
//  FaceBlurProcessor.swift
//  Our Warmth
//
//  Privacy protection: Auto blur faces in photos using Vision Framework
//

import UIKit
import Vision
import CoreImage

class FaceBlurProcessor {
    
    /// Detect faces and apply blur to protect privacy
    static func blurFaces(in image: UIImage, completion: @escaping (UIImage?) -> Void) {
        #if targetEnvironment(simulator)
        // Vision Framework's neural engine not available on simulator
        // Return original image without processing
        print("Face blur disabled on simulator - Vision Framework requires real device")
        completion(image)
        return
        #else

        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }

        // Use a flag to ensure completion is only called once
        var hasCompleted = false
        let completionLock = NSLock()

        func safeComplete(_ result: UIImage?) {
            completionLock.lock()
            defer { completionLock.unlock() }

            guard !hasCompleted else { return }
            hasCompleted = true
            completion(result)
        }

        // Create face detection request
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                print("Face detection error: \(error)")
                safeComplete(image)
                return
            }

            guard let observations = request.results as? [VNFaceObservation],
                  !observations.isEmpty else {
                // No faces detected, return original
                safeComplete(image)
                return
            }

            // Apply blur to each detected face
            let blurredImage = applyBlur(to: ciImage, faces: observations, imageSize: image.size)
            safeComplete(blurredImage)
        }

        // Perform face detection
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([faceDetectionRequest])
            } catch {
                print("Face detection failed: \(error)")
                safeComplete(image)
            }
        }
        #endif
    }
    
    private static func applyBlur(to image: CIImage, faces: [VNFaceObservation], imageSize: CGSize) -> UIImage? {
        let context = CIContext()
        var outputImage = image
        
        // Convert Vision coordinates to CIImage coordinates
        let imageHeight = image.extent.height
        
        for face in faces {
            // Vision uses normalized coords (0-1) with origin at bottom-left
            let boundingBox = face.boundingBox
            
            // Convert to CIImage coordinates
            let x = boundingBox.origin.x * imageSize.width
            let y = (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height
            let width = boundingBox.width * imageSize.width
            let height = boundingBox.height * imageSize.height
            
            // Expand rect slightly to ensure full face coverage
            let expandedRect = CGRect(
                x: max(0, x - width * 0.2),
                y: max(0, y - height * 0.2),
                width: width * 1.4,
                height: height * 1.4
            )
            
            // Apply pixelation for stronger privacy (harder to reverse than blur)
            if let pixelatedFace = pixelateFace(image: outputImage, rect: expandedRect) {
                outputImage = pixelatedFace
            }
        }
        
        // Convert back to UIImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
    }
    
    private static func pixelateFace(image: CIImage, rect: CGRect) -> CIImage? {
        // Crop face region
        let faceImage = image.cropped(to: rect)
        
        // Apply pixelation filter
        guard let pixelFilter = CIFilter(name: "CIPixellate") else { return nil }
        pixelFilter.setValue(faceImage, forKey: kCIInputImageKey)
        pixelFilter.setValue(max(rect.width, rect.height) / 20, forKey: kCIInputScaleKey) // Adjust scale for pixelation
        
        guard let pixelatedFace = pixelFilter.outputImage else { return nil }
        
        // Composite pixelated face back onto original image
        let compositedImage = pixelatedFace.composited(over: image)
        
        return compositedImage
    }
}
