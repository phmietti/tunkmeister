//
//  Month.swift
//  tunkmeister
//
//  Created by Petri Miettinen on 11/03/16.
//  Copyright © 2016 phmietti. All rights reserved.
//

import UIKit

class MonthView: UIView {

    let days = 7
    var dayButtons = [UIButton]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for d in 0..<days {
            let button = UIButton()
            button.backgroundColor = UIColor.clearColor()
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.blackColor().CGColor
            let title = String(d + 1)
            button.setTitle(title, forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            dayButtons += [button]
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        let buttonSize = Int(frame.size.height)
        print(buttonSize)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        for (index, button) in dayButtons.enumerate() {
            let x = CGFloat(index * (buttonSize + 5))
            buttonFrame.origin.x = x
            button.frame = buttonFrame
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + 5) * days
        return CGSize(width: width, height: buttonSize)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

