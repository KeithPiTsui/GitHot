//
//  RepoHitsViewController.swift
//  GitHot
//
//  Created by Pi on 22/08/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import PaversUI
import PaversFRP

final class RepoListViewController: UIViewController {

  fileprivate let viewModel: RepoListViewControllerViewModelType
    = RepoListViewControllerViewModel()

  fileprivate let datasource = RepoHitsDatasource()
  fileprivate let gradientView = UIGradientView()
  fileprivate let layout = SpringCollectionViewFlowLayout()
  fileprivate var collectionView:UICollectionView!
  fileprivate lazy var rainingController: RainingController = { RainingController(view: self.gradientView) }()

  fileprivate let cloudImageView = UIImageView()
  fileprivate let flipCloudImageView = UIImageView()
  fileprivate let waveImageView = UIImageView()

  fileprivate var displayLink: CADisplayLink!

  let interactor = Interactor()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
    self.collectionView.delegate = self
    self.collectionView.dataSource = self.datasource
    self.collectionView.register(RepoCollectionViewCell.self,
                                 forCellWithReuseIdentifier: RepoCollectionViewCell.defaultReusableId)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  override func bindStyles() {
    super.bindStyles()

    let image = UIImage(named: "Cloud")!

    self.cloudImageView.image = image
    self.cloudImageView.frame = CGRect(-image.size.width,
                                       50,
                                       image.size.width,
                                       image.size.height)

    self.flipCloudImageView.image = UIImage(cgImage: image.cgImage!,
                                            scale: image.scale,
                                            orientation: UIImageOrientation.upMirrored)
    self.flipCloudImageView.frame = CGRect(UIScreen.main.bounds.size.width,
                                           40,
                                           image.size.width * 0.75,
                                           image.size.height * 0.75)
    self.flipCloudImageView.alpha = 0.8

    self.rainingController.rainyRect = self.view.frame
      |> CGRect.lens.origin.x .~ 30
      >>> CGRect.lens.origin.y .~ (30 + image.size.height * 0.75)
      >>> CGRect.lens.size.width .~ (self.view.frame.width - 60)

    let waveImage = UIImage(named: "Wave")!
    let waveImagewidth = UIScreen.main.bounds.size.width + 30
    let waveImageHeight = waveImagewidth * (waveImage.size.height / waveImage.size.width)
    self.waveImageView.image = waveImage
    self.waveImageView.frame = CGRect(-15,
                                      UIScreen.main.bounds.size.height,
                                      waveImagewidth,
                                      waveImageHeight)

    self.view.addSubview(self.gradientView)
    self.view.addSubview(self.cloudImageView)
    self.view.addSubview(self.flipCloudImageView)
    self.view.addSubview(self.waveImageView)
    self.view.addSubview(self.collectionView)

    _ = self.gradientView
      |> gradientViewStyleRandomColor(numberOfColors: 3)
      >>> UIGradientView.lens.frame .~ self.view.frame

    _ = self.collectionView
      |> UICollectionView.lens.backgroundColor .~ .clear

    let views: [String: Any] = ["cv": self.collectionView, "top": self.topLayoutGuide, "bottom": self.bottomLayoutGuide]
    let h = visualConstraintGenerator("H:|[cv]|")
    let v = visualConstraintGenerator("V:[top][cv][bottom]")
    let cons = VisualConstraintCollector(views: views) |> h >>> v
    cons.apply()

  }

  func update() {
    let waving = sin(CACurrentMediaTime() * 2 * Double.pi / 2) * 7.5 - 7.5
    _ = self.waveImageView |> UIView.lens.frame.origin.x .~ CGFloat(waving)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outpus.startLoadingAnimation.observeForUI().observeValues { [weak self] in
      UIView.animate(withDuration: 0.6,
                     animations: {
                      guard let frame = self?.cloudImageView.frame else { return }
                      let finalFrame = frame
                        |> CGRect.lens.origin.x .~ 30
                      self?.cloudImageView.frame = finalFrame

                      guard let otherFrame = self?.flipCloudImageView.frame else { return }
                      let ohterFinalFrame = otherFrame
                        |> CGRect.lens.origin.x .~ (UIScreen.main.bounds.size.width - 30 - otherFrame.width)
                      self?.flipCloudImageView.frame = ohterFinalFrame

                      guard let waveFrame = self?.waveImageView.frame else { return }
                      let waveFinalFrame = waveFrame
                        |> CGRect.lens.origin.y .~ (UIScreen.main.bounds.size.height - waveFrame.size.height)
                      self?.waveImageView.frame = waveFinalFrame
      }) { _ in
        self?.rainingController.start()
        guard let vc = self else { return }
        vc.displayLink = CADisplayLink(target: vc, selector: #selector(vc.update))
        vc.displayLink.add(to:  RunLoop.current, forMode: .defaultRunLoopMode)
      }
    }

    self.viewModel.outpus.stopLoadingAnimation.observeForUI().observeValues {  [weak self] in
      self?.rainingController.stop()
      self?.displayLink.invalidate()
      self?.displayLink = nil
      UIView.animate(withDuration: 0.6, animations: {
        guard let frame = self?.cloudImageView.frame else { return }
        let finalFrame = frame
          |> CGRect.lens.origin.x .~ (-frame.size.width)
        self?.cloudImageView.frame = finalFrame

        guard let otherFrame = self?.flipCloudImageView.frame else { return }
        let ohterFinalFrame = otherFrame
          |> CGRect.lens.origin.x .~ UIScreen.main.bounds.size.width
        self?.flipCloudImageView.frame = ohterFinalFrame

        guard let waveFrame = self?.waveImageView.frame else { return }
        let waveFinalFrame = waveFrame
          |> CGRect.lens.origin.y .~ (UIScreen.main.bounds.size.height + waveFrame.size.height)
        self?.waveImageView.frame = waveFinalFrame
      }){ _ in self?.viewModel.inputs.loadingAnimationStopped() }
    }

    self.viewModel.outpus.repos.observeForUI().observeValues { [weak self] (repos) in
      self?.datasource.set(items: repos)
      self?.collectionView.performBatchUpdates({ self?.collectionView.insertSections(IndexSet(integer: 0))})
    }

    self.viewModel.outpus.transitTo.observeForUI().observeValues { [weak self] (vc) in
        self?.present(vc, animated: true, completion: nil)
        vc.transitioningDelegate = self
        if let mkvc = vc as? ReadmeViewController {
          mkvc.interactor = self?.interactor
        }
    }
  }

  fileprivate var itemSizes = [IndexPath:CGSize]()
  fileprivate let testCell: RepoCollectionViewCell = {
    let cell = RepoCollectionViewCell()
    cell.bindStyles()
    return cell
  }()
}

extension RepoListViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      didSelectItemAt indexPath: IndexPath) {
    self.viewModel.inputs.userDidSelectItem(at: indexPath)
  }

}

extension RepoListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let size = self.itemSizes[indexPath] { return size }
    if let value = self.datasource.valueSnapshot[indexPath.section][indexPath.item] as? RepoProfile {
      self.testCell.configureWith(value: value)

      let c = NSLayoutConstraint(item: self.testCell.contentView,
                                 attribute: .width,
                                 relatedBy: .equal,
                                 toItem: nil,
                                 attribute: .notAnAttribute,
                                 multiplier: 1,
                                 constant: self.view.frame.size.width)
      self.testCell.contentView.addConstraint(c)

      let size = self.testCell.systemLayoutSizeFitting(CGSize(self.view.frame.size.width, 0))
      self.testCell.contentView.removeConstraint(c)
      let width = self.view.frame.size.width
      self.itemSizes[indexPath] = CGSize(width, size.height)
      return size
    } else {
      let width = self.view.frame.size.width
      let size = CGSize(width, width / Styles.goldenRatio)
      self.itemSizes[indexPath] = size
      return size
    }

  }
}

extension RepoListViewController: UIViewControllerTransitioningDelegate {
  func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
    return DismissAnimator()
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
    return self.interactor.hasStarted ? self.interactor : nil
  }
}

















