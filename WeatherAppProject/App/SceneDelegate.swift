import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()

        print("WINDOW BOUNDS:", window.bounds)
        print("SCREEN BOUNDS:", UIScreen.main.bounds)

        let coordinator = AppCoordinator(navigationController: navigationController)
        self.appCoordinator = coordinator
        coordinator.start()
    }
}
