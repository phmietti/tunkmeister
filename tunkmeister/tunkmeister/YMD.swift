//
// Created by Petri Miettinen on 16/05/16.
// Copyright (c) 2016 phmietti. All rights reserved.
//

import Foundation

struct YMD: Equatable {
    let year: Int
    let month: Int
    let day: Int

    init(date: NSDate) {
        year = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: date).year
        month = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: date).month
        day = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date).day
    }

    func toDate() -> NSDate {
        return toDate(0, minutes: 0)
    }

    func toDate(hour: Int, minutes: Int) -> NSDate {
        let c = NSDateComponents()
        c.year = year
        c.month = month
        c.day = day
        c.hour = hour
        c.minute = minutes

        return NSCalendar.currentCalendar().dateFromComponents(c)!
    }

    func diffDays(diff: Int) -> YMD {
        let date = toDate()
        let newDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: diff, toDate: date, options: NSCalendarOptions(rawValue: 0))!
        return YMD(date: newDate)
    }

    func dayOfWeek() -> Int {
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: toDate()).weekday
    }

    func dayOfWeekString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.stringFromDate(toDate())
    }

}

