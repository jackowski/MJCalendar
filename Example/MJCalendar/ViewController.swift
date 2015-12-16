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

struct DayData {
    var date: NSDate
    var color: UIColor?
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MJCalendarViewDelegate {
    
    @IBOutlet weak var calendarView: MJCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    
    var daysDataArray: [DayData] = []
    var dateFormatter: NSDateFormatter!
    var colors: [UIColor] {
        return [
            UIColor(hexString: "#f6980b"),
            UIColor(hexString: "#EA2E0E"),
            UIColor(hexString: "#FFB613"),
            UIColor(hexString: "#8100B8"),
            UIColor(hexString: "#0A53C2")
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarView.calendarDelegate = self
        self.calendarView.configuration.periodType = .Month
        self.calendarView.commitConfiguration()
        
        self.dateFormatter = NSDateFormatter()
        self.setTitleWithDate(NSDate())
        
        self.setUpDays()
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
            let color = self.randColor()
            let dayData = DayData(date: day, color: color)
            self.daysDataArray.append(dayData)
        }
    }
    
    func randColor() -> UIColor? {
        if rand() % 5 == 0 {
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
        return self.daysDataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as! TableViewCell
        
        let dateData = self.daysDataArray[indexPath.row]
        self.dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let dateString = self.dateFormatter.stringFromDate(dateData.date)
        cell.dateLabel.text = dateString
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let visibleCells = self.tableView.indexPathsForVisibleRows() {
            let index = visibleCells.count / 2
            if let cellIndexPath = visibleCells.first as? NSIndexPath {
                let dateData = self.daysDataArray[cellIndexPath.row]
                self.calendarView.selectDate(dateData.date)
            }
            
        }
    }
    
    //MARK: MJCalendarViewDelegate
    func didChangePeriod(periodDate: NSDate, calendarView: MJCalendarView) {
        self.setTitleWithDate(periodDate)
    }
    
    func backgroundColorForDate(date: NSDate, calendarView: MJCalendarView) -> UIColor? {
        return nil
    }
    
    func textColorForDate(date: NSDate, calendarView: MJCalendarView) -> UIColor? {
        return nil
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

