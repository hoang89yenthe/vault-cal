import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

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
