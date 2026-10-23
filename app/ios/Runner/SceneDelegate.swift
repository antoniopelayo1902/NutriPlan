import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    private var privacyView: UIVisualEffectView?

    // Cover the window with a blur while the app is inactive so the
    // app-switcher snapshot does not show health data.
    override func sceneWillResignActive(_ scene: UIScene) {
        if let window = self.window, privacyView == nil {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
            blur.frame = window.bounds
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(blur)
            privacyView = blur
        }
        super.sceneWillResignActive(scene)
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        privacyView?.removeFromSuperview()
        privacyView = nil
        super.sceneDidBecomeActive(scene)
    }
}
