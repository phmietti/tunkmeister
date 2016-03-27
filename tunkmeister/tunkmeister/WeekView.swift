//
//  Month.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 11/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import UIKit

struct YMD {
    let year: Int
    let month: Int
    let day: Int
    
    init(date: NSDate) {
        year = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: date).year
        month = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: date).month
        day = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date).day
    }
    
    func toDate() -> NSDate {
        let c = NSDateComponents()
        c.year = year
        c.month = month
        c.day = day
    
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

class WeekView: UIView {

    var selection: Int
    var firstDayOfWeek: YMD
    let daysInWeek = 7
    var dayTitleLabels = [UILabel]()
    var dayButtons = [UIButton]()
    
    required init?(coder aDecoder: NSCoder) {
        let date = NSDate()
        let ymd = YMD(date: date)
        self.selection = ymd.dayOfWeek() - 1
        self.firstDayOfWeek = ymd.diffDays(-self.selection)
        super.init(coder: aDecoder)
        for d in 0..<daysInWeek {
            let iterYmd = firstDayOfWeek.diffDays(d)
            let button = UIButton()
            button.backgroundColor = UIColor.clearColor()
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.addTarget(self, action: #selector(daySelected), forControlEvents: .TouchUpInside)
            let title = String(iterYmd.day)
            button.setTitle(title, forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.setTitleColor(UIColor.redColor(), forState: .Selected)
            button.setTitleColor(UIColor.redColor(), forState: [.Selected, .Highlighted])
            let label = UILabel()
            label.backgroundColor = UIColor.clearColor()
            label.text = iterYmd.dayOfWeekString()
            label.textAlignment = .Center
            dayTitleLabels += [label]
            dayButtons += [button]
            addSubview(button)
            addSubview(label)
        }
    }
    
    override func layoutSubviews() {
        let buttonSize = Int(frame.size.height)
        let frameWidth = Int(frame.size.width)
        let buttonWidth = frameWidth / daysInWeek
        var buttonFrame = CGRect(x: 0, y: 10, width: buttonWidth, height: buttonSize - 15)
        for (index, button) in dayButtons.enumerate() {
            let x = CGFloat(index * (buttonWidth + 1))
            buttonFrame.origin.x = x
            button.frame = buttonFrame
        }
        var labelFrame = CGRect(x: 0, y: 0, width: buttonWidth, height: 10)
        for (index, label) in dayTitleLabels.enumerate() {
            let x = CGFloat(index * (buttonWidth + 1))
            labelFrame.origin.x = x
            label.frame = labelFrame
        }
        updateViewState()
    }
    
    
    func daySelected(button: UIButton) {
        button.selected = true
        selection = dayButtons.indexOf(button)!
        updateViewState()
    }
    
    func nextDay() {
        if (selection == daysInWeek - 1) {
            firstDayOfWeek = firstDayOfWeek.diffDays(daysInWeek)
            selection = 0
        } else {
            selection += 1
        }
        updateViewState()
    }
    
    func nextWeek() {
        firstDayOfWeek = firstDayOfWeek.diffDays(daysInWeek)
        updateViewState()
        UIView.transitionWithView(self, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in }) { (success) -> Void in
        }
    }
    
    func previousWeek() {
        firstDayOfWeek = firstDayOfWeek.diffDays(-daysInWeek)
        updateViewState()
        UIView.transitionWithView(self, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in }) { (success) -> Void in
        }
    }
    
    func currentDay() -> YMD {
        return firstDayOfWeek.diffDays(selection)
    }
    
    private func updateViewState() {
        for (index, button) in dayButtons.enumerate() {
            button.selected = index == selection
        }
        for d in 0..<daysInWeek {
            let iterYmd = firstDayOfWeek.diffDays(d)
            let title = String(iterYmd.day)
            dayButtons[d].setTitle(title, forState: .Normal)
        }
    }
}

