//
//  MarkupViewerViewController.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Down
import WebKit
import PaversFRP
import PaversUI

internal final class ReadmeViewController: UIViewController {

  fileprivate let viewModel: ReadmeViewControllerViewModelType = ReadmeViewControllerViewModel()
  fileprivate var webView: DownView?

  var interactor:Interactor? = nil

  internal func set(markup url: URL) {
    self.viewModel.inputs.set(markup: url)
  }

  internal func set(repo: RepoProfile) {
    self.viewModel.inputs.set(repo: repo)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if let wv = try? DownView(frame: CGRect.zero, markdownString: "") {
      self.view.addSubview(wv)
      self.webView = wv
      wv.translatesAutoresizingMaskIntoConstraints = false
      wv.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
      wv.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
      wv.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
      wv.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
      wv.scrollView.delegate = self
    }

    self.orignalFrame = self.view.frame
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  override func bindStyles() {
    super.bindStyles()
  }

  override func bindViewModel() {
    super.bindViewModel()
    self.viewModel.outpus.markupString.observeResult { [weak self] (result) in
      guard let markup = result.value else { print("error: \(result.error!)"); return }
      try? self?.webView?.update(markdownString: markup)
    }
  }

  var orignalFrame: CGRect = .zero

  func handleGesture(_ y: CGFloat, state: DraggingState) {

    DispatchQueue.main.async {
      guard let interactor = self.interactor else { return }
      if y > 0 {
        interactor.hasStarted = false
        interactor.cancel()
        self.view.frame = self.orignalFrame
        return
      }

      let percentThreshold:CGFloat = 0.4
      let height = UIScreen.main.bounds.size.height

      let progress = min( abs(y) / (height / 4), 1)

      switch state {
      case .began:
        interactor.hasStarted = true
        self.dismiss(animated: true, completion: nil)
      case .changed:
        if interactor.hasStarted == false { return }
        interactor.shouldFinish = progress > percentThreshold
        interactor.update(progress)
      case .ended:
        interactor.hasStarted = false
        if interactor.shouldFinish { interactor.finish() } else {
          interactor.cancel()
          self.view.frame = self.orignalFrame
        }
      }
    }
  }

}

enum DraggingState {
  case began
  case changed
  case ended
}

extension ReadmeViewController: UIWebViewDelegate {

}

extension ReadmeViewController: UIScrollViewDelegate {

  // began
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.handleGesture(scrollView.bounds.origin.y, state: .began)
  }

  // changed
  func scrollViewDidScroll(_ scrollView: UIScrollView) {// any offset changes
    self.handleGesture(scrollView.bounds.origin.y, state: .changed)
  }

  // ended
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.handleGesture(scrollView.bounds.origin.y, state: .ended)
  }
}


























