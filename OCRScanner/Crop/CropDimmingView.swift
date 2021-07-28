//
//  CropDimmingView.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/01.
//

import UIKit

class CropDimmingView: UIVisualEffectView {
    init() {
        let blur = UIBlurEffect(style: .dark)
        
        super.init(effect: blur)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMask(_ maskingView: UIView) {
        let mutablePath = CGMutablePath()
        mutablePath.addRect(bounds)
        mutablePath.addRect(maskingView.frame)
        
        let mask = CAShapeLayer()
        mask.path = mutablePath
        mask.fillRule = .evenOdd
        
        layer.mask = mask
    }
}
