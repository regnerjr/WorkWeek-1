//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

import UIKit
import Reusable

protocol CountdownViewDelegate: class {
    func countdownPageDidTapSettings()
}


protocol CountdownData {
    var timeLeftInDay: TimeInterval { get }
    var timeLeftInWeek: TimeInterval { get }
}
struct CountDown: CountdownData {
    var timeLeftInDay: TimeInterval {
        return RealmManager.shared.getUserTimeLeft()
    }
    var timeLeftInWeek: TimeInterval {
        let weekly = RealmManager.shared.queryWeeklyObject(for: Date())!
        return weekly.totalWorkTime
    }
}

//    struct FakeDataForTesting: CountdownData {
//        var timeLeftInDay: TimeInterval {
//            // 5 hours, 37 Minutes, 10 seconds
//            return 5 * 60 * 60 + 37 * 60 + 10
//        }
//        var timeLeftInWeek: TimeInterval {
//             // 15 hours, 27 min, 10 sec
//            return 15 * 60 * 60 + 27 * 60 + 10
//        }
//    }

//    let timeLeftInDay: TimeInterval
//    let timeLeftInWeek: TimeInterval
//
//    let targetTime: TimeInterval
//
//    let sundayHours: TimeInterval
//    let mondayHours: TimeInterval
//    let tuesdayHours: TimeInterval
//    let wednesdayHours: TimeInterval
//    let thursdayHours: TimeInterval
//    let fridayHours: TimeInterval
//    let saturdayHours: TimeInterval


final class CountdownViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var countdownDisplay: UILabel!
    @IBOutlet weak var weekTimeDisplay: UILabel!

    // MARK: IBActions
    @IBAction func didTapSettings(_ sender: UIButton) {
        delegate?.countdownPageDidTapSettings()
    }

    weak var delegate: CountdownViewDelegate?

    var data: CountdownData = CountDown()

    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTimer(timer)

        #if DEBUG
        // To get shake gesture
        self.becomeFirstResponder()
        #endif
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track(.pageView(.activityCountdown))
    }

    #if DEBUG
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
            return true
    }

    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.navigationController?.presentDevSettingsAlertController()
        }
    }
    #endif

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 30,
                                     target: self,
                                     selector: (#selector(CountdownViewController.updateTimer(_:))),
                                     userInfo: nil, repeats: true)
    }

    lazy var hourMinuteFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

    lazy var hoursFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour]
        return formatter
    }()

    @objc func updateTimer(_ timer: Timer) {
        countdownDisplay.text = hourMinuteFormatter.string(from: data.timeLeftInDay)
        let weekHours = hoursFormatter.string(from: data.timeLeftInWeek)!
        weekTimeDisplay.text = "\(weekHours) work hours left in the week"
    }
}

extension CountdownViewController: ActivityStoryboard {

}

