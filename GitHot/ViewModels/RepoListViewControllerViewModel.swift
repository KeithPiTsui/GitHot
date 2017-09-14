//
//  RepoHitsCollectionViewControllerViewModel.swift
//  GitHot
//
//  Created by Pi on 24/08/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import PaversFRP
import PaversUI
import GHAPI

internal protocol RepoListViewControllerViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when the view will appear with animated property.
  func viewDidAppear(animated: Bool)

  /// Call when user click on one of the item
  func userDidSelectItem(at indexPath: IndexPath)

  /// Call when loading animation stopped
  func loadingAnimationStopped()
}

internal protocol RepoListViewControllerViewModelOutputs {

  var startLoadingAnimation: Signal<(), NoError> {get}

  var stopLoadingAnimation: Signal<(), NoError> {get}

  var repos: Signal<[RepoProfile], NoError> {get}

  var transitTo: Signal<UIViewController, NoError> {get}
}

internal protocol RepoListViewControllerViewModelType {
  var inputs: RepoListViewControllerViewModelInputs { get }
  var outpus: RepoListViewControllerViewModelOutputs { get }
}


internal final class RepoListViewControllerViewModel:
  RepoListViewControllerViewModelType,
  RepoListViewControllerViewModelInputs,
RepoListViewControllerViewModelOutputs {

  init() {

    self.startLoadingAnimation = self.viewDidAppearProperty.signal.take(first:1).map{_ in ()}

    let repos = self.viewDidLoadProperty.signal.observe(on: QueueScheduler())
      .map { _ in AppEnvironment.apiService.trendingRepository(of: .daily, with: "swift").single()?.value}
      .skipNil()

    self.repos
      = Signal.combineLatest(repos,
                             self.viewDidLoadProperty.signal,
                             self.loadingAnimationStoppedProperty.signal)
        .map(first)
        .map{ $0.map(RepoProfile.init(trendingRepository:))}

    let transitToRepoReadmeVC = Signal
      .combineLatest(self.repos, self.userDidSelectItemProperty.signal.skipNil())
      .map { (repos, indexPath) in repos[indexPath.item] }

    let vc = transitToRepoReadmeVC
      .map{ (rp) -> UIViewController in
        let vc = ReadmeViewController()
        vc.set(repo: rp)
        return vc
    }

    self.transitTo = vc

    self.stopLoadingAnimation = repos.map{_ in ()}

  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  internal func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  fileprivate let viewDidAppearProperty = MutableProperty<Bool?>(nil)
  internal func viewDidAppear(animated: Bool) {
    self.viewDidAppearProperty.value = animated
  }

  fileprivate let userDidSelectItemProperty = MutableProperty<IndexPath?>(nil)
  internal func userDidSelectItem(at indexPath: IndexPath) {
    self.userDidSelectItemProperty.value = indexPath
  }

  fileprivate let loadingAnimationStoppedProperty = MutableProperty()
  internal func loadingAnimationStopped() {
    self.loadingAnimationStoppedProperty.value = ()
  }

  internal let startLoadingAnimation: Signal<(), NoError>
  internal let stopLoadingAnimation: Signal<(), NoError>

  internal let repos: Signal<[RepoProfile], NoError>
  internal let transitTo: Signal<UIViewController, NoError>

  internal var inputs: RepoListViewControllerViewModelInputs { return self }
  internal var outpus: RepoListViewControllerViewModelOutputs { return self }
}

extension RepoProfile {
  init(trendingRepository rp: TrendingRepository) {
    self = RepoProfile(ownerName: rp.repoOwner ?? "",
                       repoName: rp.repoName ?? "",
                       repoDesc: rp.repoDesc ?? "",
                       plName: rp.programmingLanguage ?? "",
                       allStars: rp.totoalStars ?? 0,
                       periodStars: rp.periodStars ?? 0,
                       forks: rp.periodStars ?? 0)
  }
}
