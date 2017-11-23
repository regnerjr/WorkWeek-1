//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

import Foundation
import RealmSwift

private struct Pair {
    let start: Event
    let end: Event

    var interval: TimeInterval {
        return DateInterval(start: start.eventTime, end: end.eventTime).duration
    }
}

class DailyObject: Object {

    convenience init(date: Date = Date()) {
        self.init()
        self.date = date
    }

    @objc dynamic var dateString: String?
    @objc dynamic var date: Date? // TODO: Write a migrate to make date non-optional

    private var unWrappedDate: Date {
        // TODO: Will remove this after figure out Realm data migration
        return date!
    }

    private let allEventsRaw = List<Event>()

    var events: [Event] {
        return Array(allEventsRaw)
    }

    var firstEvent: Event? {
        return events.first
    }

    override static func primaryKey() -> String? {
        return #keyPath(DailyObject.dateString)
    }

    func add(_ event: Event) {
        allEventsRaw.append(event)
    }

    func insertArriveWorkOnNextDay() {
        // Check the first event of the next day, if not arriveWork, insert arriveWork
        // at the start of the next day
        guard let startOfNextDay = date!.startOfNextDay else { return }
        let nextDayObject = DataStore.shared.queryDailyObject(for: startOfNextDay)
        let firstEventOfNextDay = nextDayObject?.firstEvent
        if nextDayObject == nil || (firstEventOfNextDay?.kind != .arriveWork) {
            DataStore.shared.saveDataToRealm(for: .arriveWork, startOfNextDay)
        }
    }

    var isAtWork: Bool {
        guard let lastEvent = events.last else {
            return false // no events yet today, not at work
        }
        return lastEvent.kind == NotificationCenter.CheckInEvent.arriveWork
    }

    // if the first event of the day is leftWork
    // and the last event of the previous day is arrive work
    // that means I worked past midnight last night
    var wasAtWork: Bool {
        let firstEvent = events.first
        let previousDailyObject = DataStore.shared.previousDailyObject(fromDate: unWrappedDate)
        let lastEventOfPreviousDay = previousDailyObject?.events.last

        let isFirstEventOfTheDayLeaveWork = firstEvent?.kind == .leaveWork
        let isLastEventOfPreviousDayArriveWork = lastEventOfPreviousDay?.kind == .arriveWork

        if isFirstEventOfTheDayLeaveWork && isLastEventOfPreviousDayArriveWork {
            return true
        }
        return false
    }

    var completedWorkTime: TimeInterval {
        var totalWorkTime: Double = 0.0
        let validPairsDurations = validWorkingDurations.reduce(0) { $0 + $1.interval }
        totalWorkTime += validPairsDurations
        totalWorkTime += timeSoFar()
        totalWorkTime += betweenBeginningOfTheDayAndLeaveWorkDuration()
        totalWorkTime += betweenArriveWorkAndMidnightDuration()
        return totalWorkTime
    }

    // If I worked past midnight last night, add the time interval between
    // beginning of the day (12:00AM) until I leaveWork
    private func betweenBeginningOfTheDayAndLeaveWorkDuration() -> TimeInterval {
        if wasAtWork, let leftWork = events.first {
            let startOfDay = unWrappedDate.startOfDay
            return leftWork.eventTime.timeIntervalSince(startOfDay)
        } else {
            return 0.0
        }
    }

    // If I work pass midnight tonight, add the time interval between
    // arriveWork and midnight (11:59PM)
    private func betweenArriveWorkAndMidnightDuration() -> TimeInterval {
        let now = Date()
        if isAtWork, let arriveWork = events.last {
            // if the last event of the day is arriveWork, and we already past
            // that day, we calculate the duration between arriveWork and 11:59PM
            // else, which means that we are at work and haven't pass midnight
            // we just add the duration between arriveWork and "now" to update
            // the count down view controller
            let endOfDayDate = unWrappedDate.endOfDay
            let isSameDay = Calendar.current.isDate(now, inSameDayAs: unWrappedDate)
            return isSameDay ? 0.0 : endOfDayDate.timeIntervalSince(arriveWork.eventTime)
        } else {
            return 0.0
        }
    }

    // This is where the time accumulates and updates the count down view controller data
    // for the time I am still at work
    private func timeSoFar() -> TimeInterval {
        let now = Date()
        if isAtWork, let arriveWork = events.last {
            let isSameDay = Calendar.current.isDate(now, inSameDayAs: unWrappedDate)
            return isSameDay ? now.timeIntervalSince(arriveWork.eventTime) : 0.0
        } else {
            return 0.0
        }
    }

    var oldcompletedWorkTime: TimeInterval {
        if isAtWork, let arriveWork = events.last {
            let now = Date()
            let priorDurations = validWorkingDurations.reduce(0) { $0 + $1.interval }
            // The date must exist when creating the DailyObject
            guard Calendar.current.isDate(now, inSameDayAs: date!) else {
                // create a 11:59PM date on the DailyObject's date
                let endOfDayDate = date!.endOfDay
                // Check the first event of the next day, if not arriveWork, insert arriveWork
                // at the start of the next day
//                insertArriveWorkOnNextDay() // probaly don't want to modify
                return priorDurations + endOfDayDate.timeIntervalSince(arriveWork.eventTime)
            }
            // if now is no longer the same day as the daily object, append a leave work at time 11:59
            return priorDurations + now.timeIntervalSince(arriveWork.eventTime)
        }
        return validWorkingDurations.reduce(0) { $0 + $1.interval }
    }

    var weekDay: Int? {
        let cal = Calendar.current
        let dateComp = cal.dateComponents(in: .current, from: date!)
        return dateComp.weekday
    }

    private var validWorkingDurations: [Pair] {

        func discardLeadingLeaves(_ list: [Event]) -> [Event] {
            return Array(list.drop(while: { $0.kind == .leaveWork }))
        }

        func discardTrailingArrivals(_ list: [Event]) -> [Event] {
            return Array(list.reversed().drop(while: { $0.kind == .arriveWork}).reversed())
        }

        func discardNoneWorkEvents(_ list: [Event]) -> [Event] {
            return list.filter { $0.kind == .arriveWork || $0.kind == .leaveWork }
        }

        func getPair(_ sanitized: [Event]) -> [Pair] {
            var mutableCopy = sanitized
            guard let arriveWork = findArrival(&mutableCopy) else { return [] }
            guard let leaveWork = findDeparture(&mutableCopy) else { return [] }
            let foundPair = Pair(start: arriveWork, end: leaveWork)
            return [foundPair] + getPair(Array(mutableCopy))
        }

        func findArrival(_ mutableCopy: inout [Event]) -> Event? {
            guard !mutableCopy.isEmpty else { return nil }
            let arriveArray = mutableCopy.prefix { $0.kind == .arriveWork }
            defer {  mutableCopy = Array(mutableCopy.drop { $0.kind == .arriveWork }) }
            return arriveArray.last
        }

        func findDeparture(_ mutableCopy: inout [Event]) -> Event? {
            guard !mutableCopy.isEmpty else { return nil }
            let departure = mutableCopy.removeFirst()
            guard departure.kind == .leaveWork else { return nil }
            defer { mutableCopy = Array(mutableCopy.drop(while: {$0.kind == .leaveWork})) }
            return departure
        }

        return Array(allEventsRaw)
            |> discardLeadingLeaves
            |> discardTrailingArrivals
            |> discardNoneWorkEvents
            |> getPair

    }
}
