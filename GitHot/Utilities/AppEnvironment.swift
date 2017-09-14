import Foundation
import GHAPI
import PaversFRP
import PaversArgo

/**
 A global stack that captures the current state of global objects that the app wants access to.
 */
public struct AppEnvironment {
//  internal static let environmentStorageKey = "com.kickstarter.AppEnvironment.current"
//  internal static let oauthTokenStorageKey = "com.kickstarter.AppEnvironment.oauthToken"
  private static let onceToken = UUID().uuidString

  public static func initialize() {
    DispatchQueue.once(token: onceToken) {
      swizzle(UIViewController.self)
      swizzle(UIView.self)
    }
  }

  static let apiService: ServiceType = Service()
}
