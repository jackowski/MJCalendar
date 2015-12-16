//
//  MJCalendarView.swift
//  Pods
//
//  Created by Michał Jackowski on 18.09.2015.
//
//

import UIKit
import NSDate_Escort
import UIView_JMFrame

protocol MJComponentDelegate {
    func getConfiguration() -> MJConfiguration
    func isDateSelected(date: NSDate) -> Bool
    func didSelectDate(date: NSDate)
    func calendarIsBeingAnimated() -> Bool
    
    func backgroundColorForDate(date: NSDate) -> UIColor?
    func textColorForDate(date: NSDate) -> UIColor?
}

public protocol MJCalendarViewDelegate {
    func didChangePeriod(periodDate: NSDate, calendarView: MJCalendarView)
    func backgroundColorForDate(date: NSDate, calendarView: MJCalendarView) -> UIColor?
    func textColorForDate(date: NSDate, calendarView: MJCalendarView) -> UIColor?
}

public class MJCalendarView: UIView, UIScrollViewDelegate, MJComponentDelegate {
    public var configuration: MJConfiguration
    var periods: [MJPeriodView]?
    var weekLabelsView: MJWeekLabelsView?
    var periodsContainerView: UIScrollView?
    
    var date: NSDate
    var visiblePeriodDate: NSDate!
    var currentFrame = CGRectZero
    var currentPage = 1
    public var calendarDelegate: MJCalendarViewDelegate?
    var isAnimating = false
    
    required public init(coder aDecoder: NSCoder) {
        self.configuration = MJConfiguration.getDefault()
        self.date = NSDate().dateAtStartOfDay()
        super.init(coder: aDecoder)
        self.visiblePeriodDate = self.startDate(self.date, withOtherMonth: false)
        self.configureViews()
    }
    
    override init(frame: CGRect) {
        self.configuration = MJConfiguration.getDefault()
        self.date = NSDate().dateAtStartOfDay()
        super.init(frame: frame)
        self.visiblePeriodDate = self.startDate(self.date, withOtherMonth: false)
        self.configureViews()
    }
    
    func configureViews() {
        self.weekLabelsView = MJWeekLabelsView(delegate: self)
        self.addSubview(self.weekLabelsView!)
        
        self.periodsContainerView = UIScrollView(frame: CGRectZero)
        self.periodsContainerView!.pagingEnabled = true
        self.periodsContainerView!.delegate = self
        self.periodsContainerView?.showsHorizontalScrollIndicator = false
        self.addSubview(self.periodsContainerView!)
        
        self.setPeriodViews()
    }
    
    func setPeriodViews() {
        let visibleDate = self.visiblePeriodDate
        let previousDate = self.previousPeriodDate(visibleDate, withOtherMonth: true)
        let currentDate = self.startDate(visibleDate, withOtherMonth: true)
        let nextDate = self.nextPeriodDate(visibleDate, withOtherMonth: true)
        
        if var periodViews = self.periods {
            periodViews[0].date = previousDate
            periodViews[1].date = currentDate
            periodViews[2].date = nextDate
            
            self.setPeriodFrames()
        } else {
            let previosPeriodView = MJPeriodView(date: previousDate, delegate: self)
            self.periodsContainerView!.addSubview(previosPeriodView)
            let currentPeriodView = MJPeriodView(date: currentDate, delegate: self)
            self.periodsContainerView!.addSubview(currentPeriodView)
            let nextPeriodView = MJPeriodView(date: nextDate, delegate: self)
            self.periodsContainerView!.addSubview(nextPeriodView)
            
            self.periods = [previosPeriodView, currentPeriodView, nextPeriodView]
        }
    }
    
    override public func layoutSubviews() {
        if !CGRectEqualToRect(self.currentFrame, self.frame) && !isAnimating {
            self.currentFrame = self.frame
            
            let weekLabelsViewHeight = self.configuration.weekLabelHeight
            self.periodsContainerView!.frame = CGRectMake(0, weekLabelsViewHeight, self.width(), self.height() - weekLabelsViewHeight)
            self.periodsContainerView!.contentSize = CGSizeMake(self.width() * 3, self.height() - weekLabelsViewHeight)
            
            self.setPeriodFrames()
        }
    }
    
    
    
    func setPeriodFrames() {
        let mod7 = self.width() % 7
        let width = self.width() - mod7
        let x = ceil(mod7 / 2)
        
        self.weekLabelsView?.frame = CGRectMake(x, 0, width, self.configuration.weekLabelHeight)
        
        for (index, period) in enumerate(self.periods!) {
            period.frame = CGRectMake(CGFloat(index) * self.width() + x, 0, width, self.periodHeight(self.configuration.periodType))
        }
        
        self.currentPage = 1
        self.periodsContainerView!.contentOffset.x = CGRectGetWidth(self.frame)
    }
    
    func periodHeight(periodType: MJConfiguration.PeriodType) -> CGFloat {
        return CGFloat(periodType.weeksCount()) * self.configuration.lineHeight
    }
    
    func startDate(date: NSDate, withOtherMonth: Bool) -> NSDate {
        if self.configuration.periodType == .Month {
            let beginningOfMonth = date.dateAtStartOfMonth()
            if withOtherMonth {
                return self.startWeekDay(beginningOfMonth)
            } else {
                return beginningOfMonth
            }
            
        } else {
            return self.startWeekDay(date)
        }
    }
    
    func startWeekDay(date: NSDate) -> NSDate {
        let delta = self.configuration.startDayType == .Monday ? 2 : 1
        var daysToSubstract = date.weekday - delta
        if daysToSubstract < 0 {
            daysToSubstract += 7
        }
        return date.dateBySubtractingDays(daysToSubstract)
    }
    
    func nextPeriodDate(date: NSDate, withOtherMonth: Bool) -> NSDate {
        return self.periodDate(date, isNext: true, withOtherMonth: withOtherMonth)
    }
    
    func previousPeriodDate(date: NSDate, withOtherMonth: Bool) -> NSDate {
        return self.periodDate(date, isNext: false, withOtherMonth: withOtherMonth)
    }
    
    func periodDate(date: NSDate, isNext: Bool, withOtherMonth: Bool) -> NSDate {
        let isNextFactor = isNext ? 1 : -1
        switch self.configuration.periodType {
        case .Month:
            let otherMonthDate = date.dateByAddingMonths(1 * isNextFactor)
            return self.startDate(otherMonthDate, withOtherMonth: withOtherMonth)
        case .ThreeWeeks: return date.dateByAddingDays((3 * isNextFactor) * 7)
        case .TwoWeeks: return date.dateByAddingDays((2 * isNextFactor) * 7)
        case .OneWeek: return date.dateByAddingDays((1 * isNextFactor) * 7)
        }
    }
    
    public func selectDate(date: NSDate) {
        if !self.isDateAlreadyShown(date) {
            let periodDate = self.startDate(date, withOtherMonth: false)
            self.visiblePeriodDate = date.timeIntervalSince1970 < self.date.timeIntervalSince1970
                ? self.retroPeriodDate(periodDate) : periodDate
            self.calendarDelegate?.didChangePeriod(periodDate, calendarView: self)
        }
        self.date = date
        self.setPeriodViews()
    }
    
    func retroPeriodDate(periodDate: NSDate) -> NSDate {
        switch self.configuration.periodType {
        case .Month: return periodDate
        case .ThreeWeeks: return periodDate.dateByAddingDays(-14)
        case .TwoWeeks: return periodDate.dateByAddingDays(-7)
        case .OneWeek: return periodDate
        }
    }
    
    func currentPeriod() -> MJPeriodView {
        return self.periods![1]
    }
    
    func isDateAlreadyShown(date: NSDate) -> Bool {
        if self.configuration.periodType == .Month {
            return date.dateAtStartOfMonth() == self.visiblePeriodDate.dateAtStartOfMonth()
        } else {
            return date.timeIntervalSince1970 >= self.currentPeriod().startingDate().timeIntervalSince1970
                &&  date.timeIntervalSince1970 <= self.currentPeriod().endingDate().timeIntervalSince1970
        }
    }
    
    // MARK: Calendar delegate
    
    func isDateSelected(date: NSDate) -> Bool {
        return self.date == date
    }
    
    func getConfiguration() -> MJConfiguration {
        return self.configuration
    }
    
    func didSelectDate(date: NSDate) {
        self.selectDate(date)
    }
    
    func calendarIsBeingAnimated() -> Bool {
        return self.isAnimating
    }
    
    func backgroundColorForDate(date: NSDate) -> UIColor? {
        return self.calendarDelegate?.backgroundColorForDate(date, calendarView: self)
    }
    
    func textColorForDate(date: NSDate) -> UIColor? {
        return self.calendarDelegate?.textColorForDate(date, calendarView: self)
    }
    
    // MARK: UIScrollViewDelegate
    
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = CGRectGetWidth(scrollView.frame)
        let ratio = scrollView.contentOffset.x / pageWidth
        let page = Int(ratio)

        let periodDate = self.periodDateFromPage(page)
        if self.visiblePeriodDate !=  periodDate {
            self.visiblePeriodDate = periodDate
            self.setPeriodViews()
            self.calendarDelegate?.didChangePeriod(periodDate, calendarView: self)
        }
    }
    
    func periodDateFromPage(page: Int) -> NSDate {
        if page == 0 {
            return self.previousPeriodDate(self.visiblePeriodDate, withOtherMonth: false)
        } else if page == 2 {
            return self.nextPeriodDate(self.visiblePeriodDate, withOtherMonth: false)
        } else {
            return self.visiblePeriodDate
        }
    }
    
    public func commitConfiguration() {
        self.visiblePeriodDate = self.recalculatedVisibleDate(false)
        
        if let periodViews = self.periods {
            for period in periodViews {
                period.removeFromSuperview()
            }
        }
        self.periods = nil
        self.currentFrame = CGRectZero
        
        self.setPeriodViews()
        self.weekLabelsView?.updateView()
    }
    
    func recalculatedVisibleDate(withOtherMonth: Bool) -> NSDate {
        let startDate = self.startDate(self.date, withOtherMonth: withOtherMonth)
        if self.configuration.periodType == .Month || self.configuration.periodType == .OneWeek {
            return startDate
        } else {
            let weekIndex = self.weekIndexByStartDate(startDate) + 1
            let weekCount = self.configuration.periodType.weeksCount()
            let visibleIndex = weekIndex - weekCount > 0 ? weekIndex - weekCount : 0
            return self.currentPeriod().weeks![visibleIndex].date
        }
    }
    
    func weekIndexByStartDate(startDate: NSDate) -> Int {
        for (index, week) in enumerate(self.currentPeriod().weeks!) {
            if week.date == startDate {
                return index
            }
        }
        
        return 0
    }
    
    public func animateToPeriodType(periodType: MJConfiguration.PeriodType, duration: NSTimeInterval, animations: (calendarHeight: CGFloat) -> Void, completion: ((Bool) -> Void)?) {
        let previousVisibleDate = self.visiblePeriodDate
        let previousPeriodType = self.configuration.periodType
        
        self.configuration.periodType = periodType
        let yDelta = self.periodYDelta(periodType, previousVisibleDate: previousVisibleDate)
        
        if periodType.weeksCount() > previousPeriodType.weeksCount() {
            self.commitConfiguration()
            self.setPeriodFrames()
            self.layoutIfNeeded()
            
            self.currentPeriod().setY(self.currentPeriod().y() + yDelta)
            self.currentPeriod().setHeight(self.periodHeight(previousPeriodType) - yDelta)
            
            self.performAnimation(true, periodType: periodType, yDelta: yDelta, duration: duration, animations: animations, completion: completion)
        } else {
            self.performAnimation(false, periodType: periodType, yDelta: yDelta, duration: duration, animations: animations, completion: completion)
        }
    }
    
    func periodYDelta(periodType: MJConfiguration.PeriodType, previousVisibleDate: NSDate) -> CGFloat {
        let visiblePeriodDatePreview = self.recalculatedVisibleDate(true)
        let deltaVisiblePeriod = visiblePeriodDatePreview.timeIntervalSince1970 - previousVisibleDate.timeIntervalSince1970
        let weekIndexDelta = ceil(deltaVisiblePeriod / (3600 * 24 * 7))
        return CGFloat(weekIndexDelta) * self.configuration.lineHeight
    }
    
    func performAnimation(animateToBiggerSize: Bool, periodType: MJConfiguration.PeriodType, yDelta: CGFloat, duration: NSTimeInterval, animations: (calendarHeight: CGFloat) -> Void, completion: ((Bool) -> Void)?) {
        self.isAnimating = true
        UIView.animateWithDuration(duration, animations: { () -> Void in
            animations(calendarHeight: self.periodHeight(periodType) + self.configuration.weekLabelHeight)
            if animateToBiggerSize {
                self.currentPeriod().setY(0)
                self.currentPeriod().setHeight(self.periodHeight(periodType))
            } else {
                self.currentPeriod().setY(self.currentPeriod().y() - yDelta)
                self.currentPeriod().setHeight(self.periodHeight(periodType) + yDelta)
            }
            
            }) { (completed) -> Void in
                self.isAnimating = false
                if !animateToBiggerSize {
                    self.commitConfiguration()
                    self.setPeriodFrames()
                }
                if let completionBlock = completion {
                    completionBlock(completed)
                }
        }
    }
}
