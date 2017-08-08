//
//  Copyright © 2017 Spark App Studio. All rights reserved.
//

@testable import WorkWeek
import RealmSwift
import XCTest

class DailyObjectTests: XCTestCase {

    var dailyObject: DailyObject!


    override func setUp() {
        super.setUp()
        dailyObject = DailyObject()
    }

    override func tearDown() {
        dailyObject = nil
        super.tearDown()
    }

    func testWorkTimeIsZeroForNoEvents() {
        XCTAssertEqual(dailyObject.events.count, 0)
        XCTAssertEqual(dailyObject.workTime, 0.0)
    }

    func testWorkTimeIsZeroForOneArrivalAtWork() {
        let arrival = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 0.0))
        dailyObject.allEventsRaw.append(arrival)
        XCTAssertEqual(dailyObject.events.count, 1)
        XCTAssertEqual(dailyObject.workTime, 0.0)
    }

    func testWorkTimeIsZeroForOneDepartureFromWork() {
        let departure = Event(kind: .leaveWork, time: Date(timeIntervalSince1970: 0.0))
        dailyObject.allEventsRaw.append(departure)
        XCTAssertEqual(dailyObject.events.count, 1)
        XCTAssertEqual(dailyObject.workTime, 0.0)
    }

    func testWorkTimeIsCountedForAValidPair() {
        let arrival = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 0.0))
        let departure = Event(kind: .leaveWork, time: Date(timeIntervalSince1970: 10.0)) //work for 10 seconds
        dailyObject.allEventsRaw.append(arrival)
        dailyObject.allEventsRaw.append(departure)
        XCTAssertEqual(dailyObject.events.count, 2)
        XCTAssertEqual(dailyObject.workTime, 10.0)
    }

    func testWorkTimeNotCountedForThreeArrivalsInValidItems() {
        // i.e. Arrive, Arrive

        let arrival1 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 0.0))
        let arrival2 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 10.0))
        let arrival3 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 20.0))
        dailyObject.allEventsRaw.append(arrival1)
        dailyObject.allEventsRaw.append(arrival2)
        dailyObject.allEventsRaw.append(arrival3)
        XCTAssertEqual(dailyObject.events.count, 3)
        XCTAssertEqual(dailyObject.workTime, 0.0)
    }


    func testWorkTimeIsCountedForAValidPairSurroundedByInValidItems() {

        // i.e. Arrive, Arrive, Leave, Leave
        //                 |------|  this duration is counted

        let arrival1 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 0.0))
        let arrival2 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 10.0))
        let departure1 = Event(kind: .leaveWork, time: Date(timeIntervalSince1970: 20.0)) //work for 10 seconds
        let departure2 = Event(kind: .leaveWork, time: Date(timeIntervalSince1970: 30.0))
        dailyObject.allEventsRaw.append(arrival1)
        dailyObject.allEventsRaw.append(arrival2)
        dailyObject.allEventsRaw.append(departure1)
        dailyObject.allEventsRaw.append(departure2)
        XCTAssertEqual(dailyObject.events.count, 4)
        XCTAssertEqual(dailyObject.workTime, 10.0)
    }

    func testWorkTimeIsCountedForTwoValidPairSurroundedByInValidItems() {

        // i.e. Arrive1, Arrive2, Leave1, Leave2, Arrive3, Arrive4, Leave3, Leave4
        //                 |------|                      |------|
        // returns the sum of these 2 valid intervals

        let arrival1 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 0.0))
        let arrival2 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 10.0))
        let departure1 = Event(kind: .leaveWork, time: Date(timeIntervalSince1970: 20.0)) //work for 10 seconds
        let departure2 = Event(kind: .leaveWork, time: Date(timeIntervalSince1970: 30.0))
        let arrival3 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 40.0))
        let arrival4 = Event(kind: .arriveWork, time: Date(timeIntervalSince1970: 50.0))
        let departure3 = Event(kind: .leaveWork, time: Date(timeIntervalSince1970: 60.0)) //work for 10 seconds
        let departure4 = Event(kind: .leaveWork, time: Date(timeIntervalSince1970: 70.0))

        dailyObject.allEventsRaw.append(arrival1)
        dailyObject.allEventsRaw.append(arrival2)
        dailyObject.allEventsRaw.append(departure1)
        dailyObject.allEventsRaw.append(departure2)
        dailyObject.allEventsRaw.append(arrival3)
        dailyObject.allEventsRaw.append(arrival4)
        dailyObject.allEventsRaw.append(departure3)
        dailyObject.allEventsRaw.append(departure4)

        XCTAssertEqual(dailyObject.events.count, 8)
        XCTAssertEqual(dailyObject.workTime, 20.0)
    }

}
