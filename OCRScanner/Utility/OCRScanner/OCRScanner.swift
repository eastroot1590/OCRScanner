//
//  OCRScanner.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/28.
//

import UIKit

struct OCRResult {
    var word: String?
    var box: Rectangle?
}

protocol OCRScanner {
    func requestOCR(with sourceImage: UIImage, completed: @escaping ([OCRResult]?) -> Void)
}
