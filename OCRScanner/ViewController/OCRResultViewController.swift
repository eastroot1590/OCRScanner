//
//  OCRResultViewController.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/28.
//

import UIKit

class OCRResultViewController: UIViewController {
    var sourceImage: UIImage
    var results: [OCRResult]
    
    var scale: CGFloat = 0

    init(sourceImage: UIImage, result: [OCRResult]) {
        self.results = result
        self.sourceImage = sourceImage
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        scale = view.frame.width / sourceImage.size.width
        
        // 결과값 추출(박스, 문자열)
        var resultString: String = ""
        let boxLayer = CAShapeLayer()
        boxLayer.fillColor = nil
        
        let path = UIBezierPath()
        
        for result in results {
            if let box = result.box {
                path.move(to: CGPoint(x: box.lt.x * scale , y: box.lt.y * scale))
                path.addLine(to: CGPoint(x: box.rt.x * scale , y: box.rt.y * scale))
                path.addLine(to: CGPoint(x: box.rb.x * scale , y: box.rb.y * scale))
                path.addLine(to: CGPoint(x: box.lb.x * scale , y: box.lb.y * scale))
                path.addLine(to: CGPoint(x: box.lt.x * scale , y: box.lt.y * scale))
            }
            
            if let word = result.word {
                resultString.append("[\(word)] ")
            }
        }
        
        boxLayer.path = path.cgPath
        boxLayer.strokeColor = UIColor.systemGreen.cgColor
        boxLayer.lineWidth = 2
        
        // 사용된 이미지
        let scanImage = UIImageView(image: sourceImage)
        scanImage.layer.addSublayer(boxLayer)
        scanImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanImage)
        NSLayoutConstraint.activate([
            scanImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scanImage.widthAnchor.constraint(equalTo: view.widthAnchor),
            scanImage.heightAnchor.constraint(equalToConstant: sourceImage.size.height * scale)
        ])
        
        // 결과 라벨
        let resultLabel = UILabel()
        resultLabel.text = resultString
        resultLabel.textColor = .label
        resultLabel.numberOfLines = 0
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: scanImage.bottomAnchor, constant: 10),
            resultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            resultLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
    }
}
