//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

import UIKit
import CoreLocation

struct CountDownHeaderData: CountdownData {

    var calculator: UserHoursCalculator { return DataStore.shared.getUserCalculator }

    var timeLeftInDay: TimeInterval {
        return calculator.userTimeLeftToday
    }

    var percentOfWorkRemaining: Double {
        return calculator.percentOfWorkRemaining
    }

    var timeLeftInWeek: TimeInterval {
        return calculator.userTimeLeftInWeek
    }
}

class ActivityCoordinator: NSObject, SettingsCoordinatorDelegate, UINavigationControllerDelegate {

    let navigationController: UINavigationController
    let locationManager: CLLocationManager

    var childCoordinators = NSMutableArray()


    init(with navController: UINavigationController,
         manager: CLLocationManager) {
        self.navigationController = navController
        self.locationManager = manager
        super.init()
        self.navigationController.delegate = self
    }

    func start(animated: Bool) {
        Log.log()

        navigationController.isNavigationBarHidden = true

        let countdownVC = ActivityViewController.instantiate()
        countdownVC.headerData = CountDownHeaderData()
        countdownVC.delegate = self
        let weeks = DataStore.shared.queryAllObjects(ofType: WeeklyObject.self)
        countdownVC.tableViewData = ActivityTableViewDSD(with: weeks,
                                                          marginProvider: countdownVC,
                                                          action: showWeeklyViewController)
        #if DEBUG
            countdownVC.debugDelegate = self
        #endif

        if animated {
            navigationController.viewControllers.insert(countdownVC, at: 0)
            navigationController.popWithFadeAnimation()
        } else {
            navigationController.setViewControllers([countdownVC], animated: false)
        }
    }

    func showSettings() {

        guard let user = getUserFromRealm() else {
            showErrorAlert()
            return
        }

        let settingsCoordinator = SettingsCoordinator(with: navigationController,
                                                      manger: locationManager,
                                                      user: user,
                                                      delegate: self)
        childCoordinators.add(settingsCoordinator)
        settingsCoordinator.start()
    }

    func settingsFinished(with coordinator: SettingsCoordinator) {
        childCoordinators.remove(coordinator)
    }

    func showWeeklyViewController(for week: WeeklyObject) {
        let weeklyVC = WeeklyOverviewViewController(nibName: nil, bundle: nil)
        weeklyVC.weekObject = week
        navigationController.pushViewController(weeklyVC, animated: true)
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is ActivityViewController {
            navigationController.isNavigationBarHidden = true
        } else {
            navigationController.isNavigationBarHidden = false
        }
    }

}

extension ActivityCoordinator: UserGettable {
    var vcForPresentation: UIViewController {
        return navigationController
    }
}

extension ActivityCoordinator: CountdownViewDelegate {
    func countdownPageDidTapSettings() {
        showSettings()
    }
}


#if DEBUG
extension ActivityCoordinator: DebugMenuShowing {
    func showDebugMenu() {
        navigationController.presentDevSettingsAlertController()
    }
}
#endif
