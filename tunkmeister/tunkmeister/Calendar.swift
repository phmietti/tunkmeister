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
    let identifier: String?
    let title: String

    func startYmd() -> YMD {
        return YMD(date: startDate)
    }
}

struct Calendar {

    static let identifier = "\u{2063}"

    static func persistDay(startDate: NSDate?, endDate: NSDate?, title: String?, existingEvent: CalendarEvent?, errorCallback: () -> Void, callback: () -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {
            (granted, error) in
            if !granted || error != nil {
                errorCallback()
            } else {
                do {
                    if let event = existingEvent {
                        if let eventToBeRemoved = eventStore.eventWithIdentifier(event.identifier!) {
                            try eventStore.removeEvent(eventToBeRemoved, span: .ThisEvent)
                            CalendarStore.removeEvent(eventToBeRemoved)
                        }
                    }
                    if let startDate = startDate, endDate = endDate {
                        let event = EKEvent(eventStore: eventStore)
                        event.title = "tm-event"
                        event.startDate = startDate
                        event.endDate = endDate
                        event.title = (title ?? "") + identifier
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        try eventStore.saveEvent(event, span: .ThisEvent)
                        CalendarStore.saveEvent(event)
                    }

                } catch {
                    errorCallback()
                }
                callback()

            }
        })
    }

    static func getEvents(start: YMD, end: YMD, errorCallback: () -> Void, callback: ([CalendarEvent]) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {
            (granted, error) in
            if !granted || error != nil {
                errorCallback()
            } else {
                let predicate = eventStore.predicateForEventsWithStartDate(start.toDate(), endDate: end.toDate(), calendars: [eventStore.defaultCalendarForNewEvents])
                let events = eventStore.eventsMatchingPredicate(predicate).filter { event in
                    return CalendarStore.hasEvent(event)
                }
                 callback(events.map {
                    e in CalendarEvent(startDate: e.startDate, endDate: e.endDate, identifier: e.eventIdentifier, title: e.title.substringToIndex(e.title.endIndex.predecessor()))
                })
            }
        })

    }
}
