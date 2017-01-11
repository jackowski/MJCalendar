//
//  PeriodView.swift
//  Pods
//
//  Created by Michał Jackowski on 21.09.2015.
//
//

import UIKit
import NSDate_Escort

open class MJPeriodView: MJComponentView {
    var date: Date! {
        didSet {
            self.configureViews()
        }
    }
    var weeks: [MJWeekView]?
    var numberOfWeeks: Int {
        return self.delegate!.configurationWithComponent(self).periodType.weeksCount()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(date: Date, delegate: MJComponentDelegate) {
        self.date = date
        super.init(delegate: delegate)
        self.clipsToBounds = true
        self.configureViews()
    }
    
    func configureViews() {
        if let weekViews = self.weeks {
            for i in 1...self.numberOfWeeks {
                let weekDate = (self.date!.self as NSDate).addingDays((i-1) * 7)
                weekViews[i - 1].date = weekDate
            }
        } else {
            self.weeks = []
            for i in 1...self.numberOfWeeks {
                let weekDate = (self.date!.self as NSDate).addingDays((i-1) * 7)
                let weekView = MJWeekView(date: weekDate, delegate: self.delegate!)
                self.addSubview(weekView)
                self.weeks!.append(weekView)
            }
        }
        
        self.setIsSameMonth()
    }
    
    func setIsSameMonth() {
        if (self.delegate.configurationWithComponent(self).periodType == .month) {
            let monthDate = self.weeks![1].date
            for (index, week) in (self.weeks!).enumerated() {
                if index == 0 || index == 4 || index == 5 {
                    for dayView in week.days! {
                        dayView.isSameMonth = (dayView.date as NSDate).atStartOfMonth() == (monthDate as? NSDate)?.atStartOfMonth()
                    }
                }
            }
        }
    }
    
    override func updateFrame() {
        for (index, week) in (self.weeks!).enumerated() {
            let lineHeight = self.delegate.configurationWithComponent(self).rowHeight
            week.frame = CGRect(x: 0, y: CGFloat(index) * lineHeight, width: self.width(), height: lineHeight)
        }
    }
    
    open func startingDate() -> Date {
        return self.weeks!.first!.days!.first!.date! as Date
    }
    
    open func endingDate() -> Date {
        return self.weeks!.last!.days!.last!.date! as Date
    }
    
    open func startingPeriodDate() -> Date {
        let monthCount = MJConfiguration.PeriodType.month.weeksCount()
        if self.weeks?.count == monthCount {
            let middleDate = self.weeks![3].date
            return (middleDate! as NSDate).atStartOfMonth()
        } else {
            return startingDate()
        }
    }
    
    open func endingPeriodDate() -> Date {
        let monthCount = MJConfiguration.PeriodType.month.weeksCount()
        if self.weeks?.count == monthCount {
            let middleDate = self.weeks![3].date
            return (middleDate! as NSDate).atEndOfMonth()
        } else {
            return endingDate()
        }
    }
    
    open func isDateInPeriod(_ date: Date) -> Bool {
        return (date as NSDate).isLaterThanOrEqualDate(startingPeriodDate()) && (date as NSDate).isEarlierThanOrEqualDate(endingPeriodDate())
    }
}
