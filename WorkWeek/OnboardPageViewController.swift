//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

import UIKit

protocol OnboardingPageViewControllerDelegate: class {
    func notificationsPageIsFinished()
}

final class OnboardPageViewController: UIPageViewController, OnboardingStoryboard {

    var orderedViewControllers = [OnboardWelcomeViewController.instantiate(),
                        OnboardExplainViewController.instantiate(),
                        OnboardLocationViewController.instantiate(),
                        OnboardNotifyViewController.instantiate()]

    lazy var manager: PageManager = {
        return PageManager(viewControllers: self.orderedViewControllers)
    }()

    // TODO: Need to wire up the calling of these methods.
    weak var pvcDelegate: OnboardingPageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = manager
        dataSource = manager

        guard let firstVC = orderedViewControllers.first else {
            assertionFailure("No pages in array")
            return
        }

        setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        extendPageViewContent(view: view)
    }

    func extendPageViewContent(view: UIView) {
        // Iterate through subviews and make their frame as big as this controller frame.
        // This stretches the content below the pageVC controls (the dots) and covers the black empty background
        for subview in view.subviews where subview is UIScrollView {
            subview.frame = view.frame
        }
    }
}
