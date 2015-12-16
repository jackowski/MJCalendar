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
        case OneWeek, TwoWeeks, ThreeWeeks, Month
        func weeksCount() -> Int {
            switch self {
            case .Month: return 6
            case .ThreeWeeks: return 3
            case .TwoWeeks: return 2
            case .OneWeek: return 1
            }
        }
    }
    
    public enum DayViewType {
        case Square, Circle
    }
    
    public enum StartDayType {
        case Monday, Sunday
    }
    
    public var periodType: PeriodType = .TwoWeeks
    public var dayViewType: DayViewType = .Square
    public var startDayType: StartDayType = .Monday
    
    public var lineHeight: CGFloat = 30
    public var dayViewSize: CGSize = CGSizeMake(26, 26)
    public var dayTextFont = UIFont.systemFontOfSize(12)
    public var otherMonthBackgroundColor = UIColor.clearColor()
    public var otherMonthTextColor = UIColor.whiteColor()
    public var dayBackgroundColor = UIColor.blueColor()
    public var dayTextColor = UIColor.whiteColor()
    public var selectedDayBackgroundColor = UIColor.whiteColor()
    public var selectedDayTextColor = UIColor.redColor()
    public var weekLabelFont = UIFont.systemFontOfSize(13)
    public var weekLabelTextColor = UIColor.whiteColor()
    public var weekLabelHeight: CGFloat = 20
    
    static func getDefault() -> MJConfiguration {
        let configuration = MJConfiguration()
        return configuration
    }
}
