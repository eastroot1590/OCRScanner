//
//  OCRToolPicker.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/28.
//

import Foundation
import UIKit

enum OCRTool: String {
    case MLVision
    case Tesseract
    case Kakao
}

class OCRToolPicker: UIPickerView {
    var ocrTool: OCRTool = .Kakao
    
    var scanner: OCRScanner {
        switch ocrTool {
        case .Kakao:
            return KakaoOCRScanner()
            
        case .MLVision:
            return MLVisionOCRScanner()

        case .Tesseract:
            return TesseractOCRScanner()
        }
    }
    
    private let ocrTools: [OCRTool] = [.Kakao, .MLVision, .Tesseract]
    
    init() {
        super.init(frame: .zero)
        
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OCRToolPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ocrTools.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < ocrTools.count else {
            return nil
        }
        
        return ocrTools[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < ocrTools.count else {
            return
        }
        
        ocrTool = ocrTools[row]
    }
}
