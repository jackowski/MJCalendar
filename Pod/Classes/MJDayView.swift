//
//  DayView.swift
//  Pods
//
//  Created by Michał Jackowski on 21.09.2015.
//
//

import UIKit
import NSDate_Escort

open class MJDayView: MJComponentView {
    var date: Date! {
        didSet {
            self.updateView()
        }
    }
    var todayDate: Date!
    var label: UILabel!
    var borderView: UIView!
    var isSameMonth = true {
        didSet {
            if isSameMonth != oldValue {
                self.updateView()
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(date: Date, delegate: MJComponentDelegate) {
        self.date = date
        self.todayDate = (Date() as NSDate).atStartOfDay()
        super.init(delegate: delegate)
        self.setUpGesture()
        self.setUpBorderView()
        self.setUpLabel()
        self.updateView()
    }
    
    func setUpGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(MJDayView.didTap))
        self.addGestureRecognizer(tap)
    }
    
    func didTap() {
        if !self.delegate.isDateOutOfRange(self, date: self.date) {
            self.delegate.componentView(self, didSelectDate: self.date)
        }
    }
    
    func setUpBorderView() {
        self.borderView = UIView()
        self.addSubview(self.borderView)
    }
    
    func setUpLabel() {
        self.label = UILabel()
        self.label.textAlignment = .center
        self.label.clipsToBounds = true
        self.addSubview(self.label)
    }
    
    override func updateFrame() {
        let labelSize = self.labelSize()
        let labelFrame = CGRect(x: (self.width() - labelSize.width) / 2,
                                    y: (self.height() - labelSize.height) / 2, width: labelSize.width, height: labelSize.height)
        self.label.frame = labelFrame
        
        let dayViewSize = self.delegate.configurationWithComponent(self).dayViewSize
        let borderFrame = CGRect(x: (self.width() - dayViewSize.width) / 2,
                                     y: (self.height() - dayViewSize.height) / 2, width: dayViewSize.width, height: dayViewSize.height)
        self.borderView.frame = borderFrame
    }
    
    func labelSize() -> CGSize {
        let dayViewSize = self.delegate.configurationWithComponent(self).dayViewSize
        let borderSize = self.delegate.configurationWithComponent(self).selectedBorderWidth
        let labelSize = self.delegate.configurationWithComponent(self).selectedDayType == .filled
            ? dayViewSize
            : CGSize(width: dayViewSize.width - 2 * borderSize, height: dayViewSize.height - 2 * borderSize)
        return labelSize
    }
    
    func updateView() {
        self.setText()
        self.setShape()
        self.setBackgrounds()
        self.setTextColors()
        self.setViewBackgrounds()
        self.setBorder()
    }
    
    func setText() {
        self.label.font = self.delegate.configurationWithComponent(self).dayTextFont
        let text = "\((self.date as NSDate).day)"
        self.label.text = text
        
        let isToday = self.todayDate.timeIntervalSince1970 == self.date.timeIntervalSince1970
        if isToday {
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            self.label.attributedText = NSAttributedString(string: text, attributes: underlineAttribute)
        } else {
            self.label.attributedText = NSAttributedString(string: text)
        }
    }
    
    func setShape() {
        let labelCornerRadius = self.delegate.configurationWithComponent(self).dayViewType == .circle
            ? self.labelSize().width / 2
            : 0
        self.label.layer.cornerRadius = labelCornerRadius
        let borderCornerRadius = self.delegate.configurationWithComponent(self).dayViewSize.width / 2
        self.borderView.layer.cornerRadius = borderCornerRadius
    }
    
    func setViewBackgrounds() {
        if self.isSameMonth {
            if self.delegate.isDateOutOfRange(self, date: self.date) {
                self.backgroundColor = self.delegate.configurationWithComponent(self).outOfRangeDayBackgroundColor
            } else {
                self.backgroundColor = self.delegate.configurationWithComponent(self).dayBackgroundColor
            }
        } else {
            self.backgroundColor = self.delegate.configurationWithComponent(self).otherMonthBackgroundColor
        }
    }
    
    func setTextColors() {
        if self.delegate.componentView(self, isDateSelected: self.date)
            && self.delegate.configurationWithComponent(self).selectedDayType == .filled {
            self.label.textColor = self.delegate.configurationWithComponent(self).selectedDayTextColor
        } else if self.isSameMonth {
            if let textColor = self.delegate.componentView(self, textColorForDate: self.date) {
                self.label.textColor = textColor
            } else {
                if self.delegate.isDateOutOfRange(self, date: self.date) {
                    self.label.textColor = self.delegate.configurationWithComponent(self).outOfRangeDayTextColor
                } else {
                    self.label.textColor = self.delegate.configurationWithComponent(self).dayTextColor
                }
            }
        } else {
            self.label.textColor = self.delegate.configurationWithComponent(self).otherMonthTextColor
        }
    }
    
    func setBackgrounds() {
        if self.delegate.componentView(self, isDateSelected: self.date)
            && self.delegate.configurationWithComponent(self).selectedDayType == .filled {
                self.label.backgroundColor = self.delegate.configurationWithComponent(self).selectedDayBackgroundColor
        } else if self.isSameMonth {
            if let backgroundColor = self.delegate.componentView(self, backgroundColorForDate: self.date) {
                self.label.backgroundColor = backgroundColor
            } else {
                if self.delegate.isDateOutOfRange(self, date: self.date) {
                    self.label.backgroundColor = self.delegate.configurationWithComponent(self).outOfRangeDayBackgroundColor
                } else {
                    self.label.backgroundColor = self.delegate.configurationWithComponent(self).dayBackgroundColor
                }
            }
        } else {
            self.label.backgroundColor = self.delegate.configurationWithComponent(self).otherMonthBackgroundColor
        }
    }
    
    func setBorder() {
        self.borderView.backgroundColor = self.delegate.configurationWithComponent(self).selectedDayBackgroundColor
        self.borderView.isHidden = !(self.delegate.componentView(self, isDateSelected: self.date) && isSameMonth)
    }
}
