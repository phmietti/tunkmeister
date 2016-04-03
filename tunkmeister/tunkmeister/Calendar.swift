//
//  Calendar.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 27/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import EventKitUI

struct CalendarEvent {
    let startDate: NSDate
    let endDate: NSDate
    let identifier: String
    let title: String

    func startYmd() -> YMD {
        return YMD(date: startDate)
    }
}

struct CalendarStore {
    static var storedEvents: [String] = NSUserDefaults.standardUserDefaults().arrayForKey("events") as? [String] ?? []

    static func removeEventId(eventId: String) {
        storedEvents = storedEvents.filter { $0 != eventId}
        print("removed \(storedEvents.count)")
        NSUserDefaults.standardUserDefaults().setObject(storedEvents, forKey: "events")

    }

    static func saveEventId(eventId: String) {
        storedEvents.append(eventId)
        print("saved \(storedEvents.count)")
        NSUserDefaults.standardUserDefaults().setObject(storedEvents, forKey: "events")
    }

}

struct Calendar {

    static func persistDay(startDate: NSDate?, endDate: NSDate?, title: String?, existingEvent: CalendarEvent?, callback: () -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {
            (granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                do {
                    if let event = existingEvent {
                        print(event.identifier)
                        if let eventToBeRemoved = eventStore.eventWithIdentifier(event.identifier) {
                            print("deleting event")
                            try eventStore.removeEvent(eventToBeRemoved, span: .ThisEvent)
                            CalendarStore.removeEventId(event.identifier)
                        }
                    }
                    if let startDate = startDate, endDate = endDate {
                        let event = EKEvent(eventStore: eventStore)
                        event.title = "tm-event"
                        event.startDate = startDate
                        event.endDate = endDate
                        event.title = title ?? ""
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        try eventStore.saveEvent(event, span: .ThisEvent)
                        CalendarStore.saveEventId(event.eventIdentifier)
                        print("event added " + event.eventIdentifier + " " + NSDateFormatter().stringFromDate(event.startDate))
                    }

                } catch let error as NSError {
                    print("no voe lol \(error.localizedDescription)")
                }
                callback()

            }
        })
    }

    static func getEvents(start: YMD, end: YMD, callback: ([CalendarEvent]) -> Void) {
        print("getting events")
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {
            (granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                let predicate = eventStore.predicateForEventsWithStartDate(start.toDate(), endDate: end.toDate(), calendars: [eventStore.defaultCalendarForNewEvents])
                let events = eventStore.eventsMatchingPredicate(predicate).filter {
                    do {
                        return CalendarStore.storedEvents.contains($0.eventIdentifier)
                    }
                }

                events.forEach {
                    e in print(e.eventIdentifier)
                }
                callback(events.map {
                    e in CalendarEvent(startDate: e.startDate, endDate: e.endDate, identifier: e.eventIdentifier, title: e.title)
                })
            }
        })

    }
}