//
//  Copyright © 2020 Rakuten, Inc. All rights reserved.
//

import UIKit

/// セミモーダル表示のレイアウト実装
final class SemiModalPresentationController: UIPresentationController {

    // MARK: Override Properties

    /// 表示transitionの終わりのViewのframe
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        var presentedViewFrame = CGRect.zero
        let containerBounds = containerView.bounds
        presentedViewFrame.size = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width
        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
        return presentedViewFrame
    }

    // MARK: Private Properties

    /// オーバーレイ
    private let overlay: SemiModalOverlayView

    /// インジケータ
    private let indicator: SemiModalIndicatorView

    /// セミモーダルの高さのデフォルト比率
    private let presentedViewControllerHeightRatio: CGFloat = 0.5

    // MARK: Initializer

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, overlayView: SemiModalOverlayView, indicator: SemiModalIndicatorView) {
        self.overlay = overlayView
        self.indicator = indicator
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    // MARK: Override Functions

    /// 表示されるViewのサイズ
    /// - Parameters:
    ///   - container: コンテナ
    ///   - parentSize: 親Viewのサイズ
    /// - Returns: サイズ
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        // delegateで高さが指定されていれば、そちらを優先する
        if let delegate = presentedViewController as? SemiModalPresenterDelegate {
            return CGSize(width: parentSize.width, height: delegate.semiModalContentHeight)
        }
        // 上記でなければ、高さは比率で計算する
        return CGSize(width: parentSize.width, height: parentSize.height * self.presentedViewControllerHeightRatio)
    }

    /// Subviewsのレイアウト
    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView else { return }

        // overlay
        // containerViewと同じ大きさで、一番上のレイヤーに挿入する
        overlay.frame = containerView.bounds
        containerView.insertSubview(overlay, at: 0)

        // presentedView
        // frameの大きさ設定、左上と右上を角丸にする
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 10.0
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // indicator
        // 中央上部に配置する
        indicator.frame = CGRect(x: 0, y: 0, width: 60, height: 8)
        presentedViewController.view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: presentedViewController.view.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: presentedViewController.view.topAnchor, constant: -16),
            indicator.widthAnchor.constraint(equalToConstant: indicator.frame.width),
            indicator.heightAnchor.constraint(equalToConstant: indicator.frame.height)
        ])
    }

    /// presentation transition 開始
    override func presentationTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.overlay.isActive = true
        }, completion: nil)
    }

    /// dismiss transition 開始
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.overlay.isActive = false
        }, completion: nil)
    }

    /// dismiss transition 終了
    /// - Parameter completed:
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlay.removeFromSuperview()
        }
    }
}
