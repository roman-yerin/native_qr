import Flutter
import UIKit
import VisionKit

extension NSNotification.Name {
    static var QrCodeFound: Notification.Name {
        return .init(rawValue: "QrCodeFound")
    }
    static var ScanCanceled: Notification.Name {
        return .init(rawValue: "ScanCanceled")
    }
}


@available(iOS 16.0, *)
public class NativeQrPlugin: UIViewController, FlutterPlugin, DataScannerViewControllerDelegate {
    private var successObserver : NSObjectProtocol?
    private var cancelObserver : NSObjectProtocol?

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
        DispatchQueue.main.async { [weak self] in
            self?.viewController.stopScanning()
            self?.viewController.dismiss(animated: true)
        }
        NotificationCenter.default.removeObserver(successObserver!)
        NotificationCenter.default.removeObserver(cancelObserver!)
    }
    
    @objc func closeButtonPressed() {
        NotificationCenter.default.post(name: .ScanCanceled, object: nil)
    }
    
    @MainActor private func getQrCode() -> Bool {
        viewController.delegate = self
        
        let rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.filter({ (w) -> Bool in
                    return w.isHidden == false
        }).first?.rootViewController
        
        let closeButton = UIButton(type: .close)
        closeButton.frame = CGRectMake(self.view.frame.width - 60, 50, 35, 35)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        viewController.modalPresentationStyle = .fullScreen
        viewController.view.addSubview(closeButton)
        rootViewController?.present(viewController, animated: false)

        do {
            try viewController.startScanning()
            return true
        }
        catch {
            return false
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getQrCode":
            if(!DataScannerViewController.isSupported){
                result(FlutterError(code: "ERROR", message: "DataScannerViewController is upsupported on this device", details: nil))
                break
            }
            if(!DataScannerViewController.isAvailable){
                result(FlutterError(code: "ERROR", message: "DataScannerViewController is unavailable now", details: nil))
                break
            }
            successObserver = NotificationCenter.default.addObserver(forName: .QrCodeFound, object: nil, queue: OperationQueue()) { [weak self] msg in
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
            cancelObserver = NotificationCenter.default.addObserver(forName: .ScanCanceled, object: nil, queue: OperationQueue()) { [weak self] msg in
                self!.cleanupAndClose()
                result(FlutterError(code: "CANCELED", message: "Qr code scanning canceled", details: nil))
            }
            
            if(!getQrCode()){
                result(FlutterError(code: "ERROR", message: "DataScannerViewController can't start scanning", details: nil))
            }
            break;
        default:
            result(FlutterError(code: "UNIMPLEMENTED", message: "Method is not implemented", details: nil))
        }
    }
}


