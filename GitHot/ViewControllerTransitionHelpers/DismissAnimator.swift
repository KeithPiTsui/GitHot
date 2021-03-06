//
//  DismissAnimator.swift
//  InteractiveModal
//
//  Created by Robert Chen on 1/8/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//

import UIKit

final class DismissAnimator : NSObject {}

extension DismissAnimator : UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
    -> TimeInterval {
    return 0.6
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
      let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
      else { return }
    
    let containerView = transitionContext.containerView

    containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

    let screenSize = UIScreen.main.bounds.size
    let bottomLeftCorner = CGPoint(x: 0, y: screenSize.height)
    let finalFrame = CGRect(origin: bottomLeftCorner, size: screenSize)

    UIView.animate(
      withDuration: transitionDuration(using: transitionContext),
      animations: { fromVC.view.frame = finalFrame },
      completion: { _ in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled) }
    )
  }
}
