import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  // Opaque cover shown while the app is not active so vault content never
  // appears in the app-switcher snapshot.
  private var privacyCover: UIView?

  override func sceneWillResignActive(_ scene: UIScene) {
    guard let window = window else { return }
    let cover = UIView(frame: window.bounds)
    cover.backgroundColor = UIColor(
      red: 0.05, green: 0.05, blue: 0.06, alpha: 1.0)
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(cover)
    privacyCover = cover
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    privacyCover?.removeFromSuperview()
    privacyCover = nil
  }

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "vault/app_icon",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setIcon" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let args = call.arguments as? [String: Any]
      let icon = args?["icon"] as? String ?? "calc"
      self.setAlternateIcon(icon, result: result)
    }
  }

  // Maps the Dart disguise name to an Info.plist CFBundleAlternateIcons key.
  // "calc" is the primary icon (nil). Weather / Compass require alternate icon
  // asset sets declared in Info.plist — see ios/README-disguise-icons.md.
  private func setAlternateIcon(_ icon: String, result: @escaping FlutterResult) {
    guard UIApplication.shared.supportsAlternateIcons else {
      result(nil)
      return
    }
    var iconName: String?
    switch icon {
    case "weather": iconName = "AppIconWeather"
    case "compass": iconName = "AppIconCompass"
    default: iconName = nil
    }
    UIApplication.shared.setAlternateIconName(iconName) { error in
      // Errors (e.g. asset not yet added) are swallowed on the Dart side.
      if let error = error {
        result(FlutterError(code: "icon_failed", message: error.localizedDescription, details: nil))
      } else {
        result(nil)
      }
    }
  }
}
