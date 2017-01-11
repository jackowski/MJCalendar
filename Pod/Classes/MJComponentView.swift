//
//  MJComponentView.swift
//  Pods
//
//  Created by Michał Jackowski on 17.12.2015.
//
//

import UIKit

protocol MJComponentDelegate: NSObjectProtocol {
    func configurationWithComponent(_ componentView: MJComponentView) -> MJConfiguration
    func componentView(_ componentView: MJComponentView, isDateSelected date: Date) -> Bool
    func componentView(_ componentView: MJComponentView, didSelectDate date: Date)
    func isBeingAnimatedWithComponentView(_ componentView: MJComponentView) -> Bool
    func componentView(_ componentView: MJComponentView, backgroundColorForDate date: Date) -> UIColor?
    func componentView(_ componentView: MJComponentView, textColorForDate date: Date) -> UIColor?
    func isDateOutOfRange(_ componentView: MJComponentView, date: Date) -> Bool
}

open class MJComponentView: UIView {
    weak var delegate: MJComponentDelegate!
    var currentFrame = CGRect.zero
    
    init(delegate: MJComponentDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        if !self.currentFrame.equalTo(self.frame) {
            self.currentFrame = self.frame
            self.updateFrame()
        }
    }
    
    func updateFrame() {
        fatalError("updateFrame has not been implemented")
    }
}
