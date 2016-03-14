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
    @IBOutlet weak var startTimePicker: StartTimePicker!
    @IBOutlet weak var endTimePicker: EndTimePicker!
    
    @IBAction func startTimeChanged(sender: StartTimePicker) {
    }
    
    @IBAction func endTimeChanged(sender: EndTimePicker) {
        
    }
    
    @IBAction func skipDay(sender: UIButton) {
        daySelection.nextDay()
    }
    
    @IBAction func saveEvent(sender: UIButton) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {(granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                let event = EKEvent(eventStore: eventStore)
                event.title = "tunkmeister test"
                let date = self.daySelection.firstDayOfWeek.diffDays(self.daySelection.selection).toDate()
                event.startDate = NSCalendar.currentCalendar().dateBySettingHour(self.startTimePicker.date.hour(), minute: self.startTimePicker.date.minutes(), second: 0, ofDate: date, options: NSCalendarOptions())!
                event.endDate = NSCalendar.currentCalendar().dateBySettingHour(self.endTimePicker.date.hour(), minute: self.endTimePicker.date.minutes(), second: 0, ofDate: date, options: NSCalendarOptions())!
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
            let gesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
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

