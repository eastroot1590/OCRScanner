//
//  MainViewController.swift
//  OCRTutorial
//
//  Created by 이동근 on 2021/06/22.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController {
    let ocrToolPicker = OCRToolPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        title = "Main"
        
        ocrToolPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ocrToolPicker)
        NSLayoutConstraint.activate([
            ocrToolPicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            ocrToolPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let loadPickerButton = UIButton()
        loadPickerButton.backgroundColor = .systemBlue
        loadPickerButton.setTitle("사진 선택", for: .normal)
        loadPickerButton.setTitleColor(.white, for: .normal)
        loadPickerButton.addTarget(self, action: #selector(loadImagePicker), for: .touchUpInside)
        loadPickerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadPickerButton)
        NSLayoutConstraint.activate([
            loadPickerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            loadPickerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadPickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadPickerButton.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func scan(_ sourceImage: UIImage, scanner: OCRScanner) {
        scanner.requestOCR(with: sourceImage) { [weak self] ocrResult in
            guard let ocrResult = ocrResult else {
                return
            }

            let resultViewController = OCRResultViewController(sourceImage: sourceImage, result: ocrResult)
            self?.present(resultViewController, animated: true, completion: nil)
        }
    }
    
    @objc func loadImagePicker() {
        let imagePickerActionSheet = UIAlertController(title: "OCR 스캔하기", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "카메라에서", style: .default) { alert in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "사진에서", style: .default) { alert in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true)
    }
}

// MARK: UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }

        dismiss(animated: true, completion: {
            let editor = CropEditorViewController(image: selectedPhoto)
            editor.delegate = self
            let navigationController = UINavigationController(rootViewController: editor)
            navigationController.modalPresentationStyle = .overFullScreen
            self.present(navigationController, animated: true, completion: nil)
        })
    }
}

// MARK: CropEditorViewControllerDelegate
extension MainViewController: CropEditorViewControllerDelegate {
    func cropEditor(didFinishEdit image: UIImage) {
        guard let scaledImage = image.scaledImage(1024) else {
            print("Failed to scale image.")
            return
        }
        
        print("processing...")
        
        scan(scaledImage, scanner: ocrToolPicker.scanner)
    }
}
