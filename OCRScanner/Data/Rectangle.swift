//
//  Rectangle.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/28.
//

import UIKit

/// 네개의 꼭지점과 네개의 선분으로 이루어진 2차원 도형
struct Rectangle {
    let lt: CGPoint
    let rt: CGPoint
    let rb: CGPoint
    let lb: CGPoint
    
    init(rect: CGRect) {
        self.lt = CGPoint(x: rect.minX, y: rect.minY)
        self.rt = CGPoint(x: rect.maxX, y: rect.minY)
        self.rb = CGPoint(x: rect.maxX, y: rect.maxY)
        self.lb = CGPoint(x: rect.minX, y: rect.maxY)
    }
    
    init(lt: CGPoint, rt: CGPoint, rb: CGPoint, lb: CGPoint) {
        self.lt = lt
        self.rt = rt
        self.rb = rb
        self.lb = lb
    }
}
