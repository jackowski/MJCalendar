//
//  WeekView.swift
//  Pods
//
//  Created by Michał Jackowski on 21.09.2015.
//
//

import UIKit
import NSDate_Escort

open class MJWeekView: MJComponentView {
    var date: Date! {
        didSet {
            self.configureViews()
        }
    }
    var days: [MJDayView]?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(date: Date, delegate: MJComponentDelegate) {
        self.date = date
        super.init(delegate: delegate)
        self.configureViews()
    }
    
    func configureViews() {
        if let dayViews = self.days {
            for i in 1...7 {
                let dayDate = (self.date!.self as NSDate).addingDays(i-1)
                dayViews[i - 1].date = dayDate
            }
        } else {
            self.days = []
            for i in 1...7 {
                let dayDate = (self.date!.self as NSDate).addingDays(i-1)
                let dayView = MJDayView(date: dayDate, delegate: self.delegate!)
                self.addSubview(dayView)
                self.days!.append(dayView)
            }
        }
    }
    
    override func updateFrame() {
        for (index, day) in (self.days!).enumerated() {
            let dayWidth = self.width() / 7
            day.frame = CGRect(x: CGFloat(index) * dayWidth, y: 0, width: dayWidth, height: self.height())
        }
    }
}
