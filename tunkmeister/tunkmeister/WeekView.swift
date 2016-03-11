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
    let days = 7
    var dayTitleLabels = [UILabel]()
    var dayButtons = [UIButton]()
    
    required init?(coder aDecoder: NSCoder) {
        let date = NSDate()
        self.selection = 0
        let ymd = YMD(date: date)
        let monday = ymd.diffDays(1 - ymd.dayOfWeek())
        super.init(coder: aDecoder)
        for d in 0..<days {
            let iterYmd = monday.diffDays(d)
            let button = UIButton()
            button.backgroundColor = UIColor.clearColor()
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.addTarget(self, action: "daySelected:", forControlEvents: .TouchDown)
            let title = String(iterYmd.day)
            button.setTitle(title, forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
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
        var buttonFrame = CGRect(x: 0, y: 10, width: buttonSize, height: buttonSize - 15)
        for (index, button) in dayButtons.enumerate() {
            let x = CGFloat(index * (buttonSize + 5))
            buttonFrame.origin.x = x
            button.frame = buttonFrame
        }
        var labelFrame = CGRect(x: 0, y: 0, width: buttonSize, height: 10)
        for (index, label) in dayTitleLabels.enumerate() {
            let x = CGFloat(index * (buttonSize + 5))
            labelFrame.origin.x = x
            label.frame = labelFrame
        }
        updateButtonSelectedState()
    }
    
    
    
    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + 5) * days
        return CGSize(width: width, height: buttonSize)
    }
    
    func daySelected(button: UIButton) {
        selection = dayButtons.indexOf(button)!
        print(selection)
        updateButtonSelectedState()
    }
    
    func updateButtonSelectedState() {
        for (index, button) in dayButtons.enumerate() {
            button.selected = index == selection
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
