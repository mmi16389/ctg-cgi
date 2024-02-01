//
//  AppDelegate.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import CoreStore
import IQKeyboardManagerSwift
import VersionTracker
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var notificationDataService: NotificationDataService = NotificationDataServiceImpl()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        VersionTracker.shared.track()
        UserDefaults.standard.synchronize()

        IQKeyboardManager.shared.enable = true
        
        settingUpDatabase()
        
//        if VersionTracker.shared.isFirstLaunchEver {
//            KeychainManager.shared.clear()
//        }
        
        UNUserNotificationCenter.current().delegate = self
        
        #if !DEBUG
        MSAppCenter.start(Constant.AppCenter.secret, withServices: [
            MSAnalytics.self,
            MSCrashes.self
            ])
        #endif
        
        if User.currentUser() != nil {
            notificationDataService.subscribe { (_) in
                print("[Notification] subscribe at launch just in case")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onConfigurationChanded(_:)), name: .appConfigurationChanged, object: nil)
        
        if let launcOpts = launchOptions {
            if let userInfo = launcOpts[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
                // there is a notification
                if let aps = userInfo["aps"] as? [String: AnyObject] {
                    print("aps : \(aps)")
                    processPushUserInfo(userInfo, wasInBackgound: true)
                }
            } else {
                UserDefaultManager.shared.removePushNotification()
            }
        }
        
        return true
    }
    
    func settingUpDatabase() {
        do {
            CoreStoreDefaults.dataStack = DataStack(
                xcodeModelName: "GCI" // loads from the "MyModel.xcdatamodeld" file
            )
            
            try CoreStoreDefaults.dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "GCI.sqlite",
                    localStorageOptions: .recreateStoreOnModelMismatch // optional. Provides settings that tells the DataStack how to setup the persistent store
                )
            )
        } catch let error {
            print("Cannot load the database")
            print(error.localizedDescription)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if rootViewController.responds(to: Selector(("canRotate"))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown
            }
            
            if rootViewController.responds(to: #selector(HomeViewController.iPadCanRotate)) || rootViewController.responds(to: #selector(UIAlertController.iPadCanRotate)) || rootViewController.responds(to: #selector(LoaderViewController.iPadCanRotate)) {
                // Unlock landscape view orientations for this view controller
                if DeviceType.isIpad {
                    if rootViewController.isKind(of: UIAlertController.self) || rootViewController.isKind(of: LoaderViewController.self) {
                        if parentOfView(alertView: rootViewController)?.isKind(of: HomeViewController.self) ?? false {
                            return .allButUpsideDown
                        } else {
                            return .portrait
                        }
                    } else {
                        return .allButUpsideDown
                    }
                } else {
                    return .portrait
                }
            }
        }
        
        // Only allow portrait (standard behaviour)
        return .portrait
    }
    
    private func parentOfView(alertView: UIViewController?) -> UIViewController? {
        if let navController = alertView?.presentingViewController as? UINavigationController,
            let tabBarController = navController.viewControllers.last as? TabBarViewController,
            let finalNavController = tabBarController.selectedViewController as? UINavigationController {
            return finalNavController.viewControllers.last
        } else {
            return nil
        }
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if rootViewController == nil { return nil }
        if rootViewController.isKind(of: UITabBarController.self) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if rootViewController.isKind(of: UINavigationController.self) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if rootViewController.presentedViewController != nil {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let previousToken = KeychainManager.shared.pushToken, previousToken != deviceToken {
            notificationDataService.unsubscribe {
                print("[Notification] unsubscribe due to token change with message \($0)")
            }
        }
        KeychainManager.shared.pushToken = deviceToken
        
        notificationDataService.subscribe {
            print("[Notification] subscribe due to token change with message \($0)")
        }

    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        processPushUserInfo(userInfo, wasInBackgound: false)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        processPushUserInfo(userInfo, wasInBackgound: false)
    }
    
    @objc func onConfigurationChanded(_ notification: Notification) {
        notificationDataService.subscribe {
            print("[Notification] subscribe due to configuration change with message \($0)")
        }
    }
    
    private func processPushUserInfo(_ userInfo: [AnyHashable: Any]?, wasInBackgound: Bool) {
        guard let userInfo = userInfo else {
            return
        }
        
        if let aps = userInfo["aps"] as? [AnyHashable: Any], let title = aps["title"] as? String {
            UserDefaultManager.shared.notificationPushEventTitle = title
        } else {
            UserDefaultManager.shared.notificationPushEventTitle = nil
        }
        if let aps = userInfo["aps"] as? [AnyHashable: Any], let message = aps["message"] as? String {
            UserDefaultManager.shared.notificationPushEventMessage = message
        } else {
            UserDefaultManager.shared.notificationPushEventMessage = nil
        }
        
        if let taskId = userInfo["taskIdentifier"] as? Int {
            UserDefaultManager.shared.notificationPushEventTaskId = taskId
        } else {
            // Should not redirect
            UserDefaultManager.shared.notificationPushEventTaskId = nil
        }
        
        if !wasInBackgound {
            NotificationCenter.default.post(name: Notification.Name.pushNotificationReceived, object: nil)
            if let navController = self.window?.rootViewController as? UINavigationController {
                let tabBar = navController.viewControllers.first { (controller) -> Bool in
                    return controller is TabBarViewController
                }
                if let safeTabBar = tabBar as? TabBarViewController {
                    if UserDefaultManager.shared.notificationPushEventTaskId != nil {
                        //CASE TASK (force go to home)
                        safeTabBar.selectedIndex = 0
                        if let firstChildController = safeTabBar.children[safe: 0] {
                            if let navController = firstChildController as? UINavigationController {
                                navController.popToRootViewController(animated: false)
                                if let homeController = navController.topViewController as? HomeViewController {
                                    homeController.checkNotificationReceived()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
