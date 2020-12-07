//
//  Copyright © 2020 Rakuten, Inc. All rights reserved.
//

import UIKit
import SemiModal

class MainViewController: UIViewController {

    private var semiModalPresenter = SemiModalPresenter()

    @IBAction func openModalButtonDidTap(_ sender: Any) {
        let viewController = ModalViewController.instantiateInitialViewControllerFromStoryboard()
        semiModalPresenter.viewController = viewController
        present(viewController, animated: true)
    }
}

