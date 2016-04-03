//
//  ViewController.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 06/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import UIKit
import EventKit

class TimePicker: UIDatePicker {
    override init (frame : CGRect) {
        super.init(frame: frame)
        print("init")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    deinit {
        print("deinit")
    }
}

class ViewController: UIViewController, WeekViewDelegate {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var daySelection: WeekView!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var descriptionField: UITextField!

    var startTime: NSDate?
    var endTime: NSDate?
    var event: CalendarEvent?

    @IBAction func skipDay(sender: UIButton) {
        nextDay()
    }

    let START = 1
    let END = 2

    @IBAction func startDateEditing(sender: UITextField) {
        startEditingTime(sender, tag: START, date: startTime)
    }

    @IBAction func endTimeEditing(sender: UITextField) {
        startEditingTime(sender, tag: END, date: endTime)
    }

    func startEditingTime(sender: UITextField, tag: Int, date: NSDate?) {
        let picker = EventTimePicker()
        picker.tag = tag
        picker.date = date ?? daySelection.currentDay().toDate()
        picker.addTarget(self, action: #selector(eventTimeChanged), forControlEvents: UIControlEvents.ValueChanged)
        sender.inputView = picker
    }

    func eventTimeChanged(sender: UIDatePicker) {
        let tag = sender.tag
        updateDateText(tag, date: sender.date)
    }

    func updateDateText(tag: Int, date: NSDate?) {
        print(tag, date)
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
        if let startDate = startTime, endDate = endTime {
            if (startDate.compare(endDate) == NSComparisonResult.OrderedDescending) {
                if (tag == START) {
                    endTimeField.text = text
                    endTime = date
                } else {
                    startTimeField.text = text
                    startTime = date
                }
            }

        }
    }

    @IBAction func clearDay(sender: UIButton) {
        startTimeField.text = ""
        startTime = nil
        endTimeField.text = ""
        endTime = nil
        descriptionField.text = ""
    }

    @IBAction func saveEvent(sender: UIButton) {
        Calendar.persistDay(startTime, endDate: endTime, title: descriptionField.text, existingEvent: event, callback: { [weak self] in
            dispatch_async(dispatch_get_main_queue()) {
              self?.nextDay()
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
        startTimeField.addTarget(self, action: #selector(timeChange), forControlEvents: .EditingDidEnd)
        endTimeField.addTarget(self, action: #selector(timeChange), forControlEvents: .EditingDidEnd)
    }

    func timeChange(textField: UITextField) {
        updateButtonStates()
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

    func dayChanged(ymd: YMD, event: CalendarEvent?) {
        self.event = event
        startTime = event?.startDate
        updateDateText(START, date: startTime)
        endTime = event?.endDate
        updateDateText(END, date: endTime)
        descriptionField.text = event?.title
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM YYYY"
        monthLabel.text = dateFormatter.stringFromDate(ymd.toDate())
        updateButtonStates()
    }

    func updateButtonStates() {
        saveButton.enabled = (startTime != nil && endTime != nil && startTime != endTime) || (startTime == nil && endTime == nil && event != nil)
        clearButton.enabled = startTime != nil || endTime != nil
        endEditing()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        endEditing()
    }

    func endEditing() {
        startTimeField.endEditing(false)
        endTimeField.endEditing(false)
    }

}

