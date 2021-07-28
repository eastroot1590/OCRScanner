//
//  EditorViewController.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/06/30.
//

import UIKit

protocol MyCropDelegate {
    func cropView(didFinishCropImage image: UIImage)
}

class EditorViewController: UIViewController {
    let editingImage: UIImage
    
    var editor: MyCropView!
    
    var delegate: MyCropDelegate?
    
    init(image: UIImage) {
        editingImage = image
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray
        let backButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancel))
        navigationItem.setLeftBarButton(backButton, animated: true)
        
        title = "크롭크롭"

        editor = MyCropView(frame: view.frame)
        editor.setImage(editingImage)
    
        view.addSubview(editor)
        
        let bottomBar = UIView()
        bottomBar.backgroundColor = .white
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: view.safeAreaInsets.bottom + 100)
        ])
        
        let doneButton = UIButton()
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.setTitle("완료", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.layer.cornerRadius = 5
        bottomBar.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            doneButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 20)
        ])
    }
    
    @objc func done() {
        if let croppedImage = editor.croppedImage() {
            delegate?.cropView(didFinishCropImage: croppedImage)
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

