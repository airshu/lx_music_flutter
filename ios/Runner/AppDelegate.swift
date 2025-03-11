import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
      print("AppDelegate init >>>>>>> print")
      debugPrint("AppDelegate init >>>>>>>   debugPrint")
          
    // 安全解包 registrar
    if let registrar = self.registrar(forPlugin: "CryptoChannel") {
      CryptoChannel.register(with: registrar)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
