//
//  MJWeekLabelsView.swift
//  Pods
//
//  Created by Michał Jackowski on 23.11.2015.
//
//

import UIKit

class MJWeekLabelsView: MJComponentView {
    var weekLabels: [UILabel] = []

    lazy var formatter = DateFormatter()
    var dayWeekText:[String] {
        var dayWeekText:[String] = []
        var dayIndex: Int

        for index in 1...7 {

            switch self.delegate.configurationWithComponent(self).startDayType {
            case .monday:
                dayIndex = index % 7
            case .sunday:
                dayIndex = index - 1
            }

            let day : NSString = formatter.weekdaySymbols[dayIndex] as NSString
            dayWeekText.append(day.substring(to: delegate.configurationWithComponent(self).lettersInWeekDayLabel.rawValue).uppercased())
        }

        return dayWeekText
    }

    override init(delegate: MJComponentDelegate) {
        super.init(delegate: delegate)
        self.setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpView() {
        for i: Int in 0...6 {
            let label = UILabel()
            label.font = self.delegate.configurationWithComponent(self).weekLabelFont
            label.textColor = self.delegate.configurationWithComponent(self).weekLabelTextColor
            label.text = self.dayWeekText[i]
            label.textAlignment = .center
            self.addSubview(label)
            self.weekLabels.append(label)
        }
    }
    
    func updateView() {
        for (index, weekLabel) in self.weekLabels.enumerated() {
            weekLabel.font = self.delegate.configurationWithComponent(self).weekLabelFont
            weekLabel.textColor = self.delegate.configurationWithComponent(self).weekLabelTextColor
            weekLabel.text = self.dayWeekText[index]
        }
    }
    
    override func updateFrame() {
        for (index, weekLabel) in self.weekLabels.enumerated() {
            let labelWidth: CGFloat = self.width() / 7
            weekLabel.frame = CGRect(x: CGFloat(index) * labelWidth, y: 0, width: labelWidth, height: self.height())
        }
    }
}
