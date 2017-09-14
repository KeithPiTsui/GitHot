import UIKit

internal func swizzle(_ view: UIView.Type) {

  [(#selector(view.traitCollectionDidChange(_:)), #selector(view.ksr_traitCollectionDidChange(_:)))]
    .forEach { original, swizzled in

      let originalMethod = class_getInstanceMethod(view, original)
      let swizzledMethod = class_getInstanceMethod(view, swizzled)

      let didAddViewDidLoadMethod = class_addMethod(view,
                                                    original,
                                                    method_getImplementation(swizzledMethod),
                                                    method_getTypeEncoding(swizzledMethod))

      if didAddViewDidLoadMethod {
        class_replaceMethod(view,
                            swizzled,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
      } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
      }
  }
}

extension UIView {
  open override func awakeFromNib() {
    super.awakeFromNib()
    self.bindViewModel()
  }

  open func bindStyles() {
  }

  open func bindViewModel() {
  }

  public static var defaultReusableId: String {
    return self.description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")
  }

  internal func ksr_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection) {
    self.ksr_traitCollectionDidChange(previousTraitCollection)
    self.bindStyles()
  }
}

extension UIView {
  /// Let four edges of this view to attach its super view
  ///
  /// If superview is nil, do nothing
  internal func fillupSuperView(with margin: CGFloat = 8) {
    guard let sv = self.superview else { return }
    self.translatesAutoresizingMaskIntoConstraints = false
    self.topAnchor.constraint(equalTo: sv.topAnchor, constant: margin).isActive = true
    self.bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: -margin).isActive = true
    self.leftAnchor.constraint(equalTo: sv.leftAnchor, constant: margin).isActive = true
    self.rightAnchor.constraint(equalTo: sv.rightAnchor, constant: -margin).isActive = true
  }
}





