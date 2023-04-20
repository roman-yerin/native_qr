import Flutter
import UIKit
import VisionKit

extension NSNotification.Name {
    static var QrCodeFound: Notification.Name {
        return .init(rawValue: "QrCodeFound")
    }
}


@available(iOS 16.0, *)
public class NativeQrPlugin: UIViewController, FlutterPlugin, DataScannerViewControllerDelegate {
    private var observer : NSObjectProtocol?
    private var viewController = DataScannerViewController(
        recognizedDataTypes: [.barcode(symbologies: [.qr])],
        qualityLevel: .balanced,
        recognizesMultipleItems: false,
        isHighFrameRateTrackingEnabled: false,
        isHighlightingEnabled: true)
    
    
    public func dataScannerDidZoom(_ dataScanner: DataScannerViewController) {
        
    }
    
    public func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        
    }
    
    public func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        NotificationCenter.default.post(name: .QrCodeFound, object: allItems[0])
    }
    
    public func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        
    }
    
    public func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        
    }
    
    public func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
        
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_qr", binaryMessenger: registrar.messenger())
        let instance = NativeQrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func cleanupAndClose(){
        viewController.stopScanning()
        viewController.dismiss(animated: true)
        NotificationCenter.default.removeObserver(observer!)
    }
    
    @objc func pressed() {
        cleanupAndClose()
    }
    
    @MainActor private func getQrCode(){
        viewController.delegate = self
        
        let rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.filter({ (w) -> Bool in
                    return w.isHidden == false
        }).first?.rootViewController
        
        let closeButton = UIButton(type: .close)
        closeButton.frame = CGRectMake(self.view.frame.width - 60, 50, 35, 35)
        closeButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        
        viewController.modalPresentationStyle = .fullScreen
        viewController.view.addSubview(closeButton)
        rootViewController?.present(viewController, animated: false)

        do {
            try viewController.startScanning()
        }
        catch {
            print("err")
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getQrCode":
            observer = NotificationCenter.default.addObserver(forName: .QrCodeFound, object: nil, queue: OperationQueue()) { [weak self] msg in
                let item = msg.object as! RecognizedItem
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self!.cleanupAndClose()
                }

                switch item {
                case .barcode(let code):
                    result(code.payloadStringValue);
                case .text(let text):
                    result(text.transcript);
                @unknown default:
                    result(FlutterError(code: "UNKNOWN", message: "Unknown code received somehow", details: nil))
                }
                
            }
            getQrCode()
            break;
        default:
            result(FlutterError(code: "UNIMPLEMENTED", message: "Method is not implemented", details: nil))
        }
    }
}


