//
//  RepoCollectionViewCell.swift
//  GitHot
//
//  Created by Pi on 23/08/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import PaversFRP
import PaversUI

final class RepoCollectionViewCell: UICollectionViewCell, ValueCell {

  fileprivate let card = UIView()
  fileprivate let repoOwnerName = UILabel()
  fileprivate let repoFullName = UILabel()
  fileprivate let repoDesc = UILabel()
  fileprivate let pl = UILabel()
  fileprivate let allStars = UILabel()
  fileprivate let forks = UILabel()
  fileprivate let periodStars = UILabel()
  fileprivate let plIcon = UIImageView(image: UIImage(named: "primitive-dot"))
  fileprivate let allStarsIcon = UIImageView(image: UIImage(named: "star"))
  fileprivate let forksIcon = UIImageView(image: UIImage(named: "repo-forked"))
  fileprivate let periodStarsIcon = UIImageView(image: UIImage(named: "star"))

  internal var periodDesc: String = "today"

  fileprivate var curlView: XBCurlView?
   let lastLineView: UIView = UIView()
  fileprivate let spacer = UIView()

  func configureWith(value: RepoProfile) {
    self.repoOwnerName.text = "-\(value.ownerName)"
    self.repoFullName.text = value.repoName

    self.repoDesc.text = value.repoDesc
    self.pl.text = value.plName
    self.allStars.text = "\(value.allStars)"
    self.forks.text = "\(value.forks)"
    self.periodStars.text = "\(value.periodStars) stars " + self.periodDesc
  }
  
  override func bindStyles() {
    super.bindStyles()

    _ = self |> UIView.lens.backgroundColor .~ UIColor.clear

    self.contentView.addSubview(self.card)

    self.contentView.addSubview(self.repoOwnerName)
    self.contentView.addSubview(self.repoFullName)
    self.contentView.addSubview(self.repoDesc)
    self.contentView.addSubview(self.lastLineView)

    self.lastLineView.addSubview(self.pl)
    self.lastLineView.addSubview(self.allStars)
    self.lastLineView.addSubview(self.forks)
    self.lastLineView.addSubview(self.periodStars)
    self.lastLineView.addSubview(self.plIcon)
    self.lastLineView.addSubview(self.allStarsIcon)
    self.lastLineView.addSubview(self.forksIcon)
    self.lastLineView.addSubview(self.periodStarsIcon)
    self.lastLineView.addSubview(self.spacer)

    let views = ["card": self.card,
                 "repoName": self.repoFullName,
                 "ownername": self.repoOwnerName,
                 "desc": self.repoDesc,
                 "plIcon": self.plIcon,
                 "pl": self.pl,
                 "allStarsIcon": self.allStarsIcon,
                 "allStars": self.allStars,
                 "forksIcon": self.forksIcon,
                 "forks": self.forks,
                 "periodStarIcon": self.periodStarsIcon,
                 "periodStars": self.periodStars,
                 "lastLine": self.lastLineView,
                 "spacer": self.spacer]


    let autolayoutStyle = UIView.lens.translatesAutoresizingMaskIntoConstraints .~ false
    _ = Array(views.values) ||> autolayoutStyle

    let iconStyle = UIImageView.lens.contentMode .~ .scaleAspectFit
    _ = [self.plIcon, self.allStarsIcon, self.forksIcon, self.periodStarsIcon] ||> iconStyle


    _ = self.repoFullName |>
      UILabel.lens.font .~ UIFont.ksr_title1()
      >>> UILabel.lens.textColor .~ .blue
      >>> UILabel.lens.textAlignment .~ .center

    _ = self.repoOwnerName |>
      UILabel.lens.font .~ UIFont.ksr_subhead()
      >>> UILabel.lens.textColor .~ .blue
      >>> UILabel.lens.textAlignment .~ .right

    _ = self.repoDesc |>
      UILabel.lens.numberOfLines .~ 10
      >>> UILabel.lens.font .~ UIFont.ksr_body()
      >>> UILabel.lens.contentHuggingPriorityForAxis(.vertical) .~ UILayoutPriorityFittingSizeLevel


    let footnoteStyle = UILabel.lens.font .~ UIFont.ksr_footnote()
      >>> UILabel.lens.textColor .~ .darkGray

    _ = [self.pl, self.allStars, self.forks, self.periodStars] ||> footnoteStyle

    _ = self.plIcon |>
      UIImageView.lens.tintColor .~ .orange

    _ = self.allStarsIcon |>
      UIImageView.lens.tintColor .~ .yellow

    _ = self.periodStarsIcon |>
      UIImageView.lens.tintColor .~ .yellow

    _ = self.forksIcon |>
      UIImageView.lens.tintColor .~ .darkGray

    _ = self.card |>
      cardStyle()
      >>> dropShadowStyle()
      >>> UIView.lens.backgroundColor .~ .white

    let clearBackground = UIView.lens.backgroundColor .~ .clear
    _ = [self.lastLineView, self.spacer] ||> clearBackground


    let cardV = visualConstraintGenerator("V:|-[card]-|")
    let cardH = visualConstraintGenerator("H:|-[card]-|")

    let v1 = visualConstraintGenerator("V:|-(16)-[repoName]-[ownername]-[desc]-[lastLine]-(16)-|", .alignAllCenterX)
    let v2 = visualConstraintGenerator("V:|-[spacer]-|")

    let h1 = visualConstraintGenerator("H:|-[repoName]-|")
    let h2 = visualConstraintGenerator("H:|-(>=0)-[ownername]-(24)-|")
    let h3 = visualConstraintGenerator("H:|-(16)-[desc]-(16)-|")
    let h5 = visualConstraintGenerator("H:|-[lastLine]-|")
    let h4
      = visualConstraintGenerator("H:|-[plIcon]-[pl]-[allStarsIcon]-[allStars]-[forksIcon]-[forks]-[spacer(>=0)]-[periodStarIcon]-[periodStars]-|", .alignAllCenterY)

    let c = cardV >>> cardH >>> v1 >>> v2
    let c2 = c >>> h1 >>> h2 >>> h3 >>> h4 >>> h5
    
    
    let vc = VisualConstraintCollector(views: views) |> c2
    vc.apply()

  }
}



















