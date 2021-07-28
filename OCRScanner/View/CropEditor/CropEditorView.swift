//
//  CropEditorView.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/06/30.
//

import UIKit

class CropEditorView: UIView {
    var cropRect: CropRectView!
    
    var scrollView: UIScrollView!
    var dimmingView: MaskableVisualEffectView!
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        
        scrollView = UIScrollView(frame: frame)
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        scrollView.maximumZoomScale = 3.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
        
        imageView = UIImageView(frame: CGRect(origin: .zero, size: frame.size))
        imageView.backgroundColor = .blue
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        scrollView.contentSize = CGSize(width: frame.width, height: frame.height)
        
        dimmingView = MaskableVisualEffectView()
        dimmingView.frame = frame
        dimmingView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        addSubview(dimmingView)

        cropRect = CropRectView(frame: frame)
        cropRect.delegate = self
        cropRect.dimmingView = dimmingView
        addSubview(cropRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let edge = cropRect.hitTest(convert(point, to: cropRect), with: event) as? CropRectHandle {
            return edge
        } else {
            return scrollView
        }
    }
    
    func setImage(_ image: UIImage) {
        scrollView.layoutIfNeeded()
        
        imageView.image = image
        
        // calculate imageView frame
        let imageScale = cropRect.initialFrame.width / image.size.width
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: image.size.width * imageScale, height: image.size.height * imageScale))
        scrollView.contentSize = imageView.frame.size
    }
    
    func croppedImage() -> UIImage? {
        guard let image = imageView.image else {
            return nil
        }
        
        let scrollScale = scrollView.zoomScale
        let imageScale = image.size.width / cropRect.initialFrame.width
        
        var origin: CGPoint = CGPoint(x: cropRect.frame.origin.x + scrollView.contentOffset.x, y: cropRect.frame.origin.y + scrollView.contentOffset.y)
        origin.x *= imageScale / scrollScale
        origin.y *= imageScale / scrollScale
        
        let size: CGSize = CGSize(width: cropRect.frame.width * imageScale / scrollScale, height: cropRect.frame.height * imageScale / scrollScale)
        
        let cropTargetRect: CGRect = CGRect(origin: origin, size: size)
        
        return image.rotatedImageWithtransform(.identity, croppedTo: cropTargetRect)
    }
}

extension CropEditorView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

extension CropEditorView: CropRectDelegate {
    func cropRect(didBeginEditing rect: CGRect) {
        UIView.animate(withDuration: 0.2, animations: {
            self.dimmingView.alpha = 0.5
        })
    }
    
    func cropRect(editing rect: CGRect) {
        
    }
    
    func cropRect(didChange rect: CGRect) {
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.contentInset = UIEdgeInsets(top: rect.minY - self.scrollView.safeAreaInsets.top,
                                                        left: rect.minX,
                                                        bottom: self.frame.height - rect.maxY - self.scrollView.safeAreaInsets.bottom,
                                                        right: self.frame.width - rect.maxX)
            self.dimmingView.alpha = 1
        })
    }
}
