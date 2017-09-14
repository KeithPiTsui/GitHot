//
//  AppDelegate.swift
//  GitHot
//
//  Created by Pi on 22/08/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import PaversFRP
import PaversUI
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    AppEnvironment.initialize()

    UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

    let win = UIWindow()
    let rootVC = RepoListViewController()
    win.rootViewController = rootVC
    win.makeKeyAndVisible()
    self.window = win

    return true
  }
}

