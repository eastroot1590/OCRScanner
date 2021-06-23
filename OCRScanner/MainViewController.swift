//
//  MainViewController.swift
//  OCRTutorial
//
//  Created by 이동근 on 2021/06/22.
//

import UIKit
import MobileCoreServices
import TesseractOCR

import Firebase

struct KakaoResponse: Decodable {
    struct OCRResult: Decodable {
        let boxes: [[Int]]
        let recognition_words: [String]
    }
    
    let result: [OCRResult]
}

class MainViewController: UIViewController {
    enum OCREngine {
        case mlvision
        case tesseract
        case kakao
    }
    
    let scannedString: UILabel = UILabel()
    
    let scalePicker = UIPickerView()
    let scales: [CGFloat] = [300, 500, 1000]
    var scaleFactor: CGFloat = 300
    
    let tesseractButton = UIButton()
    let mlvisionButton = UIButton()
    let kakaoButton = UIButton()
    
    var engine: OCREngine = .mlvision
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        title = "Main"
        
        scalePicker.dataSource = self
        scalePicker.delegate = self
        scalePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scalePicker)
        NSLayoutConstraint.activate([
            scalePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            scalePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        tesseractButton.setTitleColor(.label, for: .normal)
        tesseractButton.setTitle("OCR with Tesseract", for: .normal)
        tesseractButton.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        tesseractButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tesseractButton)
        NSLayoutConstraint.activate([
            tesseractButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tesseractButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100)
        ])
        
        mlvisionButton.setTitleColor(.label, for: .normal)
        mlvisionButton.setTitle("OCR with MLVision", for: .normal)
        mlvisionButton.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        mlvisionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mlvisionButton)
        NSLayoutConstraint.activate([
            mlvisionButton.topAnchor.constraint(equalTo: tesseractButton.bottomAnchor, constant: 20),
            mlvisionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        kakaoButton.setTitleColor(.label, for: .normal)
        kakaoButton.setTitle("OCR with KakaoVision", for: .normal)
        kakaoButton.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        kakaoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(kakaoButton)
        NSLayoutConstraint.activate([
            kakaoButton.topAnchor.constraint(equalTo: mlvisionButton.bottomAnchor, constant: 20),
            kakaoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        scannedString.font = .systemFont(ofSize: 16)
        scannedString.backgroundColor = .black
        scannedString.numberOfLines = 0
        scannedString.textColor = .white
        scannedString.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scannedString)
        NSLayoutConstraint.activate([
            scannedString.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scannedString.topAnchor.constraint(equalTo: kakaoButton.bottomAnchor, constant: 20)
        ])
    }
    
    @objc func pickImage(_ sender: UIButton) {
        scannedString.text = "로딩중..."
        
        if sender == mlvisionButton {
            loadPicker(with: .mlvision)
        } else if sender == tesseractButton {
            loadPicker(with: .tesseract)
        } else if sender == kakaoButton {
            loadPicker(with: .kakao)
        }
    }
    
    private func loadPicker(with engine: OCREngine) {
        self.engine = engine
        
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo", style: .default) { alert in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Existing", style: .default) { alert in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true)
    }
    
    private func tesseractOCR(_ sourceImage: UIImage) {
        print("scale factor \(scaleFactor)")
        guard let scaledImage = sourceImage.scaledImage(scaleFactor) else {
            return
        }
        
        if let tesseract = G8Tesseract(language: "kor+eng") {
            tesseract.engineMode = .tesseractOnly
            tesseract.pageSegmentationMode = .auto
            tesseract.image = scaledImage
            
            if tesseract.recognize() {
                self.scannedString.text = "Tesseract: \(tesseract.recognizedText ?? "인식 실패")"
            } else {
                print("scan fail")
            }
        }
    }
    
    private func mlvisionOCR(_ sourceImage: UIImage) {
        print("scale factor \(scaleFactor)")
        guard let scaledImage = sourceImage.scaledImage(scaleFactor) else {
            return
        }
        
        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "ko"]
        let textRecognizer = vision.cloudTextRecognizer()
        textRecognizer.process(VisionImage(image: scaledImage)) { result, error in
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
            self.scannedString.text = "MLVisioin: \(content)"
        }
    }
    
    private func kakaoOCR(_ sourceImage: UIImage) {
        print("scale factor \(scaleFactor)")
        guard let scaledImage = sourceImage.scaledImage(scaleFactor) else {
            return
        }
        
        Client().requestServer("https://dapi.kakao.com/v2/vision/text/ocr", parameter: scaledImage.jpegData(compressionQuality: 1), responseType: KakaoResponse.self, completed: { result in
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
            
            self.scannedString.text = "Kakao: \(resultString)"
        })
    }
    
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        
        dismiss(animated: true) {
            switch self.engine {
            case .mlvision:
                self.mlvisionOCR(selectedPhoto)
                
            case .tesseract:
                self.tesseractOCR(selectedPhoto)
                
            case .kakao:
                self.kakaoOCR(selectedPhoto)
            }
        }
    }
}

extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        scales.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < scales.count else {
            return nil
        }
        
        return scales[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < scales.count else {
            return
        }
        
        self.scaleFactor = scales[row]
    }
}
