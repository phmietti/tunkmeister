//
//  Calendar.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 27/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import EventKitUI

struct Calendar {

    static func saveEvent(startDate: NSDate?, endDate: NSDate?, title: String?, existingEvent: EKEvent?, callback: () -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {
            (granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                do {
                    if let event = existingEvent {
                        let predicate = eventStore.predicateForEventsWithStartDate(event.startDate, endDate: event.endDate, calendars: nil)
                        let events = eventStore.eventsMatchingPredicate(predicate)
                        if (events.count == 0) {
                            print("did not find any events")
                        }
                        try events.forEach {
                            event in
                            try eventStore.removeEvent(event, span: .ThisEvent)
                        }

                    }
                    if let startDate = startDate, endDate = endDate {
                        let event = EKEvent(eventStore: eventStore)
                        event.title = "tm-event"
                        event.startDate = startDate
                        print("adding")
                        print(startDate)
                        event.endDate = endDate
                        print(endDate)
                        event.title = title ?? ""
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        try eventStore.saveEvent(event, span: .ThisEvent)
                        print("event added " + event.eventIdentifier + " " + NSDateFormatter().stringFromDate(event.startDate))
                    }

                } catch let error as NSError {
                    print("no voe lol \(error.localizedDescription)")
                }
                callback()

            }
        })
    }

    static func getEvents(start: YMD, end: YMD, callback: ([EKEvent]) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {
            (granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                let predicate = eventStore.predicateForEventsWithStartDate(start.toDate(), endDate: end.toDate(), calendars: [eventStore.defaultCalendarForNewEvents])
                let events = eventStore.eventsMatchingPredicate(predicate)
                callback(events)
            }
        })

    }
}