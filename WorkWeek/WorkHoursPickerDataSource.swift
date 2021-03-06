//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

import UIKit

/// The Delegate type of WorkDayHoursPickerDataSource
/// The object that conforms will be notified when the user has made a selection
/// from the picker.
protocol PickerResponseForwarder: class {
    func didSelectWork(hours: Double)
}

/// This picker is simple, it just show one list of numbers
/// 0-24 in half hour increments. starting with 0.5, and ending at 23.5
class WorkDayHoursPickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    /// The delegate is called when the user has selected a row.
    weak var delegate: PickerResponseForwarder?

    /// The 15th item in the pickerData is 8.0 our default value.
    static let default8HourIndex = 15


    /// The data for the picker
    let pickerData: [Double] = {
        let str = stride(from: 0.5, to: 24, by: 0.5)
        return Array(str)
    }()

    /// Just one List of numbers
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    /// NOTE: There will only ever be one component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        assert(component == 0, "This should just be one scrolling list of numbers...")
        return pickerData.count
    }

    /// Looks at the data source, and converts the corresponding to a String
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let num = pickerData[row]
        let attributedNum = NSAttributedString(string: "\(num)", attributes: [NSAttributedStringKey.foregroundColor: UIColor.themeText()])
        return attributedNum
    }

    /// Calls up to the PickerResponseForwarder to deliver the event
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectWork(hours: pickerData[row])
    }
}
