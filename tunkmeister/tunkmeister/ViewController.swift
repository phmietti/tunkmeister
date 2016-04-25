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
        print("init")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    deinit {
        print("deinit")
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

struct FavoriteEvent {
    let startHour: Int
    let startMinutes: Int
    let endHour: Int
    let endMinutes: Int
    let title: String?

    func encode() -> NSDictionary {
        var dictionary: Dictionary = Dictionary<String, AnyObject>()
        dictionary["startHour"] = startHour
        dictionary["startMinutes"] = startMinutes
        dictionary["endHour"] = endHour
        dictionary["endMinutes"] = endMinutes
        if let t = title {
            dictionary["title"] = t
        }
        return dictionary
    }

    func matches(startDate: NSDate, endDate: NSDate) -> Bool {
        return startDate.hour() == startHour && startDate.minutes() == startMinutes && endDate.hour() == endHour && endDate.minutes() == endMinutes
    }

    // Decode
    static func decode(dictionary: NSDictionary) -> FavoriteEvent {
        let startHour = dictionary["startHour"] as! Int
        let startMinutes = dictionary["startMinutes"] as! Int
        let endHour = dictionary["endHour"] as! Int
        let endMinutes = dictionary["endMinutes"] as! Int
        let title = dictionary["title"] as? String
        return FavoriteEvent(startHour: startHour, startMinutes: startMinutes, endHour: endHour, endMinutes: endMinutes, title: title)
    }
}

class ViewController: UIViewController, WeekViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

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
                print("removing \(i) \(self.favorites.count)")
                self.favorites.removeAtIndex(i)
                if let paths = self.favoritesView.indexPathsForSelectedItems() {
                    self.favoritesView.deleteItemsAtIndexPaths(paths)
                }
            }
        } else if let s = startTime, e = endTime {
            self.favorites.append(FavoriteEvent(startHour: s.hour(), startMinutes: s.minutes(), endHour: e.hour(), endMinutes: e.minutes(), title: descriptionField.text))
            self.favoritesView.selectItemAtIndexPath(NSIndexPath(index: favorites.count - 1), animated: false, scrollPosition: .None)
        }
        dispatch_async(dispatch_get_main_queue(), {
            [weak self] in
            self?.favoritesView.reloadData()
            self?.updateButtonStates()
        });
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

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count \(self.favorites.count)")
        return self.favorites.count
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("indexPath \(indexPath.row)")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("favoriteEvent", forIndexPath: indexPath) as! FavoriteEventCell
        let favorite = favorites[indexPath.row]
        let title = favorite.title ?? ""
        cell.label.text = "\(favorite.startHour):\(favorite.startMinutes) - \(favorite.endHour):\(favorite.endMinutes)\n\(title)"
        cell.label.sizeToFit()
        cell.label.textColor = cell.selected ? UIColor.blackColor() : UIColor.grayColor()
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(70, 50)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selected \(indexPath)")
        (collectionView.cellForItemAtIndexPath(indexPath) as! FavoriteEventCell).label.textColor = UIColor.blackColor()
        let favorite = favorites[indexPath.row]
        let startTime = daySelection.currentDay().toDate(favorite.startHour, minutes: favorite.startMinutes)
        let endTime = daySelection.currentDay().toDate(favorite.endHour, minutes: favorite.endMinutes)
        updateValues(startTime, end: endTime, title: favorite.title)
        updateButtonStates()
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        (collectionView.cellForItemAtIndexPath(indexPath) as! FavoriteEventCell).label.textColor = UIColor.grayColor()
        print("deselect \(indexPath)")
    }


    @IBAction func clearDay(sender: UIButton) {
        startTimeField.text = ""
        startTime = nil
        endTimeField.text = ""
        endTime = nil
        descriptionField.text = ""
    }

    @IBAction func saveEvent(sender: UIButton) {
        Calendar.persistDay(startTime, endDate: endTime, title: descriptionField.text, existingEvent: event, callback: {
            [weak self] in
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
        favoriteButton.setImage(UIImage(named: "ic_favorite_border"), forState: .Normal)
        favoriteButton.setImage(UIImage(named: "ic_favorite"), forState: .Selected)
        daySelection.delegate = self
        favoritesView.delegate = self
        favoritesView.dataSource = self
        favoritesView.allowsMultipleSelection = false
        favoritesView.registerClass(FavoriteEventCell.self, forCellWithReuseIdentifier: "favoriteEvent")
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
        default:
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
        monthLabel.text = monthFormatter.stringFromDate(ymd.toDate())
        updateValues(event?.startDate, end: event?.endDate, title: event?.title)
        if let index = findSelectedFavoriteIndex() {
            print("favorite found \(index)")
            dispatch_async(dispatch_get_main_queue(), {
                [weak self] in
                self?.favoritesView.selectItemAtIndexPath(NSIndexPath(index: index), animated: false, scrollPosition: .None)
                self?.favoritesView.cellForItemAtIndexPath(NSIndexPath(index: index))?.selected = true
            });
        } else {
            print("favorite not found")
        }
        favoritesView.reloadData()
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
        print("selected \(index)")
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
        if let start = startTime, end = endTime {
            return favorites.indexOf {
                $0.matches(start, endDate: end)
            }
        } else {
            return nil
        }
    }

}

