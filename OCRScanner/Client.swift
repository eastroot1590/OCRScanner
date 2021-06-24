//
//  Client.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/06/23.
//

import Foundation

class Client {
    func requestServer<T>(_ urlString: String, parameter: Data?, responseType: T.Type, completed: @escaping (T?) -> Void) where T: Decodable {
        guard let url = URL(string: urlString),
              let binaryData = parameter else {
            return
        }
        
        print("size: \(binaryData.count / 1024)kb")

        let boundary: String = "\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("KakaoAK d3b2600cde6dd3962333c2568c96b29b", forHTTPHeaderField: "Authorization")

        // multipart/form-data format
        var body: Data = Data()
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"sample.jpeg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(binaryData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data,
                  let result = try? JSONDecoder().decode(T.self, from: data) else {
                return
            }
            
            DispatchQueue.main.async {
                completed(result)
            }
        }).resume()
    }
}
