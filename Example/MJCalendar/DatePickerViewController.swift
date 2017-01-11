//
//  DatePickerViewController.swift
//  MJCalendar
//
//  Created by Michał Jackowski on 25.03.2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import NSDate_Escort
import MJCalendar
import HexColors

class DatePickerViewController: UIViewController, MJCalendarViewDelegate {
    @IBOutlet weak var calendarView: MJCalendarView!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var monthNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpCalendarConfiguration()
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
        self.calendarView.configuration.selectedDayType = .filled
        
        // Set day text color
        self.calendarView.configuration.dayTextColor = UIColor(hexString: "6f787c")
        
        // Set day background color
        self.calendarView.configuration.dayBackgroundColor = UIColor(hexString: "f0f0f0")
        
        // Set selected day text color
        self.calendarView.configuration.selectedDayTextColor = UIColor.white
        
        // Set selected day background color
        self.calendarView.configuration.selectedDayBackgroundColor = UIColor(hexString: "2FBD8F")
        
        // Set other month day text color. Relevant only if periodType = .Month
        self.calendarView.configuration.otherMonthTextColor = UIColor(hexString: "6f787c")
        
        // Set other month background color. Relevant only if periodType = .Month
        self.calendarView.configuration.otherMonthBackgroundColor = UIColor(hexString: "E7E7E7")
        
        // Set week text color
        self.calendarView.configuration.weekLabelTextColor = UIColor(hexString: "6f787c")
        
        // Set start day. Available type: .Monday, Sunday
        self.calendarView.configuration.startDayType = .monday
        
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
        
        
        //Set min date
        self.calendarView.configuration.minDate = (Date() as NSDate).subtractingDays(60)
        
        //Set max date
        self.calendarView.configuration.maxDate = (Date() as NSDate).addingDays(60)
        
        self.calendarView.configuration.outOfRangeDayBackgroundColor = UIColor(hexString: "E7E7E7")
        self.calendarView.configuration.outOfRangeDayTextColor = UIColor(hexString: "6f787c")
        
        self.calendarView.configuration.selectDayOnPeriodChange = false
        
        // To commit all configuration changes execute reloadView method
        self.calendarView.reloadView()
    }
    
    func setTitleWithDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yy"
        self.monthNameLabel.text = dateFormatter.string(from: date)
    }

    //MARK: MJCalendarViewDelegate
    func calendar(_ calendarView: MJCalendarView, didChangePeriod periodDate: Date, bySwipe: Bool) {
        // Sets month name according to presented dates
        self.setTitleWithDate(periodDate)
    }
    
    func calendar(_ calendarView: MJCalendarView, backgroundForDate date: Date) -> UIColor? {
        return nil
    }
    
    func calendar(_ calendarView: MJCalendarView, textColorForDate date: Date) -> UIColor? {
        return nil
    }
    
    func calendar(_ calendarView: MJCalendarView, didSelectDate date: Date) {
        
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
        self.calendarView.animateToPeriodType(period, duration: 0.2, animations: { (calendarHeight) -> Void in
            // In animation block you can add your own animation. To adapat UI to new calendar height you can use calendarHeight param
            self.calendarViewHeight.constant = calendarHeight
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

}
