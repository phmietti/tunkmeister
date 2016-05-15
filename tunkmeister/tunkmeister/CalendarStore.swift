//
// Created by Petri Miettinen on 15/05/16.
// Copyright (c) 2016 phmietti. All rights reserved.
//

import Foundation
import EventKitUI

struct CalendarStore {
    static let format = "%04d%02d-"

    static var storedEvents: [String] = CalendarStore.fetchStoredEvents()

    private static func fetchStoredEvents() -> [String] {
        let yearBeforeLast = String(NSDate().year() - 2)
        return (NSUserDefaults.standardUserDefaults().arrayForKey("events") as? [String] ?? []).filter {
            e in return String(e.characters.prefix(4)) >= yearBeforeLast

        }
    }

    static func removeEvent(event: EKEvent) {
        let eventIdentifier = createEventIdentifier(event)
        storedEvents = storedEvents.filter {
            $0 != eventIdentifier
        }
        NSUserDefaults.standardUserDefaults().setObject(storedEvents, forKey: "events")
    }

    static func saveEvent(event: EKEvent) {
        storedEvents.append(createEventIdentifier(event))
        NSUserDefaults.standardUserDefaults().setObject(storedEvents, forKey: "events")
    }


    static func hasEvent(event: EKEvent) -> Bool {
        let eventIdentifier = createEventIdentifier(event)
        return storedEvents.contains {
            $0 == eventIdentifier
        }
    }

    private static func createEventIdentifier(event: EKEvent) -> String {
        return String(format: format, event.startDate.year(), event.startDate.month()) + event.eventIdentifier
    }
}
