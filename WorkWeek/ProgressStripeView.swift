//
// Copyright © 2017 Spark App Studio All rights reserved.
//

import UIKit

class ProgressStripeView: UIView {

    public var percentage: Double?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.white
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let percent = percentage else { return }
        let context = UIGraphicsGetCurrentContext()!
        let fillColor = UIColor.homeGreen().cgColor
        context.setFillColor(fillColor)
        let progressHeight = CGFloat(percent) * rect.height
        let div = rect.divided(atDistance: progressHeight, from: CGRectEdge.maxYEdge)
        context.fill(div.slice)
    }

}
