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

//    NSUInteger cacheSizeMemory = 500*1024*1024; // 500 MB
//    NSUInteger cacheSizeDisk = 500*1024*1024; // 500 MB
//    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
//    [NSURLCache setSharedURLCache:sharedCache];
//    sleep(1);

    let sharedCache = URLCache(memoryCapacity: 500*1024*1024,
                               diskCapacity: 500*1024*1024,
                               diskPath: "nsurlcache")
    URLCache.shared = sharedCache
    sleep(1)

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

