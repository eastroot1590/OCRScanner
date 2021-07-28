//
//  CropRectView.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/01.
//

import UIKit

protocol CropRectDelegate {
    func cropRect(didBeginEditing rect: CGRect)
    func cropRect(editing rect: CGRect)
    func cropRect(didChange rect: CGRect)
}

class CropRectView: UIView {
    let padding: CGFloat = 40
    
    var dimmingView: MaskableVisualEffectView?
    let frameLayer = CAShapeLayer()
    
    let topEdge = CropRectHandle(.top)
    let leftEdge = CropRectHandle(.left)
    let rightEdge = CropRectHandle(.right)
    let bottomEdge = CropRectHandle(.bottom)
    
    let initialFrame: CGRect
    var beginFrame: CGRect = .zero
    
    var delegate: CropRectDelegate?
    
    var initialLayout: Bool = false
    
    override init(frame: CGRect) {
        let width = frame.width - padding * 2
        self.initialFrame = CGRect(origin: CGPoint(x: padding, y: frame.height / 2 - width / 2), size: CGSize(width: width, height: width))
        
        super.init(frame: initialFrame)
        
        frameLayer.fillColor = nil
        frameLayer.strokeColor = UIColor.white.cgColor
        frameLayer.lineWidth = 3
        layer.addSublayer(frameLayer)
        
        // edges
        topEdge.delegate = self
        addSubview(topEdge)
        
        leftEdge.delegate = self
        addSubview(leftEdge)
        
        rightEdge.delegate = self
        addSubview(rightEdge)
        
        bottomEdge.delegate = self
        addSubview(bottomEdge)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let framePath = CGPath(rect: bounds, transform: nil)
        frameLayer.path = framePath
        
        topEdge.layout(bounds)
        leftEdge.layout(bounds)
        rightEdge.layout(bounds)
        bottomEdge.layout(bounds)
        
        dimmingView?.setMask(self)
        
        if !initialLayout {
            delegate?.cropRect(didChange: frame)
            initialLayout = true
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews {
            if let edge = subview as? CropRectHandle,
               edge.frame.contains(point) {
                return edge
            }
        }
        
        return nil
    }
}

extension CropRectView: CropRectHandleDelegate {
    func edge(_ edge: CropRectHandle, didBeginEditing editing: Bool) {
        beginFrame = frame
        
        delegate?.cropRect(didBeginEditing: frame)
    }
    
    func edge(_ edge: CropRectHandle, delta: CGPoint) {
        var newFrame = frame
        
        switch edge.edge {
        case .top:
            newFrame = CGRect(origin: CGPoint(x: beginFrame.origin.x, y: beginFrame.origin.y - delta.y), size: CGSize(width: beginFrame.width, height: beginFrame.height + delta.y))
            
        case .left:
            newFrame = CGRect(origin: CGPoint(x: beginFrame.origin.x - delta.x, y: beginFrame.origin.y), size: CGSize(width: beginFrame.width + delta.x, height: beginFrame.height))
            
        case .right:
            newFrame = CGRect(origin: beginFrame.origin, size: CGSize(width: beginFrame.width - delta.x, height: beginFrame.height))
            
        case .bottom:
            newFrame = CGRect(origin: beginFrame.origin, size: CGSize(width: beginFrame.width, height: beginFrame.height - delta.y))
        }
        
        frame = newFrame
    }
    
    func edge(_ edge: CropRectHandle, didEndEditing editing: Bool) {
        delegate?.cropRect(didChange: frame)
    }
}
