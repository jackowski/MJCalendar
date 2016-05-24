//
//  MJComponentView.swift
//  Pods
//
//  Created by Michał Jackowski on 17.12.2015.
//
//

import UIKit

protocol MJComponentDelegate: NSObjectProtocol {
    func configurationWithComponent(componentView: MJComponentView) -> MJConfiguration
    func componentView(componentView: MJComponentView, isDateSelected date: NSDate) -> Bool
    func componentView(componentView: MJComponentView, didSelectDate date: NSDate)
    func isBeingAnimatedWithComponentView(componentView: MJComponentView) -> Bool
    func componentView(componentView: MJComponentView, backgroundColorForDate date: NSDate) -> UIColor?
    func componentView(componentView: MJComponentView, textColorForDate date: NSDate) -> UIColor?
    func isDateOutOfRange(componentView: MJComponentView, date: NSDate) -> Bool
}

public class MJComponentView: UIView {
    weak var delegate: MJComponentDelegate!
    var currentFrame = CGRectZero
    
    init(delegate: MJComponentDelegate) {
        self.delegate = delegate
        super.init(frame: CGRectZero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        if !CGRectEqualToRect(self.currentFrame, self.frame) {
            self.currentFrame = self.frame
            self.updateFrame()
        }
    }
    
    func updateFrame() {
        fatalError("updateFrame has not been implemented")
    }
}