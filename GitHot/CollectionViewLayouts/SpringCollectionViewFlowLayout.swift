//
//  SpringCollectionViewFlowLayout.swift
//  GitHot
//
//  Created by Pi on 23/08/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import PaversUI


internal final class SpringCollectionViewFlowLayout: UICollectionViewFlowLayout {
  internal var springDamping: CGFloat = 0.5 {
    didSet {
      guard self.springDamping >= 0 && self.springDamping != oldValue
        else {self.springDamping = oldValue; return}
      self.animator.behaviors.forEach {
        if let spring = $0 as? UIAttachmentBehavior {
          spring.damping = self.springDamping
        }
      }
    }
  }
  internal var springFrequency: CGFloat = 0.8 {
    didSet {
      guard self.springFrequency >= 0 && self.springFrequency != oldValue
        else {self.springFrequency = oldValue; return}
      self.animator.behaviors.forEach {
        if let spring = $0 as? UIAttachmentBehavior {
          spring.frequency = self.springFrequency
        }
      }
    }
  }
  internal var resistenceFactor: CGFloat = 1000

  private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)

  override func prepare() {
    super.prepare()
    let contentSize = self.collectionViewContentSize
    let items = super.layoutAttributesForElements(in: CGRect(0, 0, contentSize.width, contentSize.height))!
    if items.count != self.animator.behaviors.count {
      self.animator.removeAllBehaviors()
      items.forEach{ (item) in
        let spring = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
        spring.length = 0
        spring.damping = self.springDamping
        spring.frequency = self.springFrequency
        self.animator.addBehavior(spring)
      }
    }
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return self.animator.items(in: rect) as? [UICollectionViewLayoutAttributes]
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return self.animator.layoutAttributesForCell(at:indexPath)
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let sv = self.collectionView else { return false }
    let scrollDelta = newBounds.origin.y - sv.bounds.origin.y
    let touchLocation = sv.panGestureRecognizer.location(in: sv)
    self.animator.behaviors.forEach {
      guard let spring = $0 as? UIAttachmentBehavior else { return }
      let anchorPoint = spring.anchorPoint
      let distanceFromTouch = abs(touchLocation.y - anchorPoint.y)
      let sr = distanceFromTouch / self.resistenceFactor
      if let item = spring.items.first {
        var center = item.center
        center.y += scrollDelta > 0 ? min(scrollDelta, scrollDelta * sr) : max(scrollDelta, scrollDelta * sr)
        item.center = center
        self.animator.updateItem(usingCurrentState: item)
      }
    }
    return false
  }
}





























