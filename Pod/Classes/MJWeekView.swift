//
//  WeekView.swift
//  Pods
//
//  Created by Michał Jackowski on 21.09.2015.
//
//

import UIKit
import NSDate_Escort

public class MJWeekView: UIView {
    var date: NSDate! {
        didSet {
            self.configureViews()
        }
    }
    var delegate: MJComponentDelegate!
    var days: [MJDayView]?
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(date: NSDate, delegate: MJComponentDelegate) {
        self.date = date
        self.delegate = delegate
        super.init(frame: CGRectZero)
        self.configureViews()
    }
    
    func configureViews() {
        if let dayViews = self.days {
            for i in 1...7 {
                let dayDate = self.date!.dateByAddingDays(i-1) //self.date! + (i - 1).days
                dayViews[i - 1].date = dayDate
            }
        } else {
            self.days = []
            for i in 1...7 {
                let dayDate = self.date!.dateByAddingDays(i-1) //self.date! + (i - 1).days
                let dayView = MJDayView(date: dayDate, delegate: self.delegate!)
                self.addSubview(dayView)
                self.days!.append(dayView)
            }
        }
    }
    
    override public func layoutSubviews() {
        for (index, day) in enumerate(self.days!) {
            let dayWidth = self.width() / 7
            day.frame = CGRectMake(CGFloat(index) * dayWidth, 0, dayWidth, self.height())
        }
    }
}
