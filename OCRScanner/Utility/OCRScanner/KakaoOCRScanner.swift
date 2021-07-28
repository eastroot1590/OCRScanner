//
//  KakaoOCRScanner.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/28.
//

import UIKit

struct KakaoResponse: Decodable {
    struct OCRResult: Decodable {
        let boxes: [[Int]]
        let recognition_words: [String]
    }
    
    let result: [OCRResult]
}

class KakaoOCRScanner: OCRScanner {
    func requestOCR(with sourceImage: UIImage, completed: @escaping ([OCRResult]?) -> Void) {
        guard let url = URL(string: "https://dapi.kakao.com/v2/vision/text/ocr"),
              let imageBinary = sourceImage.jpegData(compressionQuality: 1),
              let apiKey = Bundle.main.object(forInfoDictionaryKey: "Kakao API Key") as? String else {
            return
        }
        
        print("size: \(imageBinary.count / 1024)kb")

        let boundary: String = "\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")

        // multipart/form-data format
        var body: Data = Data()
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"sample.jpeg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageBinary)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data,
                  let result = try? JSONDecoder().decode(KakaoResponse.self, from: data) else {
                completed(nil)
                return
            }
            
            var ocrResults: [OCRResult] = []

            for block in result.result {
                var word: String = ""
                
                for recognitionWord in block.recognition_words {
                    word.append(recognitionWord)
                }
                
                let box = Rectangle(lt: CGPoint(x: CGFloat(block.boxes[0][0]), y: CGFloat(block.boxes[0][1])),
                                    rt: CGPoint(x: CGFloat(block.boxes[1][0]), y: CGFloat(block.boxes[1][1])),
                                    rb: CGPoint(x: CGFloat(block.boxes[2][0]), y: CGFloat(block.boxes[2][1])),
                                    lb: CGPoint(x: CGFloat(block.boxes[3][0]), y: CGFloat(block.boxes[3][1])))
                
                ocrResults.append(OCRResult(word: word, box: box))
            }
            
            DispatchQueue.main.async {
                completed(ocrResults)
            }
        }).resume()
    }
}
