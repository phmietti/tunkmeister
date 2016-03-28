//
//  Calendar.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 27/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import EventKitUI

struct Calendar {
    
    static func saveEvent(startDate: NSDate, endDate: NSDate, callback: () -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {(granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                let event = EKEvent(eventStore: eventStore)
                event.title = "tm-event"
                event.startDate = startDate
                event.endDate = endDate
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.saveEvent(event, span: .ThisEvent)
                    print("event added " + event.eventIdentifier + " " + NSDateFormatter().stringFromDate(event.startDate))
                }
                catch let error as NSError {
                    print("no voe lol \(error.localizedDescription)")
                }
                callback()
                
            }
        })
    }
    
    static func getEvents(start: YMD, end: YMD, callback: ([EKEvent]) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {(granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                let predicate = eventStore.predicateForEventsWithStartDate(start.toDate(), endDate: end.toDate(), calendars: [eventStore.defaultCalendarForNewEvents])
                let events = eventStore.eventsMatchingPredicate(predicate) .filter { (e) in e.title == "tm-event" }
                callback(events)
            }
        })
        
    }
}