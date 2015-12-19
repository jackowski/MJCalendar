//
//  MJComponentView.swift
//  Pods
//
//  Created by Michał Jackowski on 17.12.2015.
//
//

import UIKit

protocol MJComponentDelegate {
    func getConfiguration() -> MJConfiguration
    func isDateSelected(date: NSDate) -> Bool
    func didSelectDate(date: NSDate)
    func calendarIsBeingAnimated() -> Bool
    
    func backgroundColorForDate(date: NSDate) -> UIColor?
    func textColorForDate(date: NSDate) -> UIColor?
}

public class MJComponentView: UIView {
    var delegate: MJComponentDelegate!
    
    init(delegate: MJComponentDelegate) {
        self.delegate = delegate
        super.init(frame: CGRectZero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
