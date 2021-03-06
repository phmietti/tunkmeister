//
//  Month.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 11/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import UIKit
import EventKit


func ==(lhs: YMD, rhs: YMD) -> Bool {
    return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
}

protocol WeekViewDelegate {
    func dayChanged(ymd: YMD, event: CalendarEvent?)

    func errorInCalendar()
}


class WeekView: UIView {

    var selection: Int
    var firstDayOfWeek: YMD
    let daysInWeek = 7
    var dayTitleLabels = [UILabel]()
    var dayButtons = [UIButton]()
    var delegate: WeekViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        let date = NSUserDefaults.standardUserDefaults().objectForKey("date") as? NSDate ?? NSDate()
        let ymd = YMD(date: date)
        self.selection = ymd.dayOfWeek() - 1
        self.firstDayOfWeek = ymd.diffDays(1 - self.selection)
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5
        for d in 0 ..< daysInWeek {
            let iterYmd = firstDayOfWeek.diffDays(d)
            let button = UIButton()
            button.backgroundColor = UIColor.clearColor()
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.addTarget(self, action: #selector(daySelected), forControlEvents: .TouchUpInside)
            let title = String(iterYmd.day)
            button.setTitle(title, forState: .Normal)
            button.setTitleColor(UIColor.grayColor(), forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Selected)
            button.setTitleColor(UIColor.blackColor(), forState: [.Selected, .Highlighted])
            let label = UILabel()
            label.backgroundColor = UIColor.clearColor()
            label.text = iterYmd.dayOfWeekString()
            label.textAlignment = .Center
            dayTitleLabels += [label]
            dayButtons += [button]
            addSubview(button)
            addSubview(label)
        }
        updateViewState()
    }

    override func layoutSubviews() {
        let buttonSize = Int(frame.size.height)
        let frameWidth = Int(frame.size.width)
        let buttonWidth = (frameWidth - daysInWeek) / daysInWeek
        var buttonFrame = CGRect(x: 0, y: 20, width: buttonWidth, height: buttonSize - 20)
        for (index, button) in dayButtons.enumerate() {
            let x = CGFloat(index * (buttonWidth + 1))
            buttonFrame.origin.x = x
            button.frame = buttonFrame
        }
        var labelFrame = CGRect(x: 0, y: 0, width: buttonWidth, height: 20)
        for (index, label) in dayTitleLabels.enumerate() {
            let x = CGFloat(index * (buttonWidth + 1))
            labelFrame.origin.x = x
            label.frame = labelFrame
        }
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
    }

    func previousWeek() {
        firstDayOfWeek = firstDayOfWeek.diffDays(-daysInWeek)
        updateViewState()
    }

    func currentDay() -> YMD {
        return firstDayOfWeek.diffDays(selection)
    }

    private func updateViewState() {
        NSUserDefaults.standardUserDefaults().setObject(firstDayOfWeek.diffDays(selection).toDate(), forKey: "date")
        for (index, button) in dayButtons.enumerate() {
            button.selected = index == selection
            dayTitleLabels[index].textColor = button.currentTitleColor
        }
        Calendar.getEvents(firstDayOfWeek,
                end: firstDayOfWeek.diffDays(daysInWeek),
                errorCallback: {
                    [weak self] in
                    self?.delegate?.errorInCalendar()
                },
                callback: {
                    [weak self] events in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let daysInWeek = self?.daysInWeek, firstDayOfWeek = self?.firstDayOfWeek, currentDay = self?.currentDay() {
                            for d in 0 ..< daysInWeek {
                                let iterYmd = firstDayOfWeek.diffDays(d)
                                let title = String(iterYmd.day)
                                let button = self?.dayButtons[d]
                                button?.setTitle(title, forState: .Normal)
                                let dayEvents = events.filter {
                                    (e) in YMD(date: e.startDate) == iterYmd
                                }
                                button?.layer.borderColor = dayEvents.isEmpty ? UIColor.whiteColor().CGColor : UIColor.blackColor().CGColor
                                if (d == self?.selection) {
                                    self?.delegate?.dayChanged(currentDay, event: dayEvents.first)
                                }
                            }
                        }
                    }
                })
    }
}

