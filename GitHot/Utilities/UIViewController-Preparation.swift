import ObjectiveC
import UIKit

internal func swizzle(_ vc: UIViewController.Type) {
  [
    (#selector(vc.viewDidLoad), #selector(vc.ksr_viewDidLoad)),
    (#selector(vc.viewWillAppear(_:)), #selector(vc.ksr_viewWillAppear(_:))),
    (#selector(vc.traitCollectionDidChange(_:)), #selector(vc.ksr_traitCollectionDidChange(_:)))
    ].forEach { original, swizzled in
      guard let originalMethod = class_getInstanceMethod(vc, original),
        let swizzledMethod = class_getInstanceMethod(vc, swizzled)
        else {fatalError("Failed to swizzle methods in UIViewController")}
      method_exchangeImplementations(originalMethod, swizzledMethod)
  }
}

extension UIViewController {

  @objc fileprivate func ksr_viewDidLoad() {
    self.ksr_viewDidLoad()
    self.bindViewModel()
  }
  @objc fileprivate func ksr_viewWillAppear(_ animated: Bool) {
    self.ksr_viewWillAppear(animated)
    if !self.hasViewAppeared {
      self.bindStyles()
      self.hasViewAppeared = true
    }
  }
  @objc fileprivate func ksr_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    self.ksr_traitCollectionDidChange(previousTraitCollection)
    self.bindStyles()
  }

  /**
   The entry point to bind all view model outputs. Called just before `viewDidLoad`.
   */
  open func bindViewModel() {}
  /**
   The entry point to bind all styles to UI elements. Called just after `viewDidLoad`.
   */
  open func bindStyles() {}

  private struct AssociatedKeys { static var hasViewAppeared = "hasViewAppeared"}

  // Helper to figure out if the `viewWillAppear` has been called yet
  private var hasViewAppeared: Bool {
    get {
      return (objc_getAssociatedObject(self, &AssociatedKeys.hasViewAppeared) as? Bool) ?? false
    }
    set {
      objc_setAssociatedObject(self,
                               &AssociatedKeys.hasViewAppeared,
                               newValue,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

extension UIViewController {
  public static var defaultNib: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }

  public static var storyboardIdentifier: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }
}


















