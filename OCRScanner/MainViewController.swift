//
//  MainViewController.swift
//  OCRTutorial
//
//  Created by 이동근 on 2021/06/22.
//

import UIKit
import MobileCoreServices
import TesseractOCR

import PEPhotoCropEditor

import Firebase

struct KakaoResponse: Decodable {
    struct OCRResult: Decodable {
        let boxes: [[Int]]
        let recognition_words: [String]
    }
    
    let result: [OCRResult]
}

class MainViewController: UIViewController {
    enum OCREngine: String {
        case MLVision
        case Tesseract
        case Kakao
    }
    
    let scanOptionPicker = UIPickerView()
    
    let scannedString: UILabel = UILabel()
    
    let scales: [CGFloat] = [300, 500, 1000]
    var scaleFactor: CGFloat = 300
    let engines: [OCREngine] = [.Kakao, .Tesseract, .MLVision]
    var engine: OCREngine = .Kakao
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        title = "Main"
        
        scanOptionPicker.dataSource = self
        scanOptionPicker.delegate = self
        scanOptionPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanOptionPicker)
        NSLayoutConstraint.activate([
            scanOptionPicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            scanOptionPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let loadPickerButton = UIButton()
        loadPickerButton.backgroundColor = .systemBlue
        loadPickerButton.setTitle("사진 선택", for: .normal)
        loadPickerButton.setTitleColor(.white, for: .normal)
        loadPickerButton.addTarget(self, action: #selector(loadImagePicker), for: .touchUpInside)
        loadPickerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadPickerButton)
        NSLayoutConstraint.activate([
            loadPickerButton.topAnchor.constraint(equalTo: scanOptionPicker.bottomAnchor, constant: 50),
            loadPickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadPickerButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            loadPickerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        scannedString.font = .systemFont(ofSize: 12)
        scannedString.numberOfLines = 0
        scannedString.textColor = .label
        scannedString.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scannedString)
        NSLayoutConstraint.activate([
            scannedString.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scannedString.topAnchor.constraint(equalTo: loadPickerButton.bottomAnchor, constant: 40)
        ])
        
        
//        sampleImage.frame.size = CGSize(width: 300, height: 300)
//        sampleImage.backgroundColor = .red
//        sampleImage.contentMode = .scaleAspectFit
//        sampleImage.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(sampleImage)
//        NSLayoutConstraint.activate([
//            sampleImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            sampleImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            sampleImage.widthAnchor.constraint(equalToConstant: 300),
//            sampleImage.heightAnchor.constraint(equalToConstant: 300)
//        ])
    }
    
    @objc func loadImagePicker() {
        let imagePickerActionSheet = UIAlertController(title: "OCR 스캔하기", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "카메라에서", style: .default) { alert in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
//                imagePicker.allowsEditing = true
                imagePicker.mediaTypes = [kUTTypeImage as String]
                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "사진에서", style: .default) { alert in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
//            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true)
    }
    
    private func tesseractOCR(_ sourceImage: UIImage) {
        if let tesseract = G8Tesseract(language: "kor+eng") {
            tesseract.engineMode = .tesseractOnly
            tesseract.pageSegmentationMode = .auto
            tesseract.image = sourceImage
            
            if tesseract.recognize() {
                self.scannedString.text = "Tesseract:\n\(tesseract.recognizedText ?? "인식 실패")"
            } else {
                print("scan fail")
            }
        }
    }
    
    private func mlvisionOCR(_ sourceImage: UIImage) {
        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "ko"]
        let textRecognizer = vision.cloudTextRecognizer()
        textRecognizer.process(VisionImage(image: sourceImage)) { result, error in
            if let error = error {
                debugPrint(error)
            }
            
            guard let result = result else {
                print("no result")
                return
            }
            
            var content: String = ""
            for block in result.blocks {
                print("\(block.text)/")
                content.append("\(block.text)\n")
            }
            self.scannedString.text = "MLVisioin:\n\(content)"
        }
    }
    
    private func kakaoOCR(_ sourceImage: UIImage) {
        Client().requestServer("https://dapi.kakao.com/v2/vision/text/ocr", parameter: sourceImage.jpegData(compressionQuality: 1), responseType: KakaoResponse.self, completed: { result in
            guard let result = result else {
                print("response fail")
                return
            }
            
            var resultString: String = ""
            
            for res in result.result {
                for word in res.recognition_words {
                    resultString.append("\(word)\n")
                }
            }
            
            self.scannedString.text = "Kakao:\n\(resultString)"
        })
    }
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        
        dismiss(animated: true, completion: {
            let editor = EditorViewController(image: selectedPhoto)
            editor.delegate = self
            let navigationController = UINavigationController(rootViewController: editor)
            navigationController.modalPresentationStyle = .overFullScreen
            self.present(navigationController, animated: true, completion: nil)
        })
    }
}

extension MainViewController: MyCropDelegate {
    func cropView(didFinishCropImage image: UIImage) {
        guard let scaledImage = image.scaledImage(self.scaleFactor) else {
            return
        }
        
//        sampleImage.image = image
        
        self.scannedString.text = "로딩중..."
        
        switch self.engine {
        case .MLVision:
            self.mlvisionOCR(scaledImage)
            
        case .Tesseract:
            self.tesseractOCR(scaledImage)
            
        case .Kakao:
            self.kakaoOCR(scaledImage)
        }
    }
}

extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return scales.count
        } else if component == 1 {
            return engines.count
        } else {
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            guard row < scales.count else {
                return nil
            }
            
            return scales[row].description
        } else if component == 1 {
            guard row < engines.count else {
                return nil
            }
            
            return engines[row].rawValue
        } else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            guard row < scales.count else {
                return
            }
            
            self.scaleFactor = scales[row]
        } else if component == 1 {
            guard row < engines.count else {
                return
            }
            
            self.engine = engines[row]
        }
    }
}
