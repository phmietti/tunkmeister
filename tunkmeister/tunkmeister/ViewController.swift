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
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}


class FavoriteEventCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }


}

class ViewController: UIViewController, WeekViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var daySelection: WeekView!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var favoritesView: UICollectionView!
    @IBOutlet weak var favoriteButton: UIButton!

    var startTime: NSDate?
    var endTime: NSDate?
    var event: CalendarEvent?
    var favorites: Array<FavoriteEvent>
    let shortDateFormatter = NSDateFormatter()
    let monthFormatter = NSDateFormatter()

    required init?(coder aDecoder: NSCoder) {
        shortDateFormatter.timeStyle = .ShortStyle
        monthFormatter.dateFormat = "MMM YYYY"
        self.favorites = (NSUserDefaults.standardUserDefaults().arrayForKey("favorites") as? Array<NSDictionary> ?? Array()).map {
            (dict) -> FavoriteEvent in FavoriteEvent.decode(dict)
        }
        self.favorites.sortInPlace { $0.startMinutesFromMidnight() < $1.startMinutesFromMidnight() }
        super.init(coder: aDecoder)
    }

    @IBAction func skipDay(sender: UIButton) {
        nextDay()
    }

    let START = 1
    let END = 2

    @IBAction func startDateEditing(sender: UITextField) {
        startEditingTime(sender, tag: START, date: startTime)
    }

    @IBAction func clickFavorite(sender: UIButton) {
        if (sender.selected) {
            if let i = findSelectedFavoriteIndex() {
                self.favorites.removeAtIndex(i)
                if let paths = self.favoritesView.indexPathsForSelectedItems() {
                    self.favoritesView.deleteItemsAtIndexPaths(paths)
                }
            }
        } else if let s = startTime, e = endTime {
            self.favorites.append(FavoriteEvent(startHour: s.hour(), startMinutes: s.minutes(), endHour: e.hour(), endMinutes: e.minutes(), title: descriptionField.text))
            self.favorites.sortInPlace { $0.startMinutesFromMidnight() < $1.startMinutesFromMidnight() }
            self.favoritesView.reloadData()
            self.favoritesView.selectItemAtIndexPath(NSIndexPath(forRow: self.favorites.count - 1, inSection: 0), animated: false, scrollPosition: .None)
        }
        self.updateButtonStates()
        NSUserDefaults.standardUserDefaults().setObject(favorites.map {
            f -> NSDictionary in f.encode()
        }, forKey: "favorites")

    }

    @IBAction func endTimeEditing(sender: UITextField) {
        startEditingTime(sender, tag: END, date: endTime)
    }

    func startEditingTime(sender: UITextField, tag: Int, date: NSDate?) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))

        let picker: UIDatePicker = UIDatePicker(frame: CGRectMake(0, 0, 0, 0))
        picker.datePickerMode = .Time
        picker.minuteInterval = 15
        picker.tag = tag
        picker.date = date ?? daySelection.currentDay().toDate()

        picker.addTarget(self, action: #selector(eventTimeChanged), forControlEvents: UIControlEvents.ValueChanged)

        inputView.addSubview(picker)
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width / 2) - (100 / 2), 0, 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        doneButton.frame = CGRectMake(250.0, 10.0, 70.0, 37.0)
        if (tag == START) {
            doneButton.addTarget(self, action: #selector(startTimeDone), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        } else {
            doneButton.addTarget(self, action: #selector(endTimeDone), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        }

        inputView.addSubview(doneButton) // add Button to UIView

        sender.inputView = inputView
    }

    func eventTimeChanged(sender: UIDatePicker) {
        let tag = sender.tag
        updateDateText(tag, date: sender.date)
    }

    func startTimeDone(sender: UIButton) {
        startTimeField.resignFirstResponder() // To resign the inputView on clicking done.
    }

    func endTimeDone(sender: UIButton) {
        endTimeField.resignFirstResponder()
    }

    func updateDateText(tag: Int, date: NSDate?) {
        let text = date != nil ? shortDateFormatter.stringFromDate(date!) : ""
        switch tag {
        case START:
            startTimeField.text = text
            self.startTime = date
        case END:
            endTimeField.text = text
            self.endTime = date
        default:
            return
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


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favorites.count
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("favoriteEvent", forIndexPath: indexPath) as! FavoriteEventCell
        let f = favorites[indexPath.row]
        let title = f.title ?? ""
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        cell.label.text = String(format: "%02d:%02d-%02d:%02d", f.startHour, f.startMinutes, f.endHour, f.endMinutes) + " " + title
        cell.label.sizeToFit()
        cell.selected = f.matches(startTime, endDateMaybe: endTime, titleMaybe: title)
        cell.label.textColor = cell.selected ? UIColor.blackColor() : UIColor.grayColor()
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(200, 20)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedFavorite(collectionView, indexPath: indexPath)
    }

    func selectedFavorite(collectionView: UICollectionView?, indexPath: NSIndexPath) {
        (collectionView?.cellForItemAtIndexPath(indexPath) as? FavoriteEventCell)?.label.textColor = UIColor.blackColor()
        let favorite = favorites[indexPath.row]
        let startTime = daySelection.currentDay().toDate(favorite.startHour, minutes: favorite.startMinutes)
        let endTime = daySelection.currentDay().toDate(favorite.endHour, minutes: favorite.endMinutes)
        updateValues(startTime, end: endTime, title: favorite.title)
        updateButtonStates()
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        (collectionView.cellForItemAtIndexPath(indexPath) as! FavoriteEventCell).label.textColor = UIColor.grayColor()
    }

    @IBAction func clearDay(sender: UIButton) {
        startTimeField.text = ""
        startTime = nil
        endTimeField.text = ""
        endTime = nil
        descriptionField.text = ""
        updateButtonStates()
        favoritesView.reloadData()
    }

    @IBAction func saveEvent(sender: UIButton) {
        Calendar.persistDay(startTime,
                endDate: endTime,
                title: descriptionField.text,
                existingEvent: event,
                errorCallback: self.errorInCalendar,
                callback: {
                    [weak self] in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.nextDay()
                    }
                })
    }

    func errorInCalendar() {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Cannot access calendar", message: "Please allow calendar access to this app. Otherwise the app is unsuable.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let directions: [UISwipeGestureRecognizerDirection] = [.Left, .Right]
        for d in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            gesture.direction = d
            daySelection.addGestureRecognizer(gesture)
        }
        favoriteButton.setImage(UIImage(named: "ic_favorite_border"), forState: .Normal)
        favoriteButton.setImage(UIImage(named: "ic_favorite"), forState: .Selected)
        daySelection.delegate = self
        favoritesView.delegate = self
        favoritesView.dataSource = self
        favoritesView.allowsMultipleSelection = false
        favoritesView.registerClass(FavoriteEventCell.self, forCellWithReuseIdentifier: "favoriteEvent")
        favoritesView.layer.cornerRadius = 5
        descriptionField.delegate = self
        startTimeField.addTarget(self, action: #selector(valueChange), forControlEvents: .EditingDidEnd)
        endTimeField.addTarget(self, action: #selector(valueChange), forControlEvents: .EditingDidEnd)
        descriptionField.addTarget(self, action: #selector(valueChange), forControlEvents: .EditingChanged)
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()

            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

            self.view.insertSubview(blurEffectView, atIndex: 0) //if you have more UIViews, use an insertSubview API to place it where needed
        }
    }

    func valueChange(textField: UITextField) {
        updateButtonStates()
    }

    func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Left:
            daySelection.nextWeek()
        case UISwipeGestureRecognizerDirection.Right:
            daySelection.previousWeek()
        default:
            return
        }
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
        monthLabel.text = monthFormatter.stringFromDate(ymd.toDate())
        updateValues(event?.startDate, end: event?.endDate, title: event?.title)
        favoritesView.reloadData()
        if let index = findSelectedFavoriteIndex() {
            self.favoritesView.reloadData()
            self.favoritesView.selectItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: .None)

        }
        updateButtonStates()
    }

    func updateValues(start: NSDate?, end: NSDate?, title: String?) {
        startTime = start
        endTime = end
        descriptionField.text = title
        updateDateText(START, date: startTime)
        updateDateText(END, date: endTime)
    }

    func updateButtonStates() {
        saveButton.enabled = (startTime != nil && endTime != nil && startTime != endTime) || (startTime == nil && endTime == nil && event != nil)
        favoriteButton.hidden = !saveButton.enabled
        let index = findSelectedFavoriteIndex()
        favoriteButton.selected = index != nil
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

    func findSelectedFavoriteIndex() -> Int? {
        return favorites.indexOf {
            $0.matches(startTime, endDateMaybe: endTime, titleMaybe: descriptionField.text)
        }

    }

    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }


}

