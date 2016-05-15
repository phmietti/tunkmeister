//
//  NSDateExtension.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 13/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import Foundation

extension NSDate {
    func year() -> Int {
        return NSCalendar.currentCalendar().component(.Year, fromDate: self)
    }

    func month() -> Int {
         return NSCalendar.currentCalendar().component(.Month, fromDate: self)
    }

    func hour() -> Int {
        return NSCalendar.currentCalendar().component(.Hour, fromDate: self)
    }
    
    func minutes() -> Int {
        return NSCalendar.currentCalendar().component(.Minute, fromDate: self)
    }
}