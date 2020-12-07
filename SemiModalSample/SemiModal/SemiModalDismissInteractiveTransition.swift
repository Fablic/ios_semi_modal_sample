//
//  Copyright © 2020 Rakuten, Inc. All rights reserved.
//

import UIKit

/// セミモーダルのインタラクティブなdismiss transition制御
final class SemiModalDismissInteractiveTransition: UIPercentDrivenInteractiveTransition {

    // MARK: Private Properties

    /// 表示しているViewController
    weak var viewController: UIViewController?

    /// 遷移中かどうか
    private(set) var isInteractiveDismalTransition = false

    /// 完了閾値(0 ~ 1.0)
    private let percentCompleteThreshold: CGFloat = 0.3

    ///  ジェスチャーの方向
    private var gestureDirection = GestureDirection.down

    // MARK: Override functions

    override func cancel() {
        completionSpeed = self.percentCompleteThreshold
        super.cancel()
    }

    override func finish() {
        completionSpeed = 1.0 - self.percentCompleteThreshold
        super.finish()
    }
}

// MARK: - Pan Gesture
extension SemiModalDismissInteractiveTransition {

    /// ジェスチャーの方向
    enum GestureDirection {
        case up
        case down

        init(recognizer: UIPanGestureRecognizer, view: UIView) {
            let velocity = recognizer.velocity(in: view)
            self = velocity.y <= 0 ? .up : .down
        }
    }

    /// Panジェスチャーをつける
    /// - Parameter viewController: 対象のViewController
    func addPanGesture(to views: [UIView]) {
        views.forEach {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dismissalPanGesture(recognizer:)))
            panGesture.delegate = self
            $0.addGestureRecognizer(panGesture)
        }
    }

    /// Panジェスチャー
    /// - Parameter recognizer:
    @objc private func dismissalPanGesture(recognizer: UIPanGestureRecognizer) {
        guard let viewController = viewController else { return }

        isInteractiveDismalTransition = recognizer.state == .began || recognizer.state == .changed

        switch recognizer.state {
        case .began:
            gestureDirection = GestureDirection(recognizer: recognizer, view: viewController.view)
            if gestureDirection == .down {
                viewController.dismiss(animated: true, completion: nil)
            }
        case .changed:
            // インタラクティブな制御のために、Viewの高さに応じた画面更新を行う
            let translation = recognizer.translation(in: viewController.view)
            var progress = translation.y / viewController.view.bounds.size.height
            switch gestureDirection {
            case .up:
                progress = -max(-1.0, max(-1.0, progress))
            case .down:
                progress = min(1.0, max(0, progress))
            }
            update(progress)
        case .cancelled, .ended:
            if percentComplete > percentCompleteThreshold {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SemiModalDismissInteractiveTransition: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // UIScrollViewのときはpan gestureとコンフリクトしないようにする
        if otherGestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer.view is UIScrollView {
            return true
        } else {
            return false
        }
    }
}
