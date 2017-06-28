//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

import UIKit
import Reusable

final class CountdownViewController: UIViewController {

    @IBOutlet weak var countdownDisplay: UILabel!

    @IBAction func leftHomeNotificationPressed(_ sender: UIButton) {
        Log.log("Left Home Notification Pressed")
        NotificationCenterManager.shared.postLeftHomeNotification()
    }

    @IBAction func arriveWorkNotificationPressed(_ sender: UIButton) {
        Log.log("Arrive Work Notification Pressed")
        NotificationCenterManager.shared.postArriveWorkNotification()
    }

    @IBAction func leftWorkNotificationPressed(_ sender: UIButton) {
        Log.log("Left Work Notification Pressed")
        NotificationCenterManager.shared.postLeftWorkNotification()
    }

    @IBAction func arriveHomeNotification(_ sender: UIButton) {
        Log.log("Arrive Home Notification Pressed")
        NotificationCenterManager.shared.postArriveHomeNotification()
    }

    var timer = Timer()
    var timeRemaining = 28800

    override func viewDidLoad() {
        super.viewDidLoad()
        //By default, start count down from 8 hours
        runTimer()
    }

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: (#selector(CountdownViewController.updateTimer(_:))),
                                     userInfo: nil, repeats: true)
    }

    func updateTimer(_ timer: Timer) {
        if timeRemaining < 1 {
            timer.invalidate()
            //Time is up, do some stuff
        } else {
            timeRemaining -= 1
            countdownDisplay.text = timeString(time: TimeInterval(timeRemaining))
        }
    }

    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

extension CountdownViewController: ActivityStoryboard {
}

