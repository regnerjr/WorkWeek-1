//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

import UIKit

class AppCoordinator {

    let navigationController: UINavigationController

    init(with navController: UINavigationController) {
        self.navigationController = navController
    }

    func start() {
        let initial = OnboardPageViewController.instantiate()
        navigationController.setViewControllers([initial], animated: false)
        navigationController.isNavigationBarHidden = true
    }

}
