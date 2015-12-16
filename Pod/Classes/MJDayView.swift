//
//  DayView.swift
//  Pods
//
//  Created by Michał Jackowski on 21.09.2015.
//
//

import UIKit
import NSDate_Escort

public class MJDayView: UIView {
    var date: NSDate! {
        didSet {
            self.updateView()
        }
    }
    var delegate: MJComponentDelegate!
    var label: UILabel!
    var isSameMonth = true {
        didSet {
            if isSameMonth != oldValue {
                self.updateView()
            }
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(date: NSDate, delegate: MJComponentDelegate) {
        self.date = date
        self.delegate = delegate
        super.init(frame: CGRectZero)
        self.setUpGesture()
        self.setUpLabel()
        self.updateView()
    }
    
    func setUpGesture() {
        let tap = UITapGestureRecognizer(target: self, action: Selector("didTap"))
        self.addGestureRecognizer(tap)
    }
    
    func didTap() {
        self.delegate.didSelectDate(self.date)
    }
    
    func setUpLabel() {
        self.label = UILabel()
        self.label.textAlignment = .Center
        self.label.clipsToBounds = true
        self.addSubview(self.label)
    }
    
    override public func layoutSubviews() {
        let labelSize = self.delegate.getConfiguration().dayViewSize
        let labelFrame = CGRectMake((self.width() - labelSize.width) / 2,
            (self.height() - labelSize.height) / 2, labelSize.width, labelSize.height)
        self.label.frame = labelFrame
    }
    
    func updateView() {
        self.label.font = self.delegate.getConfiguration().dayTextFont
        self.label.text = "\(self.date.day)"
        self.setShape()
        self.setBackgrounds()
        self.setTextColors()
        self.setViewBackgrounds()
    }
    
    func setShape() {
        let cornerRadius = self.delegate.getConfiguration().dayViewType == .Circle
            ? self.delegate.getConfiguration().dayViewSize.width / 2
            : 0
        self.label.layer.cornerRadius = cornerRadius
    }
    
    func setViewBackgrounds() {
        if self.isSameMonth {
            self.backgroundColor = self.delegate.getConfiguration().dayBackgroundColor
        } else {
            self.backgroundColor = self.delegate.getConfiguration().otherMonthBackgroundColor
        }
    }
    
    func setTextColors() {
        if self.delegate.isDateSelected(self.date) {
            self.label.textColor = self.delegate.getConfiguration().selectedDayTextColor
        } else if self.isSameMonth {
            if let textColor = self.delegate.textColorForDate(self.date) {
                self.label.textColor = textColor
            } else {
                self.label.textColor = self.delegate.getConfiguration().dayTextColor
            }
        } else {
            self.label.textColor = self.delegate.getConfiguration().otherMonthTextColor
        }
    }
    
    func setBackgrounds() {
        if self.delegate.isDateSelected(self.date) {
            self.label.backgroundColor = self.delegate.getConfiguration().selectedDayBackgroundColor
        } else if let backgroundColor = self.delegate.backgroundColorForDate(self.date) {
            self.label.backgroundColor = self.isSameMonth
                ? backgroundColor
                : self.delegate.getConfiguration().otherMonthBackgroundColor
        } else {
            self.label.backgroundColor = self.isSameMonth
                ? self.delegate.getConfiguration().dayBackgroundColor
                : self.delegate.getConfiguration().otherMonthBackgroundColor
        }
    }
    
    
}
