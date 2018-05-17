//
//  AppDelegate.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 5/3/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import UIKit
import EASIPRO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		print(Bundle.main.infoDictionary!["ASSESSMENTCENTER_KEY"] as Any)
		
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        let client = SMARTManager.shared.client
        if client.awaitingAuthCallback {
            return client.didRedirect(to: url)
        }
        return false
    }


}

