//
//  ViewController.swift
//  MJCalendar
//
//  Created by Michał Jackowski on 09/14/2015.
//  Copyright (c) 2015 Michał Jackowski. All rights reserved.
//

import UIKit
import NSDate_Escort
import MJCalendar
import HexColors

struct DayColors {
    var backgroundColor: UIColor
    var textColor: UIColor
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MJCalendarViewDelegate {
    
    @IBOutlet weak var calendarView: MJCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    
    var days: [NSDate] = []
    var dayColors = Dictionary<NSDate, DayColors>()
    var dateFormatter: NSDateFormatter!
    var colors: [UIColor] {
        return [
            UIColor(hexString: "#f6980b"),
            UIColor(hexString: "#2081D9"),
            UIColor(hexString: "#2fbd8f"),
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDays()
        
        self.setUpCalendarConfiguration()
        
        self.dateFormatter = NSDateFormatter()
        self.setTitleWithDate(NSDate())
    }
    
    func setUpCalendarConfiguration() {
        self.calendarView.calendarDelegate = self
        self.calendarView.configuration.periodType = .Month
        self.calendarView.configuration.dayViewType = .Circle
        self.calendarView.configuration.dayTextColor = UIColor(hexString: "6f787c")
        self.calendarView.configuration.dayBackgroundColor = UIColor(hexString: "f0f0f0")
        self.calendarView.configuration.selectedDayTextColor = UIColor.whiteColor()
        self.calendarView.configuration.selectedDayBackgroundColor = UIColor(hexString: "6f787c")
        self.calendarView.configuration.otherMonthTextColor = UIColor(hexString: "6f787c")
        self.calendarView.configuration.otherMonthBackgroundColor = UIColor(hexString: "E7E7E7")
        self.calendarView.configuration.weekLabelTextColor = UIColor(hexString: "6f787c")
        self.calendarView.commitConfiguration()
    }
    
    func setTitleWithDate(date: NSDate) {
        self.dateFormatter.dateFormat = "MMMM yy"
        self.navigationItem.title = self.dateFormatter.stringFromDate(date)
    }

    func setUpDays() {
        let range = 365
        let startDay = NSDate().dateAtStartOfDay().dateBySubtractingDays(range / 2)
        for i in 0...range {
            let day = startDay.dateByAddingDays(i)
            self.days.append(day)
            if let randColor = self.randColor() {
                let dayColors = DayColors(backgroundColor: randColor, textColor: UIColor.whiteColor())
                self.dayColors[day] = dayColors
            }
            
        }
    }
    
    func randColor() -> UIColor? {
        if rand() % 2 == 0 {
            let colorIndex = Int(rand()) % self.colors.count
            let color = self.colors[colorIndex]
            return color
        }
        
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.days.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as! TableViewCell
        
        let date = self.days[indexPath.row]
        self.dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let dateString = self.dateFormatter.stringFromDate(date)
        cell.dateLabel.text = dateString
        cell.colorView.backgroundColor = self.dayColors[date]?.backgroundColor
        cell.colorView.clipsToBounds = true
        cell.colorView.layer.cornerRadius = cell.colorView.width() / 2
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let visibleCells = self.tableView.indexPathsForVisibleRows() {
            let index = visibleCells.count / 2
            if let cellIndexPath = visibleCells.first as? NSIndexPath {
                let day = self.days[cellIndexPath.row]
                self.calendarView.selectDate(day)
            }
            
        }
    }
    
    //MARK: MJCalendarViewDelegate
    func didChangePeriod(periodDate: NSDate, calendarView: MJCalendarView) {
        self.setTitleWithDate(periodDate)
    }
    
    func backgroundColorForDate(date: NSDate, calendarView: MJCalendarView) -> UIColor? {
        return self.dayColors[date]?.backgroundColor
    }
    
    func textColorForDate(date: NSDate, calendarView: MJCalendarView) -> UIColor? {
        return self.dayColors[date]?.textColor
    }

    //MARK: Toolbar actions
    @IBAction func didTapMonth(sender: AnyObject) {
        self.animateToPeriod(.Month)
    }
    
    @IBAction func didTapThreeWeeks(sender: AnyObject) {
        self.animateToPeriod(.ThreeWeeks)
    }
    
    
    @IBAction func didTapTwoWeeks(sender: AnyObject) {
        self.animateToPeriod(.TwoWeeks)
    }
    
    @IBAction func didTapOneWeek(sender: AnyObject) {
        self.animateToPeriod(.OneWeek)
    }
    
    func animateToPeriod(period: MJConfiguration.PeriodType) {
        self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
        self.calendarView.animateToPeriodType(period, duration: 0.2, animations: { (calendarHeight) -> Void in
            self.calendarViewHeight.constant = calendarHeight
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

