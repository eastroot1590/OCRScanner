//
//  CropEdge.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/01.
//

import UIKit

protocol CropEdgeDelegate {
    func edge(_ edge: CropEdge, didBeginEditing editing: Bool)
    func edge(_ edge: CropEdge, delta: CGPoint)
    func edge(_ edge: CropEdge, didEndEditing editing: Bool)
}

class CropEdge: UIView {
    enum EditingEdge {
        case left
        case top
        case right
        case bottom
    }
    
    let edge: EditingEdge
    var delegate: CropEdgeDelegate?
    
    var editingBegin: CGPoint = .zero

    init(_ edge: EditingEdge) {
        self.edge = edge
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout(_ frame: CGRect) {
        var edgeFrame: CGRect = .zero
        
        switch self.edge {
        case .left:
            edgeFrame.origin = CGPoint(x: frame.minX - 5, y: frame.height / 2 - 25)
            edgeFrame.size = CGSize(width: 10, height: 50)
            
        case .right:
            edgeFrame.origin = CGPoint(x: frame.maxX - 5, y: frame.height / 2 - 25)
            edgeFrame.size = CGSize(width: 10, height: 50)
        
        case .top:
            edgeFrame.origin = CGPoint(x: frame.width / 2 - 25, y: frame.minY - 5)
            edgeFrame.size = CGSize(width: 50, height: 10)
            
        case .bottom:
            edgeFrame.origin = CGPoint(x: frame.width / 2 - 25, y: frame.maxY - 5)
            edgeFrame.size = CGSize(width: 50, height: 10)
        }
        
        self.frame = edgeFrame
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let state = recognizer.state
        let point = recognizer.translation(in: self)
        
        switch state {
        case .began:
            editingBegin = point
            delegate?.edge(self, didBeginEditing: true)
            
        case .changed:
            let delta: CGPoint = CGPoint(x: editingBegin.x - point.x, y: editingBegin.y - point.y)
            delegate?.edge(self, delta: delta)
            
        case .cancelled:
            delegate?.edge(self, didEndEditing: true)
            
        case .ended:
            delegate?.edge(self, didEndEditing: true)
            
        default:
            break
        }
    }
}
