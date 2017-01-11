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

public protocol MJCalendarViewDelegate: NSObjectProtocol {
    func calendar(_ calendarView: MJCalendarView, didChangePeriod periodDate: Date, bySwipe: Bool)
    func calendar(_ calendarView: MJCalendarView, didSelectDate date: Date)
    func calendar(_ calendarView: MJCalendarView, backgroundForDate date: Date) -> UIColor?
    func calendar(_ calendarView: MJCalendarView, textColorForDate date: Date) -> UIColor?
}

open class MJCalendarView: UIView, UIScrollViewDelegate, MJComponentDelegate {
    open var configuration: MJConfiguration
    var periods: [MJPeriodView]?
    var weekLabelsView: MJWeekLabelsView?
    var periodsContainerView: UIScrollView?
    
    var date: Date
    var visiblePeriodDate: Date!
    var currentFrame = CGRect.zero
    weak open var calendarDelegate: MJCalendarViewDelegate?
    var isAnimating = false
    
    var currentPage: Int!
    
    required public init?(coder aDecoder: NSCoder) {
        self.configuration = MJConfiguration.getDefault()
        self.date = NSDate().atStartOfDay() as Date
        super.init(coder: aDecoder)
        self.visiblePeriodDate = self.startDate(self.date, withOtherMonth: false)
        self.configureViews()
    }
    
    override init(frame: CGRect) {
        self.configuration = MJConfiguration.getDefault()
        self.date = NSDate().atStartOfDay()
        super.init(frame: frame)
        self.visiblePeriodDate = self.startDate(self.date, withOtherMonth: false)
        self.configureViews()
    }
    
    func configureViews() {
        self.weekLabelsView = MJWeekLabelsView(delegate: self)
        self.addSubview(self.weekLabelsView!)
        
        self.periodsContainerView = UIScrollView(frame: CGRect.zero)
        self.periodsContainerView!.isPagingEnabled = true
        self.periodsContainerView!.delegate = self
        self.periodsContainerView?.showsHorizontalScrollIndicator = false
        self.addSubview(self.periodsContainerView!)
        
        self.setPeriodViews()
    }
    
    func setPeriodViews() {
        let visibleDate = self.visiblePeriodDate
        let previousDate = self.previousPeriodDate(visibleDate!, withOtherMonth: true)
        let currentDate = self.startDate(visibleDate!, withOtherMonth: true)
        let nextDate = self.nextPeriodDate(visibleDate!, withOtherMonth: true)
        
        if var periodViews = self.periods {
            if self.shouldChangePeriodsRange() {
                if self.periods?.count == 3 {
                    periodViews[0].date = previousDate
                    periodViews[1].date = currentDate
                    periodViews[2].date = nextDate
                    
                    self.currentPage = 1
                    self.setPeriodFrames()
                } else {
                    self.createPeriodsViews(previousDate, currentDate: currentDate, nextDate: nextDate)
                    self.setPeriodFrames()
                }
            } else {
                for periodView in periodViews {
                    periodView.configureViews()
                }
            }
        } else {
            self.createPeriodsViews(previousDate, currentDate: currentDate, nextDate: nextDate)
        }
    }
    
    func createPeriodsViews(_ previousDate: Date, currentDate: Date, nextDate: Date) {
        self.clearView()
        self.periods = []
        
        let previosPeriodView = MJPeriodView(date: previousDate, delegate: self)
        if !isDateEarlierThanMin(previosPeriodView.endingPeriodDate()) {
            self.periodsContainerView!.addSubview(previosPeriodView)
            self.periods!.append(previosPeriodView)
        }
        
        let currentPeriodView = MJPeriodView(date: currentDate, delegate: self)
        self.periodsContainerView!.addSubview(currentPeriodView)
        self.periods!.append(currentPeriodView)
        
        let nextPeriodView = MJPeriodView(date: nextDate, delegate: self)
        if !isDateLaterThanMax(nextPeriodView.startingPeriodDate()) {
            self.periodsContainerView!.addSubview(nextPeriodView)
            self.periods!.append(nextPeriodView)
        }
        
        self.currentPage = self.periods!.index(of: currentPeriodView)
    }
    
    func shouldChangePeriodsRange() -> Bool {
        let startDateOfPeriod = self.visiblePeriodDate
        let endDateOfPeriod = nextPeriodDate(self.visiblePeriodDate, withOtherMonth: false)
        return !(self.isDateEarlierThanMin(startDateOfPeriod!) || self.isDateLaterThanMax(endDateOfPeriod))
    }
    
    func isDateEarlierThanMin(_ date: Date) -> Bool {
        if let minDate = (configuration.minDate as? NSDate)?.atStartOfDay() {
            if (date as NSDate).isEarlierThanDate(minDate) {
                return true
            }
        }
        
        return false
    }
    
    func isDateLaterThanMax(_ date: Date) -> Bool {
        if let maxDate = (configuration.maxDate as? NSDate)?.atEndOfDay() {
            if (date as NSDate).isLaterThanDate(maxDate) {
                return true
            }
        }
        
        return false
    }
    
    override open func layoutSubviews() {
        if !self.currentFrame.equalTo(self.frame) && !isAnimating {
            self.currentFrame = self.frame
            
            let weekLabelsViewHeight = self.configuration.weekLabelHeight
            self.periodsContainerView!.frame = CGRect(x: 0, y: weekLabelsViewHeight, width: self.width(), height: self.height() - weekLabelsViewHeight)
            
            self.setPeriodFrames()
        }
    }
    
    func setPeriodFrames() {
        let mod7 = self.width().truncatingRemainder(dividingBy: 7)
        let width = self.width() - mod7
        let x = ceil(mod7 / 2)
        
        self.weekLabelsView?.frame = CGRect(x: x, y: 0, width: width, height: self.configuration.weekLabelHeight)
        
        for (index, period) in (self.periods!).enumerated() {
            
            period.frame = CGRect(x: CGFloat(index) * self.width() + x,y: 0,width: width, height: self.periodHeight(self.configuration.periodType))
        }
        
        self.periodsContainerView!.contentSize = CGSize(width: self.width() * CGFloat(self.periods!.count), height: self.height() - self.configuration.weekLabelHeight)
        self.periodsContainerView!.contentOffset.x = self.frame.width * CGFloat(self.currentPage)
    }
    
    func periodHeight(_ periodType: MJConfiguration.PeriodType) -> CGFloat {
        return CGFloat(periodType.weeksCount()) * self.configuration.rowHeight
    }
    
    func startDate(_ date: Date, withOtherMonth: Bool) -> Date {
        if self.configuration.periodType == .month {
            let beginningOfMonth = (date as NSDate).atStartOfMonth()
            if withOtherMonth {
                return self.startWeekDay(beginningOfMonth)
            } else {
                return beginningOfMonth
            }
            
        } else {
            return self.startWeekDay(date)
        }
    }
    
    func startWeekDay(_ date: Date) -> Date {
        let delta = self.configuration.startDayType == .monday ? 2 : 1
        var daysToSubstract = (date as NSDate).weekday - delta
        if daysToSubstract < 0 {
            daysToSubstract += 7
        }
        return (date as NSDate).subtractingDays(daysToSubstract)
    }
    
    func nextPeriodDate(_ date: Date, withOtherMonth: Bool) -> Date {
        return self.periodDate(date, isNext: true, withOtherMonth: withOtherMonth)
    }
    
    func previousPeriodDate(_ date: Date, withOtherMonth: Bool) -> Date {
        return self.periodDate(date, isNext: false, withOtherMonth: withOtherMonth)
    }
    
    func periodDate(_ date: Date, isNext: Bool, withOtherMonth: Bool) -> Date {
        let isNextFactor = isNext ? 1 : -1
        switch self.configuration.periodType {
            case .month:
                let otherMonthDate = (date as NSDate).addingMonths(1 * isNextFactor)
                return self.startDate(otherMonthDate, withOtherMonth: withOtherMonth)
            case .threeWeeks: return (date as NSDate).addingDays((3 * isNextFactor) * 7)
            case .twoWeeks: return (date as NSDate).addingDays((2 * isNextFactor) * 7)
            case .oneWeek: return (date as NSDate).addingDays((1 * isNextFactor) * 7)
        }
    }
    
    open func selectDate(_ date: Date) {
        let validatedDate = dateInRange(date)
        if !self.isDateAlreadyShown(validatedDate) {
            let periodDate = self.startDate(validatedDate, withOtherMonth: false)
            self.visiblePeriodDate = validatedDate.timeIntervalSince1970 < self.date.timeIntervalSince1970
                ? self.retroPeriodDate(periodDate) : periodDate
            self.calendarDelegate?.calendar(self, didChangePeriod: periodDate, bySwipe: false)
        }
        self.date = validatedDate
        self.setPeriodViews()
    }
    
    func selectNewPeriod(_ date: Date) {
        let validatedDate = dateInRange(date)
        if !self.isDateAlreadyShown(validatedDate) {
            let periodDate = self.startDate(validatedDate, withOtherMonth: false)
            self.visiblePeriodDate = periodDate
            self.calendarDelegate?.calendar(self, didChangePeriod: periodDate, bySwipe: false)
        }
        self.date = validatedDate
        self.setPeriodViews()
    }
    
    open func moveToNextPeriod() {
        if let nextPeriodDate = self.periods?.last?.startingPeriodDate() {
            selectNewPeriod(nextPeriodDate as Date)
            calendarDelegate?.calendar(self, didChangePeriod: nextPeriodDate as Date, bySwipe: true)
        }
    }
    
    open func moveToPreviousPeriod() {
        if let previousPeriodDate = self.periods?.first?.startingPeriodDate() {
            selectNewPeriod(previousPeriodDate as Date)
            calendarDelegate?.calendar(self, didChangePeriod: previousPeriodDate as Date, bySwipe: true)
        }
    }
    
    func dateInRange(_ date: Date) -> Date {
        if isDateEarlierThanMin(date) {
            return (configuration.minDate! as NSDate).atStartOfDay()
        } else {
            return date
        }
    }
    
    func retroPeriodDate(_ periodDate: Date) -> Date {
        switch self.configuration.periodType {
            case .month: return periodDate
            case .threeWeeks: return (periodDate as NSDate).addingDays(-14)
            case .twoWeeks: return (periodDate as NSDate).addingDays(-7)
            case .oneWeek: return periodDate
        }
    }
    
    func currentPeriod() -> MJPeriodView {
        return self.periods![self.currentPage]
    }
    
    func isDateAlreadyShown(_ date: Date) -> Bool {
        if self.configuration.periodType == .month {
            return (date as NSDate).atStartOfMonth() == (self.visiblePeriodDate as NSDate).atStartOfMonth()
        } else {
            return date.timeIntervalSince1970 >= self.currentPeriod().startingDate().timeIntervalSince1970
                &&  date.timeIntervalSince1970 <= self.currentPeriod().endingDate().timeIntervalSince1970
        }
    }
    
    // MARK: Calendar delegate
    
    func componentView(_ componentView: MJComponentView, isDateSelected date: Date) -> Bool {
        return self.date == date
    }
    
    func configurationWithComponent(_ componentView: MJComponentView) -> MJConfiguration {
        return self.configuration
    }
    
    func componentView(_ componentView: MJComponentView, didSelectDate date: Date) {
        self.selectDate(date)
        self.calendarDelegate?.calendar(self, didSelectDate: date)
    }
    
    func isBeingAnimatedWithComponentView(_ componentView: MJComponentView) -> Bool {
        return self.isAnimating
    }
    
    func componentView(_ componentView: MJComponentView, backgroundColorForDate date: Date) -> UIColor? {
        return self.calendarDelegate?.calendar(self, backgroundForDate: date)
    }
    
    func componentView(_ componentView: MJComponentView, textColorForDate date: Date) -> UIColor? {
        return self.calendarDelegate?.calendar(self, textColorForDate: date)
    }
    
    func isDateOutOfRange(_ componentView: MJComponentView, date: Date) -> Bool {
        return isDateLaterThanMax(date) || isDateEarlierThanMin(date)
    }
    
    // MARK: UIScrollViewDelegate
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let ratio = scrollView.contentOffset.x / pageWidth
        let page = Int(ratio)

        let periodDate = self.periodDateFromPage(page)
        if self.visiblePeriodDate !=  periodDate {
            self.currentPage = page
            self.visiblePeriodDate = periodDate
            self.calendarDelegate?.calendar(self, didChangePeriod: periodDate, bySwipe: true)
            if self.configuration.selectDayOnPeriodChange {
                self.selectDate(periodDate)
            } else {
                self.setPeriodViews()
            }
        }
    }
    
    func periodDateFromPage(_ page: Int) -> Date {
        return periods![page].startingPeriodDate() as Date
    }
    
    open func reloadView() {
        self.visiblePeriodDate = self.recalculatedVisibleDate(false)
        self.clearView()
        self.setPeriodViews()
        self.setPeriodFrames()
        self.weekLabelsView?.updateView()
    }
    
    func clearView() {
        if let periodViews = self.periods {
            for period in periodViews {
                period.removeFromSuperview()
            }
        }
        
        self.periods = nil
        self.currentFrame = CGRect.zero
    }
    
    func recalculatedVisibleDate(_ withOtherMonth: Bool) -> Date {
        let visibleDate = self.currentPeriod().isDateInPeriod(self.date) ? self.date : self.visiblePeriodDate
        let startDate = self.startDate(visibleDate!, withOtherMonth: withOtherMonth)
        if self.configuration.periodType == .month || self.configuration.periodType == .oneWeek {
            return startDate
        } else {
            let weekIndex = self.weekIndexByStartDate(startDate) + 1
            let weekCount = self.configuration.periodType.weeksCount()
            let visibleIndex = weekIndex - weekCount > 0 ? weekIndex - weekCount : 0
            return self.currentPeriod().weeks![visibleIndex].date
        }
    }
    
    func weekIndexByStartDate(_ startDate: Date) -> Int {
        for (index, week) in (self.currentPeriod().weeks!).enumerated() {
            if week.date == startDate {
                return index
            }
        }
        
        return 0
    }
    
    open func reloadDayViews() {
        for periodView in self.periods! {
            for weekView in periodView.weeks! {
                for dayView in weekView.days! {
                    dayView.updateView()
                }
            }
        }
    }
    
    open func animateToPeriodType(_ periodType: MJConfiguration.PeriodType, duration: TimeInterval, animations: @escaping (_ calendarHeight: CGFloat) -> Void, completion: ((Bool) -> Void)?) {
        let previousVisibleDate = self.visiblePeriodDate
        let previousPeriodType = self.configuration.periodType
        
        self.configuration.periodType = periodType
        let yDelta = self.periodYDelta(periodType, previousVisibleDate: previousVisibleDate!)
        
        if periodType.weeksCount() > previousPeriodType.weeksCount() {
            self.reloadView()
            self.layoutIfNeeded()
            
            self.currentPeriod().setY(self.currentPeriod().y() + yDelta)
            self.currentPeriod().setHeight(self.periodHeight(previousPeriodType) - yDelta)
            
            self.performAnimation(true, periodType: periodType, yDelta: yDelta, duration: duration, animations: animations, completion: completion)
        } else {
            self.performAnimation(false, periodType: periodType, yDelta: yDelta, duration: duration, animations: animations, completion: completion)
        }
    }
    
    func periodYDelta(_ periodType: MJConfiguration.PeriodType, previousVisibleDate: Date) -> CGFloat {
        let visiblePeriodDatePreview = self.recalculatedVisibleDate(true)
        let deltaVisiblePeriod = visiblePeriodDatePreview.timeIntervalSince1970 - previousVisibleDate.timeIntervalSince1970
        let weekIndexDelta = ceil(deltaVisiblePeriod / (3600 * 24 * 7))
        return CGFloat(weekIndexDelta) * self.configuration.rowHeight
    }
    
    func performAnimation(_ animateToBiggerSize: Bool, periodType: MJConfiguration.PeriodType, yDelta: CGFloat, duration: TimeInterval, animations: @escaping (_ calendarHeight: CGFloat) -> Void, completion: ((Bool) -> Void)?) {
        self.isAnimating = true
        UIView.animate(withDuration: duration, animations: { () -> Void in
            animations(self.periodHeight(periodType) + self.configuration.weekLabelHeight)
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
                    self.reloadView()
                    self.setPeriodFrames()
                }
                self.calendarDelegate?.calendar(self, didChangePeriod: self.visiblePeriodDate, bySwipe: false)
                
                if let completionBlock = completion {
                    completionBlock(completed)
                }
        }
    }
}
