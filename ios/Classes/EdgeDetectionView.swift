import Flutter
import WeScan
import UIKit

class EdgeDetectionView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var cameraController: ImageScannerController?
    private var selectPhotoButton: UIButton?
    private var saveTo: String = ""
    private var canUseGallery: Bool = true
    private var result: FlutterResult?
    
    init(
        frame: CGRect,
        viewIdentifier: Int64,
        messenger: FlutterBinaryMessenger,
        arguments: Any?
    ) {
        _view = UIView(frame: frame)
        super.init()
        
        if let args = arguments as? [String: Any] {
            saveTo = args["save_to"] as? String ?? ""
            canUseGallery = args["can_use_gallery"] as? Bool ?? true
        }
        
        setupCamera()
        setupGalleryButton()
    }
    
    func view() -> UIView {
        return _view
    }
    
    private func setupCamera() {
        cameraController = ImageScannerController()
        cameraController?.imageScannerDelegate = self
        
        if #available(iOS 13.0, *) {
            cameraController?.isModalInPresentation = true
            cameraController?.overrideUserInterfaceStyle = .dark
            cameraController?.view.backgroundColor = .black
        }
        
        if let cameraView = cameraController?.view {
            cameraView.frame = _view.bounds
            _view.addSubview(cameraView)
        }
    }
    
    private func setupGalleryButton() {
        selectPhotoButton = UIButton()
        guard let button = selectPhotoButton else { return }
        
        button.setImage(UIImage(named: "gallery", in: Bundle(for: SwiftEdgeDetectionPlugin.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = !canUseGallery
        
        _view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44.0),
            button.heightAnchor.constraint(equalToConstant: 44.0),
            button.rightAnchor.constraint(equalTo: _view.rightAnchor, constant: -24.0),
            _view.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: (65.0 / 2) - 10.0)
        ])
    }
    
    @objc private func selectPhoto() {
        let scanPhotoVC = ScanPhotoViewController()
        scanPhotoVC.saveTo = self.saveTo
        if #available(iOS 13.0, *) {
            scanPhotoVC.isModalInPresentation = true
            scanPhotoVC.overrideUserInterfaceStyle = .dark
        }
        
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(scanPhotoVC, animated: true)
        }
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        
        let path = "file://" + self.saveTo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let filePath = URL(string: path)!
        
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath.path) {
                try fileManager.removeItem(atPath: filePath.path)
            }
            
            try data.write(to: filePath)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

extension EdgeDetectionView: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
        result?(false)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        saveImage(image: results.doesUserPreferEnhancedScan ? results.enhancedScan!.image : results.croppedScan.image)
        result?(true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        result?(false)
    }
} 