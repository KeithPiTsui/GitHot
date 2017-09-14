//
//  WaterController.swift
//  Physics
//
//  Created by Kiran Kunigiri on 7/18/15.
//  Copyright (c) 2015 Kiran Kunigiri. All rights reserved.
//

import Foundation
import UIKit

internal final class RainingController {

  // MARK: - Properties

  // MARK: Views
  private let view: UIView
  fileprivate var drops: [UIView] = []

  // MARK: Drop behaviors
  fileprivate let animator: UIDynamicAnimator
  fileprivate let gravityBehavior = UIGravityBehavior()
  fileprivate var timer1: Timer?

  private let raindropImage = UIImage(named: "raindrop")!

  var rainyRect = CGRect.zero

  // MARK: - Methods
  init(view: UIView) {
    // Get main view
    self.view = view

    // Initialize animator
    animator = UIDynamicAnimator(referenceView: self.view)
    gravityBehavior.gravityDirection.dy = 1
    animator.addBehavior(gravityBehavior)
  }

  /** Starts the rain animation */
  func start() {
    // Timer that calls spawnFirst method every 0.2 second. 
    // Produces rain drops every .2 second in 1st and 2rd row
    timer1 = Timer.scheduledTimer(timeInterval: 0.1,
                                  target: self,
                                  selector: #selector(spawnFirst),
                                  userInfo: nil,
                                  repeats: true)
  }


  // MARK: - Helper Methods

  /** Manages all drops in rain */
  fileprivate func addGravity(_ array: [UIView]) {
    // Adds gravity to every drop in array
    for drop in array { gravityBehavior.addItem(drop) }

    // Checks if each drop is below the bottom of screen. Then removes its gravity, hides it, and removes from array
    let invalidDrops = drops.filter { $0.frame.origin.y > self.view.frame.height }
    invalidDrops.forEach {
      gravityBehavior.removeItem($0)
      $0.removeFromSuperview()
      if let idx = drops.index(of: $0) {
        drops.remove(at: idx)
      }
    }
  }

  /** Spawns water drops */
  @objc fileprivate func spawnFirst() {
    //creates array of UIViews (drops)
    var thisArray: [UIView] = []
    //number of col of drops [3, 6]
    let numberOfDrops = Int(arc4random_uniform(UInt32(3))) + 3

    //for each drop in a row
    for _ in 0 ..< numberOfDrops {
      // Create a UIView (a drop). Then set the size, color, and remove border of drop
      let x = CGFloat(arc4random_uniform(UInt32(self.rainyRect.size.width))) + self.rainyRect.origin.x
      let y = self.rainyRect.origin.y

      let size = self.raindropImage.size
      let ratio = size.height / size.width
      let drop = UIImageView(image: self.raindropImage)
      drop.frame = CGRect(x: x,
                          y: y,
                          width: 10.0,
                          height: 10 * ratio)

      // Add the drop to main view
      self.view.addSubview(drop)
      // Add the drop to the drops array
      self.drops.append(drop)
      // Add the drop to thisArray
      thisArray.append(drop)
    }
    // Adds gravity to the drops that were just created
    addGravity(thisArray)
  }

  /** Stops the water animation */
  func stop() {
    // Stop all timers
    timer1?.invalidate()
    timer1 = nil
    // Remove all objects from drops array
    drops.forEach {
      gravityBehavior.removeItem($0)
      $0.removeFromSuperview()
    }
    drops.removeAll()

  }
}
