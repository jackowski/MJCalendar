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
    var borderView: UIView!
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
        self.setUpBorderView()
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
    
    func setUpBorderView() {
        self.borderView = UIView()
        self.addSubview(self.borderView)
    }
    
    func setUpLabel() {
        self.label = UILabel()
        self.label.textAlignment = .Center
        self.label.clipsToBounds = true
        self.addSubview(self.label)
    }
    
    override public func layoutSubviews() {
        let labelSize = self.labelSize()
        let labelFrame = CGRectMake((self.width() - labelSize.width) / 2,
            (self.height() - labelSize.height) / 2, labelSize.width, labelSize.height)
        self.label.frame = labelFrame
        
        let dayViewSize = self.delegate.getConfiguration().dayViewSize
        let borderFrame = CGRectMake((self.width() - dayViewSize.width) / 2,
            (self.height() - dayViewSize.height) / 2, dayViewSize.width, dayViewSize.height)
        self.borderView.frame = borderFrame
    }
    
    func labelSize() -> CGSize {
        let dayViewSize = self.delegate.getConfiguration().dayViewSize
        let borderSize = self.delegate.getConfiguration().selectedBorderWidth
        let labelSize = self.delegate.getConfiguration().selectedDayType == .Filled
            ? dayViewSize
            : CGSizeMake(dayViewSize.width - 2 * borderSize, dayViewSize.height - 2 * borderSize)
        return labelSize
    }
    
    func updateView() {
        self.label.font = self.delegate.getConfiguration().dayTextFont
        self.label.text = "\(self.date.day)"
        self.setShape()
        self.setBackgrounds()
        self.setTextColors()
        self.setViewBackgrounds()
        self.setBorder()
    }
    
    func setShape() {
        let labelCornerRadius = self.delegate.getConfiguration().dayViewType == .Circle
            ? self.labelSize().width / 2
            : 0
        self.label.layer.cornerRadius = labelCornerRadius
        let borderCornerRadius = self.delegate.getConfiguration().dayViewSize.width / 2
        self.borderView.layer.cornerRadius = borderCornerRadius
    }
    
    func setViewBackgrounds() {
        if self.isSameMonth {
            self.backgroundColor = self.delegate.getConfiguration().dayBackgroundColor
        } else {
            self.backgroundColor = self.delegate.getConfiguration().otherMonthBackgroundColor
        }
    }
    
    func setTextColors() {
        if self.delegate.isDateSelected(self.date)
            && self.delegate.getConfiguration().selectedDayType == .Filled {
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
        if self.delegate.isDateSelected(self.date)
            && self.delegate.getConfiguration().selectedDayType == .Filled {
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
    
    func setBorder() {
        self.borderView.backgroundColor = self.delegate.getConfiguration().selectedDayBackgroundColor
        self.borderView.hidden = !self.delegate.isDateSelected(self.date)
    }
}
