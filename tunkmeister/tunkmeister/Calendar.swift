//
//  Calendar.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 27/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import EventKitUI

struct Calendar {
 
    static func saveEvent(startDate: NSDate, endDate: NSDate) {
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
                    print("event added " + event.eventIdentifier)
                }
                catch let error as NSError {
                    print("no voe lol \(error.localizedDescription)")
                }
            }
        })
    }
}