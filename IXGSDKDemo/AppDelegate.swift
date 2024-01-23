//
//  AppDelegate.swift
//  IXGSDKDemo
//
//  Created by Michael Sweeney on 12/15/23.
//

import UIKit
import PushKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate {
    let voipRegistry: PKPushRegistry = {
        let reg = PKPushRegistry(queue: nil)
        return reg
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
        print("App Delegate did finish launching")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        dump(pushCredentials)
        print("Push Credentials Updated")
    }
}
