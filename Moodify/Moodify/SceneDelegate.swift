//
//  SceneDelegate.swift
//  Moodify
//
//  Created by Cross Lawn on 11/1/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    lazy var rootViewController = ViewController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Initialize the window with the windowScene
        window = UIWindow(windowScene: windowScene)

        // Set the initial view controller from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            window?.rootViewController = initialViewController
        }

        window?.makeKeyAndVisible()
    }


    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let parameters = rootViewController.appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            rootViewController.responseCode = code
            // Add code to perform transition to the desired view controller here
            transitionToMainContent(with: scene)
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            rootViewController.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error =", error_description)
        }
    }

    // Helper method to transition to the main content of your app
    private func transitionToMainContent(with scene: UIScene) {
        // Assuming your storyboard's name is "Main" and the identifier for the Tab Bar Controller is "MainTabBarController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
            let accessToken = (self.window?.rootViewController as? ViewController)?.accessToken

                    // Pass the accessToken to each child view controller that needs it
                    for viewController in mainTabBarController.viewControllers ?? [] {
                        if let moodVC = viewController as? chooseMoodVC {
                            moodVC.accessToken = accessToken
                        } else if let songViewController = viewController as? songVC {
                            songViewController.accessToken = accessToken
                        }
                        // Repeat for other view controllers if necessary
                    }
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = mainTabBarController // Set the Tab Bar Controller as root
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }


    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let accessToken = rootViewController.appRemote.connectionParameters.accessToken {
            rootViewController.appRemote.connectionParameters.accessToken = accessToken
            rootViewController.appRemote.connect()
        } else if let accessToken = rootViewController.accessToken {
            rootViewController.appRemote.connectionParameters.accessToken = accessToken
            rootViewController.appRemote.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if rootViewController.appRemote.isConnected {
            rootViewController.appRemote.disconnect()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    


}
