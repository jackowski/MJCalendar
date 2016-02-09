//
//  MJComponentView.swift
//  Pods
//
//  Created by Michał Jackowski on 17.12.2015.
//
//

import UIKit

protocol MJComponentDelegate {
    func configurationWithComponent(componentView: MJComponentView) -> MJConfiguration
    func componentView(componentView: MJComponentView, isDateSelected date: NSDate) -> Bool
    func componentView(componentView: MJComponentView, didSelectDate date: NSDate)
    func isBeingAnimatedWithComponentView(componentView: MJComponentView) -> Bool
    func componentView(componentView: MJComponentView, backgroundColorForDate date: NSDate) -> UIColor?
    func componentView(componentView: MJComponentView, textColorForDate date: NSDate) -> UIColor?
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

/*
extension NSDate {
    func dateByAddingEfficientlyDays(days: Int) -> NSDate {
        return self.dateByAddingDays(days)
    }
}
*/