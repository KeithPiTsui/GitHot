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

  internal var interactor:Interactor? = nil
  internal var backImageView: UIImageView?
  fileprivate var circleView: UIView?
  fileprivate var hintsLabel: UILabel?
  fileprivate var card: UIView?
  fileprivate var blockedCard: UIView?
  fileprivate var loaded = false
  
  internal func set(repo: RepoProfile) {
    self.viewModel.inputs.set(repo: repo)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.hex(0x576B71)

    if let wv = try? DownView() {

      self.view.addSubview(wv)
      wv.translatesAutoresizingMaskIntoConstraints = false
      wv.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
      wv.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
      wv.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
      wv.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

      wv.scrollView.delegate = self
      wv.navigationDelegate = self

      wv.alpha = 0

      self.webView = wv
    }

    self.orignalFrame = self.view.frame
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.loadingAnimating()
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

extension ReadmeViewController {
  fileprivate func loadingAnimating(){
    if loaded { return }

    let center = CGPoint(x: view.bounds.width * 0.5, y: 200)
    let small = CGSize(width: 30, height: 30)
    let frame = CGRect(origin: center, size: small)
    let circle = UIView(frame: frame)
    circle.layer.cornerRadius = circle.frame.width/2
    circle.backgroundColor = UIColor.white
    circle.layer.shadowOpacity = 0.8
    circle.layer.shadowOffset = CGSize.zero

    let cardSizeWidth = self.view.bounds.size.width / 2
    let cardSizeHeight = cardSizeWidth / self.view.bounds.size.ratioW2H
    let cardX = (self.view.bounds.size.width - cardSizeWidth) / 2
    let cardY = center.y - cardSizeHeight * 0.2
    let cardFrame = CGRect(cardX, cardY, cardSizeWidth, cardSizeHeight)
    let card = UIView(frame: cardFrame)
    card.backgroundColor = .white
    card.layer.cornerRadius = 5
    card.layer.shadowOpacity = 0.8
    card.layer.shadowOffset = CGSize.zero


    let blockedCardSizeWidth = self.view.bounds.size.width / 2
    let blockedCardSizeHeight = blockedCardSizeWidth / self.view.bounds.size.ratioW2H
    let blockedCardX = (self.view.bounds.size.width - blockedCardSizeWidth) / 2
    let blockedCardY = cardFrame.origin.y + cardFrame.size.height
    let blockedCardFrame = CGRect(blockedCardX, blockedCardY, blockedCardSizeWidth, blockedCardSizeHeight)
    let blockedCard = UIView(frame: blockedCardFrame)
    blockedCard.backgroundColor = UIColor.hex(0x576B71)

    let label = UILabel()
    _ = label
      |> UILabel.lens.font .~ UIFont.ksr_headline()
      >>> UILabel.lens.text .~ "Drag top down to back"
      >>> UILabel.lens.textColor .~ .white
      >>> UILabel.lens.alpha .~ 1

    if let backView = self.backImageView {
      self.view.addSubview(backView)
      backView.frame = cardFrame
    }


    self.view.addSubview(card)
    self.card = card

    view.addSubview(circle)
    self.circleView = circle

    self.view.addSubview(blockedCard)
    self.blockedCard = blockedCard

    self.view.addSubview(label)

    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    label.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor,
                               constant: 20).isActive = true


    self.hintsLabel = label

    UIView.animate(
      withDuration: 2,
      delay: 0.25,
      options: [.repeat],
      animations: {
        circle.frame.origin.y += 200
        circle.layer.opacity = 0
        card.frame.origin.y += 200
    }
    )


  }
}

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
    self.loaded = true
    UIView.animate(withDuration: 0.5, animations: { 
      self.view.backgroundColor = .white
      self.circleView?.alpha = 0
      self.webView?.alpha = 1
      self.hintsLabel?.alpha = 0
      self.blockedCard?.alpha = 0
      self.card?.alpha = 0
      self.backImageView?.alpha = 0
    }) { _ in
      self.circleView?.removeFromSuperview()
      self.hintsLabel?.removeFromSuperview()
      self.blockedCard?.removeFromSuperview()
      self.card?.removeFromSuperview()
      self.backImageView?.removeFromSuperview()
      self.circleView = nil
      self.hintsLabel = nil
      self.card = nil
      self.blockedCard = nil
      self.backImageView = nil
    }
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


























