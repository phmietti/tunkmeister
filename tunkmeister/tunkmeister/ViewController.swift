//
//  ViewController.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 06/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    @IBOutlet weak var daySelection: WeekView!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    var startTime: NSDate!
    var endTime: NSDate!
   
    
    @IBAction func skipDay(sender: UIButton) {
        daySelection.nextDay()
    }
    
    let START = 1
    let END = 2
    
    @IBAction func startDateEditing(sender: UITextField) {
        startEditingTime(sender, tag: START)
    }
    
    @IBAction func endTimeEditing(sender: UITextField) {
        startEditingTime(sender, tag: END)
    }
    func startEditingTime(sender: UITextField, tag: Int) {
        let picker = UIDatePicker()
        picker.datePickerMode = .Time
        picker.minuteInterval = 15
        picker.tag = tag
        picker.date = daySelection.currentDay().toDate()
        picker.addTarget(self, action: #selector(eventTimeChanged), forControlEvents: UIControlEvents.ValueChanged)
        sender.inputView = picker
        
    }

    func eventTimeChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        switch sender.tag {
        case START:
            startTimeField.text = dateFormatter.stringFromDate(sender.date)
            self.startTime = sender.date
        case END:
            endTimeField.text = dateFormatter.stringFromDate(sender.date)
            self.endTime = sender.date
        default:
            print("Lol")
        }
    }
    
    @IBAction func saveEvent(sender: UIButton) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {(granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                let event = EKEvent(eventStore: eventStore)
                event.title = "tunkmeister test"
                event.startDate = self.startTime
                event.endDate = self.endTime
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
        daySelection.nextDay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let directions: [UISwipeGestureRecognizerDirection] = [.Left, .Right]
        for d in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            gesture.direction = d
            daySelection.addGestureRecognizer(gesture)
        }
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


}

