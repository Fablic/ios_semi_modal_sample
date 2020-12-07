//
//  Copyright © 2020 Rakuten, Inc. All rights reserved.
//

import UIKit
import SemiModal

final class ModalViewController: UIViewController {

    @IBOutlet private weak var contentView: UIView!
}

extension ModalViewController {

    static func instantiateInitialViewControllerFromStoryboard() -> Self {
        return UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
            .instantiateInitialViewController() as! Self
    }
}

extension ModalViewController: SemiModalPresenterDelegate {

    var semiModalContentHeight: CGFloat {
        return contentView.frame.height
    }
}
