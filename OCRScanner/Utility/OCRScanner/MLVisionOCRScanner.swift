//
//  MLVisionOCRScanner.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/28.
//

import UIKit
import FirebaseMLVision

class MLVisionOCRScanner: OCRScanner {
    func requestOCR(with sourceImage: UIImage, completed: @escaping ([OCRResult]?) -> Void) {
        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "ko"]
        
        let textRecognizer = vision.cloudTextRecognizer(options: options)
        textRecognizer.process(VisionImage(image: sourceImage)) { result, error in
            if let error = error {
                debugPrint(error)
            }
            
            guard let result = result else {
                completed(nil)
                return
            }
            
            var ocrResult: [OCRResult] = []
            
            for block in result.blocks {
                let word = block.text
                let box = Rectangle(rect: block.frame)
                
                ocrResult.append(OCRResult(word: word, box: box))
            }

            completed(ocrResult)
        }
    }
}
