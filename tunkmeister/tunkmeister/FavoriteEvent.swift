//
// Created by Petri Miettinen on 16/05/16.
// Copyright (c) 2016 phmietti. All rights reserved.
//

import Foundation

struct FavoriteEvent {
    let startHour: Int
    let startMinutes: Int
    let endHour: Int
    let endMinutes: Int
    let title: String?

    func encode() -> NSDictionary {
        var dictionary: Dictionary = Dictionary<String, AnyObject>()
        dictionary["startHour"] = startHour
        dictionary["startMinutes"] = startMinutes
        dictionary["endHour"] = endHour
        dictionary["endMinutes"] = endMinutes
        if let t = title {
            dictionary["title"] = t
        }
        return dictionary
    }

    func matches(startDateMaybe: NSDate?, endDateMaybe: NSDate?, titleMaybe: String?) -> Bool {
        if let startDate = startDateMaybe, endDate = endDateMaybe {
            return startDate.hour() == startHour && startDate.minutes() == startMinutes && endDate.hour() == endHour && endDate.minutes() == endMinutes && titleMaybe == title
        } else {
            return false
        }
    }

    // Decode
    static func decode(dictionary: NSDictionary) -> FavoriteEvent {
        let startHour = dictionary["startHour"] as! Int
        let startMinutes = dictionary["startMinutes"] as! Int
        let endHour = dictionary["endHour"] as! Int
        let endMinutes = dictionary["endMinutes"] as! Int
        let title = dictionary["title"] as? String
        return FavoriteEvent(startHour: startHour, startMinutes: startMinutes, endHour: endHour, endMinutes: endMinutes, title: title)
    }

    func startMinutesFromMidnight() -> Int {
        return self.startHour * 60 + self.startMinutes
    }
}
