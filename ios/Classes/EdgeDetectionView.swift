import Flutter
import WeScan
import UIKit

class EdgeDetectionView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var cameraController: ImageScannerController?
    private var selectPhotoButton: UIButton?
    private var canUseGallery: Bool = true
    private var channel: FlutterMethodChannel
    
    init(
        frame: CGRect,
        viewIdentifier: Int64,
        messenger: FlutterBinaryMessenger,
        arguments: Any?
    ) {
        _view = UIView(frame: frame)
        
        var channelName = "edge_detection_view_\(viewIdentifier)"
        if let args = arguments as? [String: Any] {
            canUseGallery = args["can_use_gallery"] as? Bool ?? true
            if let viewId = args["view_id"] as? Int64 {
                channelName = "edge_detection_view_\(viewId)"
            }
        }
        
        channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        print("Swift channel name: \(channelName)")
        super.init()
        
        setupChannel()
        setupCamera()
        setupGalleryButton()
    }
    
    private func setupChannel() {
        print("Setting up Swift method channel handler")
        channel.setMethodCallHandler { [weak self] (call, result) in
            print("Swift received method call: \(call.method)")
            switch call.method {
            case "dispose":
                self?.dispose()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func dispose() {
        cameraController?.dismiss(animated: false)
        cameraController = nil
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
        scanPhotoVC.delegate = self
        if #available(iOS 13.0, *) {
            scanPhotoVC.isModalInPresentation = true
            scanPhotoVC.overrideUserInterfaceStyle = .dark
        }
        
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(scanPhotoVC, animated: true)
        }
    }
    
    private func saveImageAndNotify(image: UIImage) {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let fileName = "\(timestamp).jpeg"
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            channel.invokeMethod("onError", arguments: "Could not get documents directory")
            return
        }
        
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 1) else {
            channel.invokeMethod("onError", arguments: "Could not convert image to data")
            return
        }
        
        do {
            try data.write(to: fileURL)
            channel.invokeMethod("onImageCaptured", arguments: fileURL.path)
        } catch {
            channel.invokeMethod("onError", arguments: error.localizedDescription)
        }
    }
}

extension EdgeDetectionView: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
        channel.invokeMethod("onError", arguments: error.localizedDescription)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        let image = results.doesUserPreferEnhancedScan ? results.enhancedScan!.image : results.croppedScan.image
        saveImageAndNotify(image: image)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        channel.invokeMethod("onCancel", arguments: nil)
    }
}

extension EdgeDetectionView: ScanPhotoViewControllerDelegate {
    func scanPhotoViewController(_ controller: ScanPhotoViewController, didFinishScanningWithResults results: ImageScannerResults) {
        let image = results.doesUserPreferEnhancedScan ? results.enhancedScan!.image : results.croppedScan.image
        saveImageAndNotify(image: image)
    }
    
    func scanPhotoViewControllerDidCancel(_ controller: ScanPhotoViewController) {
        channel.invokeMethod("onCancel", arguments: nil)
    }
} 