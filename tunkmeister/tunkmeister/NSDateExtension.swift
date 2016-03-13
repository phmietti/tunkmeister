//
//  NSDateExtension.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 13/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import Foundation

extension NSDate {
    func hour() -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: self).hour
    }
    
    func minutes() -> Int {
        return NSCalendar.currentCalendar().components(.Minute, fromDate: self).minute
    }
}