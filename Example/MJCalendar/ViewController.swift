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
    
    var dayColors = Dictionary<Date, DayColors>()
    var dateFormatter: DateFormatter!
    var colors: [UIColor] {
        return [
            UIColor(hexString: "#f6980b"),
            UIColor(hexString: "#2081D9"),
            UIColor(hexString: "#2fbd8f"),
        ]
    }
    
    let daysRange = 365
    var isScrollingAnimation = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDays()
        
        self.setUpCalendarConfiguration()
        
        self.dateFormatter = DateFormatter()
        self.setTitleWithDate(Date())
    }
    
    func setUpCalendarConfiguration() {
        self.calendarView.calendarDelegate = self
        
        // Set displayed period type. Available types: Month, ThreeWeeks, TwoWeeks, OneWeek
        self.calendarView.configuration.periodType = .month

        // Set shape of day view. Available types: Circle, Square
        self.calendarView.configuration.dayViewType = .circle

        // Set selected day display type. Available types: 
        // Border - Only border is colored with selected day color
        // Filled - Entire day view is filled with selected day color
        self.calendarView.configuration.selectedDayType = .border

        // Set width of selected day border. Relevant only if selectedDayType = .Border
        self.calendarView.configuration.selectedBorderWidth = 1

        // Set day text color
        self.calendarView.configuration.dayTextColor = UIColor(hexString: "6f787c")

        // Set day background color
        self.calendarView.configuration.dayBackgroundColor = UIColor(hexString: "f0f0f0")

        // Set selected day text color
        self.calendarView.configuration.selectedDayTextColor = UIColor.white

        // Set selected day background color
        self.calendarView.configuration.selectedDayBackgroundColor = UIColor(hexString: "6f787c")

        // Set other month day text color. Relevant only if periodType = .Month
        self.calendarView.configuration.otherMonthTextColor = UIColor(hexString: "6f787c")

        // Set other month background color. Relevant only if periodType = .Month
        self.calendarView.configuration.otherMonthBackgroundColor = UIColor(hexString: "E7E7E7")

        // Set week text color
        self.calendarView.configuration.weekLabelTextColor = UIColor(hexString: "6f787c")

        // Set start day. Available type: .Monday, Sunday
        self.calendarView.configuration.startDayType = .monday

        // Set number of letters presented in the week days label
        self.calendarView.configuration.lettersInWeekDayLabel = .one

        // Set day text font
        self.calendarView.configuration.dayTextFont = UIFont.systemFont(ofSize: 12)

        //Set week's day name font
        self.calendarView.configuration.weekLabelFont = UIFont.systemFont(ofSize: 12)

        //Set day view size. It includes border width if selectedDayType = .Border
        self.calendarView.configuration.dayViewSize = CGSize(width: 24, height: 24)

        //Set height of row with week's days
        self.calendarView.configuration.rowHeight = 30

        // Set height of week's days names view
        self.calendarView.configuration.weekLabelHeight = 25
        
        // To commit all configuration changes execute reloadView method
        self.calendarView.reloadView()
    }
    
    func setTitleWithDate(_ date: Date) {
        self.dateFormatter.dateFormat = "MMMM yy"
        self.navigationItem.title = self.dateFormatter.string(from: date)
    }

    func setUpDays() {
        for i in 0...self.daysRange {
            let day = self.dateByIndex(i)
            if let randColor = self.randColor() {
                let dayColors = DayColors(backgroundColor: randColor, textColor: UIColor.white)
                self.dayColors[day] = dayColors
            } else {
                self.dayColors[day] = nil
            }
        }
    }
    
    func randColor() -> UIColor? {
        if arc4random() % 2 == 0 {
            let colorIndex = Int(arc4random()) % self.colors.count
            let color = self.colors[colorIndex]
            return color
        }
        
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.daysRange
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        
        let date = self.dateByIndex(indexPath.row)
        self.dateFormatter.dateStyle = DateFormatter.Style.long
        let dateString = self.dateFormatter.string(from: date)
        cell.dateLabel.text = dateString
        cell.colorView.backgroundColor = self.dayColors[date]?.backgroundColor
        cell.colorView.clipsToBounds = true
        cell.colorView.layer.cornerRadius = cell.colorView.width() / 2
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Prevent changing selected day when non user scroll is triggered.
        if !self.isScrollingAnimation {
            // Get all visible cells from tableview
            if let visibleCells = self.tableView.indexPathsForVisibleRows {
                if let cellIndexPath = visibleCells.first {
                    // Get day by indexPath
                    let day = self.dateByIndex(cellIndexPath.row)
                    
                    //Select day according to first visible cell in tableview
                    self.calendarView.selectDate(day)
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.isScrollingAnimation = false
    }
    
    func dateByIndex(_ index: Int) -> Date {
        let startDay = ((Date() as NSDate).atStartOfDay() as NSDate).subtractingDays(self.daysRange / 2)
        let day = (startDay as NSDate).addingDays(index)
        return day
    }
    
    func scrollTableViewToDate(_ date: Date) {
        if let row = self.indexByDate(date) {
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
            self.isScrollingAnimation = true
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func indexByDate(_ date: Date) -> Int? {
        let startDay = ((Date() as NSDate).atStartOfDay() as NSDate).subtractingDays(self.daysRange / 2)
        let index = (date as NSDate).days(after: startDay)
        if index >= 0 && index <= self.daysRange {
            return index
        } else {
            return nil
        }
    }
    
    //MARK: MJCalendarViewDelegate
    func calendar(_ calendarView: MJCalendarView, didChangePeriod periodDate: Date, bySwipe: Bool) {
        // Sets month name according to presented dates
        self.setTitleWithDate(periodDate)
        
        // bySwipe diffrentiate changes made from swipes or select date method
        if bySwipe {
            // Scroll to relevant date in tableview
            self.scrollTableViewToDate(periodDate)
        }
    }
    
    func calendar(_ calendarView: MJCalendarView, backgroundForDate date: Date) -> UIColor? {
        return self.dayColors[date]?.backgroundColor
    }
    
    func calendar(_ calendarView: MJCalendarView, textColorForDate date: Date) -> UIColor? {
        return self.dayColors[date]?.textColor
    }
    
    func calendar(_ calendarView: MJCalendarView, didSelectDate date: Date) {
        self.scrollTableViewToDate(date)
    }

    //MARK: Toolbar actions
    @IBAction func didTapMonth(_ sender: AnyObject) {
        self.animateToPeriod(.month)
    }
    
    @IBAction func didTapThreeWeeks(_ sender: AnyObject) {
        self.animateToPeriod(.threeWeeks)
    }
    
    @IBAction func didTapTwoWeeks(_ sender: AnyObject) {
        self.animateToPeriod(.twoWeeks)
    }
    
    @IBAction func didTapOneWeek(_ sender: AnyObject) {
        self.animateToPeriod(.oneWeek)
    }
    
    func animateToPeriod(_ period: MJConfiguration.PeriodType) {
        self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
        
        self.calendarView.animateToPeriodType(period, duration: 0.2, animations: { (calendarHeight) -> Void in
            // In animation block you can add your own animation. To adapat UI to new calendar height you can use calendarHeight param
            self.calendarViewHeight.constant = calendarHeight
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

