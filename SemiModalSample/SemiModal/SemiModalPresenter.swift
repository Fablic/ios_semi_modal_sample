//
//  Copyright © 2020 Rakuten, Inc. All rights reserved.
//

import UIKit

public protocol SemiModalPresenterDelegate: AnyObject {

    /// ViewControllerからモーダルの高さを決定させる場合に使用する
    var semiModalContentHeight: CGFloat { get }
}

/// ViewControllerをセミモーダルで表示する
public final class SemiModalPresenter: NSObject {

    // MARK: Public Properties

    /// presentするViewControllerを設定する
    public weak var viewController: UIViewController? {
        didSet {
            if let viewController = viewController {
                viewController.modalPresentationStyle = .custom
                viewController.transitioningDelegate = self
                dismissInteractiveTransition.viewController = viewController
                dismissInteractiveTransition.addPanGesture(to: [viewController.view, indicator, overlayView])
            }
        }
    }

    // MARK: Private Properties

    /// オーバーレイ
    private lazy var overlayView: SemiModalOverlayView = {
        let overlayView = SemiModalOverlayView()
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlayDidTap(_:))))
        return overlayView
    }()

    /// モーダル上部に設置されるインジケータ
    private lazy var indicator: SemiModalIndicatorView = {
        let indicator = SemiModalIndicatorView()
        indicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(indicatorDidTap(_:))))
        return indicator
    }()

    /// インタラクティブなdismiss transition
    private let dismissInteractiveTransition = SemiModalDismissInteractiveTransition()
}

// MARK: - Gestures
extension SemiModalPresenter {

    /// オーバーレイタップ
    /// - Parameter sender:
    @objc private func overlayDidTap(_ sender: AnyObject) {
        viewController?.dismiss(animated: true, completion: nil)
    }

    /// インジケータタップ
    /// - Parameter sender:
    @objc private func indicatorDidTap(_ sender: AnyObject) {
        viewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SemiModalPresenter: UIViewControllerTransitioningDelegate {

    /// 画面遷移開始時に呼ばれる。カスタムビューを使用して表示する。
    /// - Parameters:
    ///   - presented: 呼び出し先ViewController
    ///   - presenting: 呼び出し元ViewController
    ///   - source: presentメソッドがプレゼンテーションプロセスを開始するために呼び出されたViewController
    /// - Returns: UIPresentationController
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SemiModalPresentationController(presentedViewController: presented,
                                               presenting: presenting,
                                               overlayView: overlayView,
                                               indicator: indicator)
    }

    /// dismiss時に呼ばれる。dismissのアニメーション指定。
    /// - Parameter dismissed: dismissされるViewController
    /// - Returns: UIViewControllerAnimatedTransitioning
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SemiModalDismissAnimatedTransition()
    }

    /// インタラクティブなdismissを制御する。
    /// - Parameter animator: animationController(forDismissed:)で指定したアニメーター
    /// - Returns: UIViewControllerInteractiveTransitioning
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard dismissInteractiveTransition.isInteractiveDismalTransition else { return nil }
        return dismissInteractiveTransition
    }
}
