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
        initConfig()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initConfig()
    }

    func initConfig() {
        self.datePickerMode = .Time
        self.minuteInterval = 15

    }




}