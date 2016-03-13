//
//  EventTimePIcker.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 12/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import UIKit

class EventTimePicker: UIDatePicker {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.datePickerMode = .Time
        self.minuteInterval = 15
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

class StartTimePicker: EventTimePicker {
    
}

class EndTimePicker: EventTimePicker {
    
}
