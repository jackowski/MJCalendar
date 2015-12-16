//
//  PeriodView.swift
//  Pods
//
//  Created by Michał Jackowski on 21.09.2015.
//
//

import UIKit
import NSDate_Escort

public class MJPeriodView: UIView {
    var date: NSDate! {
        didSet {
            self.configureViews()
        }
    }
    var delegate: MJComponentDelegate!
    var weeks: [MJWeekView]?
    var numberOfWeeks: Int {
        return self.delegate!.getConfiguration().periodType.weeksCount()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(date: NSDate, delegate: MJComponentDelegate) {
        self.date = date
        self.delegate = delegate
        super.init(frame: CGRectZero)
        self.clipsToBounds = true
        self.configureViews()
    }
    
    func configureViews() {
        if let weekViews = self.weeks {
            for i in 1...self.numberOfWeeks {
                let weekDate = self.date!.dateByAddingDays((i-1) * 7) //self.date! + (i - 1).weeks
                weekViews[i - 1].date = weekDate
            }
        } else {
            self.weeks = []
            for i in 1...self.numberOfWeeks {
                let weekDate = self.date!.dateByAddingDays((i-1) * 7) //self.date! + (i - 1).weeks
                let weekView = MJWeekView(date: weekDate, delegate: self.delegate!)
                self.addSubview(weekView)
                self.weeks!.append(weekView)
            }
        }
        
        self.setIsSameMonth()
    }
    
    func setIsSameMonth() {
        if (self.delegate.getConfiguration().periodType == .Month) {
            let monthDate = self.weeks![1].date
            for (index, week) in enumerate(self.weeks!) {
                if index == 0 || index == 4 || index == 5 {
                    for dayView in week.days! {
                        dayView.isSameMonth = dayView.date.dateAtStartOfMonth() == monthDate.dateAtStartOfMonth()
                    }
                }
            }
        }
    }
    
    override public func layoutSubviews() {
        for (index, week) in enumerate(self.weeks!) {
            let lineHeight = self.delegate.getConfiguration().lineHeight
            week.frame = CGRectMake(0, CGFloat(index) * lineHeight, self.width(), lineHeight)
            println(week.frame)
        }
    }
    
    public func startingDate() -> NSDate {
        return self.weeks!.first!.days!.first!.date!
    }
    
    public func endingDate() -> NSDate {
        return self.weeks!.last!.days!.last!.date!
    }
}
