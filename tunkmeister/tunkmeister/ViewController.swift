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
    
    @IBAction func saveEvent(sender: UIButton) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: {(granted, error) in
            if !granted || error != nil {
                print("error")
            } else {
                let event = EKEvent(eventStore: eventStore)
                event.title = "tunkmeister test"
                let date = self.daySelection.monday.diffDays(self.daySelection.selection).toDate()
                event.startDate = NSCalendar.currentCalendar().dateBySettingHour(8, minute: 30, second: 0, ofDate: date, options: NSCalendarOptions())!
                event.endDate = NSCalendar.currentCalendar().dateBySettingHour(16, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
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
            
            
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

