//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

import UIKit
import Reusable
import Realm
import RealmSwift

// NOTE: This must match the padding on the storyboard!
// ex: |-padding-|StackView|-padding-| , where | the outer pipe is the scroll View
private let padding: CGFloat = 8

protocol SettingsMainProtocol: class {
    func didTapWorkMap(nav: UINavigationController)
    func didTapHomeMap(nav: UINavigationController)
    func didTapSelectHours(nav: UINavigationController)
    func didTapDone()
}

final class SettingsViewController: UIViewController, SettingsStoryboard {

    weak var delegate: SettingsMainProtocol?

    @IBOutlet var mainStackViewContentWidth: NSLayoutConstraint!

    @IBOutlet weak var work: UIButton!
    @IBOutlet weak var home: UIButton!

    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!
    @IBOutlet weak var sunday: UIButton!

    @IBOutlet weak var targetHoursButton: TwoLabelButton!
    @IBOutlet weak var notificationsSegment: UISegmentedControl!

    var user: User!
    private var notificationToken: NotificationToken! = nil


    // MARK: View Lifecycle

    override func viewDidLoad() {
        assert(user != nil, "Error! User object shoudl be provided to the VC by the coordinator")
        super.viewDidLoad()
        title = "Settings"
        setMainContentStackViewEqualToPhoneWidth()
        configureStyle(of: work, home)
        configureStyle(of: monday, tuesday, wednesday, thursday, friday, saturday, sunday)

        configureSelectedButtons(with: user.weekdays)
        configureNotificationsSegment(with: user.notificationChoice)

        targetHoursButton.rightTitle = "\(user.hoursInWorkDay)"

        notificationToken = user.addNotificationBlock { change in
            switch change {
            case .change(let properties):
                if let hours = properties.first(where: { $0.name == "hoursInWorkDay" }),
                    let hoursNumber = hours.newValue as? Double {
                    self.targetHoursButton.rightTitle = "\(hoursNumber)"
                }
            default:
                return
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track(.pageView(.settingsMain))
    }


    func setMainContentStackViewEqualToPhoneWidth() {
        mainStackViewContentWidth.constant = UIScreen.main.bounds.width - padding * 2
    }

    func configureStyle(of buttons: UIButton...) {
        for button in buttons {
            button.configureForDefaultStyle()
        }
    }


    // MARK: Actions

    @IBAction func didTapDay(_ sender: UIButton) {
        //toggle
        sender.isSelected = !sender.isSelected
        saveButtonUpdates()
    }

    @IBAction func homeMapPressed(_ sender: UIButton) {
        delegate?.didTapHomeMap(nav: navigationController!)
    }

    @IBAction func workMapPressed(_ sender: UIButton) {
        delegate?.didTapWorkMap(nav: navigationController!)
    }

    @IBAction func didTapSelectHours(_ sender: TwoLabelButton) {
        delegate?.didTapSelectHours(nav: navigationController!)
    }

    @IBAction func didTapDone(_ sender: UIButton) {
        delegate?.didTapDone()
    }

    // MARK: Members (RE-asses this name?...

    func configureNotificationsSegment(with choice: User.NotificationChoice) {
        notificationsSegment.setSelected(choice)
    }

    @IBAction func didTapNotifications(_ segment: UISegmentedControl) {
        RealmManager.shared.updateNotificationsChoice(for: user, with: segment.choice)
    }

    func configureSelectedButtons(with days: User.Weekdays) {
        sunday.isSelected = days.contains(.sunday)
        monday.isSelected = days.contains(.monday)
        tuesday.isSelected = days.contains(.tuesday)
        wednesday.isSelected = days.contains(.wednesday)
        thursday.isSelected = days.contains(.thursday)
        friday.isSelected = days.contains(.friday)
        saturday.isSelected = days.contains(.saturday)
    }

    func saveButtonUpdates() {
        var updated = user.weekdays
        if sunday.isSelected {
            updated.insert(.sunday)
        } else {
            updated.remove(.sunday)
        }

        if monday.isSelected {
            updated.insert(.monday)
        } else {
            updated.remove(.monday)
        }

        if tuesday.isSelected {
            updated.insert(.tuesday)
        } else {
            updated.remove(.tuesday)
        }

        if wednesday.isSelected {
            updated.insert(.wednesday)
        } else {
            updated.remove(.wednesday)
        }

        if thursday.isSelected {
            updated.insert(.thursday)
        } else {
            updated.remove(.thursday)
        }

        if friday.isSelected {
            updated.insert(.friday)
        } else {
            updated.remove(.friday)
        }

        if saturday.isSelected {
            updated.insert(.saturday)
        } else {
            updated.remove(.saturday)
        }

        RealmManager.shared.update(user: user, with: updated)
    }

}

extension UIButton {
    func configureForDefaultStyle() {
        layer.cornerRadius = 10.0
        backgroundColor = .gray
        setTitleColor(.white, for: .normal)
    }
}

extension UISegmentedControl {
    func setSelected(_ index: User.NotificationChoice) {
        selectedSegmentIndex = index.rawValue
    }
    var choice: User.NotificationChoice {
        return User.NotificationChoice(rawValue: selectedSegmentIndex) ?? .none
    }
}
