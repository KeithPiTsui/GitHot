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
  
  internal func set(repo: RepoProfile) {
    self.viewModel.inputs.set(repo: repo)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white

    if let wv = try? DownView() {

      self.view.addSubview(wv)
      wv.translatesAutoresizingMaskIntoConstraints = false
      wv.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
      wv.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
      wv.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
      wv.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

      wv.scrollView.delegate = self
      wv.navigationDelegate = self

      self.webView = wv
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

  fileprivate var orignalFrame: CGRect = .zero
}

//extension ReadmeViewController {
//
//  override var preferredStatusBarStyle: UIStatusBarStyle {
//
//    guard var targetViewController = self.presentingViewController else {
//      return .lightContent
//    }
//
//    while let parentViewController = targetViewController.parent {
//      targetViewController = parentViewController
//    }
//
//    while let childViewController = targetViewController.childViewControllerForStatusBarStyle {
//      targetViewController = childViewController
//    }
//
//    return targetViewController.preferredStatusBarStyle
//  }
//
//  override var prefersStatusBarHidden: Bool {
//
//    guard var targetViewController = self.presentingViewController else {
//      return false
//    }
//
//    while let parentViewController = targetViewController.parent {
//      targetViewController = parentViewController
//    }
//
//    while let childViewController = targetViewController.childViewControllerForStatusBarHidden {
//      targetViewController = childViewController
//    }
//
//    return targetViewController.prefersStatusBarHidden
//  }
//}


// MARK: - WebView navigation handling

extension ReadmeViewController: WKNavigationDelegate {
  /*! @abstract Decides whether to allow or cancel a navigation.
   @param webView The web view invoking the delegate method.
   @param navigationAction Descriptive information about the action
   triggering the navigation request.
   @param decisionHandler The decision handler to call to allow or cancel the
   navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
   @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
   */
  @available(iOS 8.0, *)
  public func webView(_ webView: WKWebView,
                      decidePolicyFor navigationAction: WKNavigationAction,
                      decisionHandler: @escaping (WKNavigationActionPolicy)
    -> Swift.Void) {
    print("\(#function)--\(navigationAction)")
    decisionHandler(.allow)
  }


  /*! @abstract Invoked when a main frame navigation starts.
   @param webView The web view invoking the delegate method.
   @param navigation The navigation.
   */
  @available(iOS 8.0, *)
  public func webView(_ webView: WKWebView,
                      didStartProvisionalNavigation navigation: WKNavigation!) {
    print("\(#function)--\(navigation)")
  }


  /*! @abstract Invoked when an error occurs while starting to load data for
   the main frame.
   @param webView The web view invoking the delegate method.
   @param navigation The navigation.
   @param error The error that occurred.
   */
  @available(iOS 8.0, *)
  public func webView(_ webView: WKWebView,
                      didFailProvisionalNavigation navigation: WKNavigation!,
                      withError error: Error) {
    print("\(#function)--\(navigation.description)")
  }


  /*! @abstract Invoked when content starts arriving for the main frame.
   @param webView The web view invoking the delegate method.
   @param navigation The navigation.
   */
  @available(iOS 8.0, *)
  public func webView(_ webView: WKWebView,
                      didCommit navigation: WKNavigation!) {
    print("\(#function)--\(navigation.description)")
  }


  /*! @abstract Invoked when a main frame navigation completes.
   @param webView The web view invoking the delegate method.
   @param navigation The navigation.
   */
  @available(iOS 8.0, *)
  public func webView(_ webView: WKWebView,
                      didFinish navigation: WKNavigation!) {
    print("\(#function)--\(navigation.description)")
  }


  /*! @abstract Invoked when an error occurs during a committed main frame
   navigation.
   @param webView The web view invoking the delegate method.
   @param navigation The navigation.
   @param error The error that occurred.
   */
  @available(iOS 8.0, *)
  public func webView(_ webView: WKWebView,
                      didFail navigation: WKNavigation!,
                      withError error: Error) {
    print("\(#function)--\(navigation.description)--\(error)")
  }


  /*! @abstract Invoked when the web view needs to respond to an authentication challenge.
   @param webView The web view that received the authentication challenge.
   @param challenge The authentication challenge.
   @param completionHandler The completion handler you must invoke to respond to the challenge. The
   disposition argument is one of the constants of the enumerated type
   NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
   the credential argument is the credential to use, or nil to indicate continuing without a
   credential.
   @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
   */
  @available(iOS 8.0, *)
  public func webView(_ webView: WKWebView,
                      didReceive challenge: URLAuthenticationChallenge,
                      completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?)
    -> Swift.Void) {
    print("\(#function)--\(challenge)")
    completionHandler(.performDefaultHandling, nil)
  }


  /*! @abstract Invoked when the web view's web content process is terminated.
   @param webView The web view whose underlying web content process was terminated.
   */
  @available(iOS 9.0, *)
  public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
      print("\(#function)")
  }
}


// MARK: - Drag down to back handling

extension ReadmeViewController: UIScrollViewDelegate {
  fileprivate enum DraggingState {
    case began
    case changed
    case ended
  }

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

  fileprivate func handleGesture(_ y: CGFloat, state: DraggingState) {
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


























