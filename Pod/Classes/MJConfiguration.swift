//
//  MJConfiguration.swift
//  Pods
//
//  Created by Michał Jackowski on 18.09.2015.
//
//

import Foundation

public struct MJConfiguration {
    public enum PeriodType {
        case oneWeek, twoWeeks, threeWeeks, month
        func weeksCount() -> Int {
            switch self {
                case .month: return 6
                case .threeWeeks: return 3
                case .twoWeeks: return 2
                case .oneWeek: return 1
            }
        }
    }
    
    public enum DayViewType {
        case square, circle
    }
    
    public enum StartDayType {
        case monday, sunday
    }

    public enum LettersInWeekDay: Int {
        case one = 1
        case two
        case three
    }

    public enum SelectedDayType {
        case filled, border
    }

    public var lettersInWeekDayLabel:LettersInWeekDay = .three

    public var periodType: PeriodType = .month
    public var dayViewType: DayViewType = .circle
    public var startDayType: StartDayType = .monday
    public var selectedDayType: SelectedDayType = .border
    
    public var rowHeight: CGFloat = 30
    public var dayViewSize: CGSize = CGSize(width: 24, height: 24)
    public var dayTextFont = UIFont.systemFont(ofSize: 12)
    
    public var otherMonthBackgroundColor = UIColor.clear
    public var otherMonthDayViewBackgroundColor = UIColor.clear
    public var otherMonthTextColor = UIColor.clear
    
    public var dayBackgroundColor = UIColor.clear
    public var dayDayViewBackgroundColor = UIColor.clear
    public var dayTextColor = UIColor.clear
    
    public var selectedDayBackgroundColor = UIColor.clear
    public var selectedDayTextColor = UIColor.clear
    public var selectedBorderWidth: CGFloat = 1
    
    public var weekLabelFont = UIFont.systemFont(ofSize: 12)
    public var weekLabelTextColor = UIColor.clear
    public var weekLabelHeight: CGFloat = 25
    
    public var minDate: Date?
    public var maxDate: Date?
    
    public var outOfRangeDayBackgroundColor = UIColor.clear
    public var outOfRangeDayTextColor = UIColor.clear
    
    public var selectDayOnPeriodChange: Bool = true
    
    static func getDefault() -> MJConfiguration {
        let configuration = MJConfiguration()
        return configuration
    }
}
