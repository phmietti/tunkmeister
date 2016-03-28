//
//  ViewController.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 06/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController, WeekViewDelegate {

    @IBOutlet weak var daySelection: WeekView!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    var startTime: NSDate!
    var endTime: NSDate!
    var event: EKEvent?
    
    @IBAction func skipDay(sender: UIButton) {
        nextDay()
    }
    
    let START = 1
    let END = 2
    
    @IBAction func startDateEditing(sender: UITextField) {
        startEditingTime(sender, tag: START, date: startTime, minimumDate: nil, maximumDate: endTime)
    }
    
    @IBAction func endTimeEditing(sender: UITextField) {
        startEditingTime(sender, tag: END, date: endTime, minimumDate: startTime, maximumDate: nil)
    }
    
    func startEditingTime(sender: UITextField, tag: Int, date: NSDate?, minimumDate: NSDate?, maximumDate: NSDate?) {
        let picker = UIDatePicker()
        picker.datePickerMode = .Time
        picker.minuteInterval = 15
        picker.tag = tag
        if (date != nil) {
            picker.date = date!
        }
        picker.minimumDate = minimumDate
        picker.maximumDate = maximumDate
        picker.date = date ?? daySelection.currentDay().toDate()
        picker.addTarget(self, action: #selector(eventTimeChanged), forControlEvents: UIControlEvents.ValueChanged)
        picker.addTarget(self, action: #selector(closePicker), forControlEvents: .EditingDidEnd)
        sender.inputView = picker
    }
    
    func closePicker(sender: UIDatePicker) {
        sender.resignFirstResponder()
    }
    
    func eventTimeChanged(sender: UIDatePicker) {
        let tag = sender.tag
        updateDateText(tag, date: sender.date)
    }
    
    func updateDateText(tag: Int, date: NSDate?) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        let text = date != nil ? dateFormatter.stringFromDate(date!) : ""
        switch tag {
        case START:
            startTimeField.text = text
            self.startTime = date
        case END:
            endTimeField.text = text
            self.endTime = date
        default:
            print("Lol")
        }
    }
    
    @IBAction func saveEvent(sender: UIButton) {
        Calendar.saveEvent(startTime, endDate: endTime, existingEvent: event, callback: {
            dispatch_async(dispatch_get_main_queue()) {
              self.nextDay()
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let directions: [UISwipeGestureRecognizerDirection] = [.Left, .Right]
        for d in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            gesture.direction = d
            daySelection.addGestureRecognizer(gesture)
        }
        daySelection.delegate = self
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Left:
            daySelection.nextWeek()
        case UISwipeGestureRecognizerDirection.Right:
            daySelection.previousWeek()
        default :
            print("voe lol")
        }
        print(sender.direction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextDay() {
        self.daySelection.nextDay()
        
    }
    
    func dayChanged(ymd: YMD, event: EKEvent?) {
        self.event = event
        startTime = event?.startDate
        updateDateText(START, date: startTime)
        endTime = event?.endDate
        updateDateText(END, date: endTime)
    }
   
}

