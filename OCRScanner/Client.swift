//
//  Client.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/06/23.
//

import Foundation
import Alamofire

class Client {
    func requestServer<T>(_ urlString: String, parameter: Data?, responseType: T.Type, completed: @escaping (T?) -> Void) where T: Decodable {
        guard let url = URL(string: urlString),
              let binaryData = parameter else {
            return
        }
        
        print("size: \(binaryData.count / 1024)kb")
        
        var headers: HTTPHeaders = HTTPHeaders.default
        headers.update(.accept("*/*"))
        headers.update(.contentType("multipart/form-data"))
        headers.update(.authorization("KakaoAK d3b2600cde6dd3962333c2568c96b29b"))
        
        Session.default.upload(multipartFormData: { formdata in
            formdata.append(binaryData, withName: "image", fileName: "sample.jpeg", mimeType: "image/jpeg")
            
        }, to: url, method: .post, headers: headers).responseJSON { response in
            
            print(response.debugDescription)
            if let error = response.error {
                debugPrint(error)
                return
            }
            
            guard let data = response.data,
                  let result = try? JSONDecoder().decode(T.self, from: data) else {
                print("decode fail")
                return
            }
            
            completed(result)
        }
    }
    
    private func createBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    private func createBody(parameters: [String: String], data: Data, boundary: String, filename: String) -> Data {
        var body = Data()
        
        guard let boundaryPrefix = "--\(boundary)\r\n".data(using: .utf8) else {
            print("바운더리도 못만듦")
            return body
        }
        
        for parameter in parameters {
            body.append(boundaryPrefix)
            body.append("Content-Disposition: form-data; name=\"\(parameter.key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(parameter.value)\r\n".data(using: .utf8)!)
        }
        
        body.append(boundaryPrefix)
        body.append("Content-Disposition: form-data; name=\"body.image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
//        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--".data(using: .utf8)!)
        
        return body as Data
    }
}
