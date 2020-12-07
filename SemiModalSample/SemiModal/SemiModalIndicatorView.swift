//
//  Copyright © 2020 Rakuten, Inc. All rights reserved.
//

import UIKit

/// セミモーダルインジケータ
final class SemiModalIndicatorView: UIView {

    // MARK: Initializer

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
}

// MARK: Private Functions
extension SemiModalIndicatorView {

    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = 5.0
        backgroundColor = UIColor.lightGray
    }
}
