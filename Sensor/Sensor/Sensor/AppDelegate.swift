//
//  AppDelegate.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/25.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
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
        if IMEI.shared.value == "" {
            if let navigationController = window?.rootViewController as? UINavigationController, let viewController = navigationController.viewControllers.first as? ViewController {
                DispatchQueue.main.async {
                    viewController.performSegue(withIdentifier: SegueIdentifiers.inputIMEI.rawValue, sender: nil)
                }
            }
/*
            var gotIMEI = false
            if let sitAccuracyRegEx = try? NSRegularExpression(pattern: imeiPattern) {
                if let pasteIMEI = UIPasteboard.general.string {
                    let matches = sitAccuracyRegEx.matches(in: pasteIMEI, range: NSMakeRange(0, pasteIMEI.characters.count))
                    if matches.count == 1, let range = matches.last?.range {
                        let imeiString = pasteIMEI.substring(with: pasteIMEI.index(pasteIMEI.startIndex, offsetBy: range.location)..<pasteIMEI.index(pasteIMEI.startIndex, offsetBy: range.location + range.length))
                        if imeiString.characters.count == 18, let navigationController = window?.rootViewController as? UINavigationController, let viewController = navigationController.viewControllers.first as? ViewController {
                            gotIMEI = true
                            viewController.imeiString = imeiString
                            DispatchQueue.main.async {
                                viewController.performSegue(withIdentifier: SegueIdentifiers.inputIMEI.rawValue, sender: nil)
                            }
                        }
                    }
                }
            }
            if gotIMEI == false {
                let alert = UIAlertController(title: "需要IMEI", message: "请在”设置-通用-关于“中找到并长按复制IMEI", preferredStyle: .alert)
                let actionOK = UIAlertAction(title: "设置", style: .default) { _ in
                    if let settingURL = URL(string: "App-Prefs:root=General&path=About") {
                        if UIApplication.shared.canOpenURL(settingURL) {
                            UIApplication.shared.open(settingURL)
                        }
                    }
                }
                alert.addAction(actionOK)
                window?.rootViewController?.present(alert, animated: true)
            }
 */
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

