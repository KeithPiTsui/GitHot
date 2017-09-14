//
//  MarkupViewerViewModel.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import PaversFRP
import PaversUI
import GHAPI
import Down

internal protocol ReadmeViewControllerViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when vc received a url for markup
  func set(markup url: URL)

  /// Call when vc recived a repo for readme
  func set(repo: RepoProfile)
}

internal protocol ReadmeViewControllerViewModelOutputs {
  var markupString: Signal<String, ErrorEnvelope> {get}
}

internal protocol ReadmeViewControllerViewModelType {
  var inputs: ReadmeViewControllerViewModelInputs { get }
  var outpus: ReadmeViewControllerViewModelOutputs { get }
}


internal final class ReadmeViewControllerViewModel:
ReadmeViewControllerViewModelType,
ReadmeViewControllerViewModelInputs,
ReadmeViewControllerViewModelOutputs {

  init() {
    self.markupString = Signal
      .combineLatest(self.setRepoProfileProperty.signal.skipNil(),
                     self.viewDidLoadProperty.signal)
      .map(first)
      .observeInBackground()
      .flatMap(.concat){AppEnvironment.apiService.repository(of: $0.ownerName, and: $0.repoName)}
      .map{ $0.urls.url.appendingPathComponent("/contents/README.md") }
      .flatMap{ AppEnvironment.apiService.readme(referredBy: $0) }
      .map { try? String(contentsOf: $0.download_url) }
      .skipNil()
  }

  fileprivate let setMarkupURLProperty = MutableProperty<URL?>(nil)
  public func set(markup url: URL) {
    self.setMarkupURLProperty.value = url
  }

  fileprivate let setRepoProfileProperty = MutableProperty<RepoProfile?>(nil)
  public func set(repo: RepoProfile) {
    self.setRepoProfileProperty.value = repo
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty(())
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  internal func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  internal let markupString: Signal<String, ErrorEnvelope>

  internal var inputs: ReadmeViewControllerViewModelInputs { return self }
  internal var outpus: ReadmeViewControllerViewModelOutputs { return self }
}
