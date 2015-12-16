//
//  MJWeekLabelsView.swift
//  Pods
//
//  Created by Michał Jackowski on 23.11.2015.
//
//

import UIKit

class MJWeekLabelsView: UIView {
    var delegate: MJComponentDelegate!
    var weekLabels: [UILabel] = []
    var dayWeekText: [String] {
        if self.delegate.getConfiguration().startDayType == .Monday {
            return [
                "MON",
                "TUE",
                "WED",
                "THU",
                "FRI",
                "SAT",
                "SUN"
            ]
        } else {
            return [
                "SUN",
                "MON",
                "TUE",
                "WED",
                "THU",
                "FRI",
                "SAT"
            ]
        }
    }

    init(delegate: MJComponentDelegate) {
        self.delegate = delegate
        super.init(frame: CGRectZero)
        self.setUpView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpView() {
        for i: Int in 0...6 {
            let label = UILabel()
            label.font = self.delegate.getConfiguration().weekLabelFont
            label.textColor = self.delegate.getConfiguration().weekLabelTextColor
            label.text = self.dayWeekText[i]
            label.textAlignment = .Center
            self.addSubview(label)
            self.weekLabels.append(label)
        }
    }
    
    override func layoutSubviews() {
        for (index, weekLabel) in enumerate(self.weekLabels) {
            let labelWidth: CGFloat = self.width() / 7
            weekLabel.frame = CGRectMake(CGFloat(index) * labelWidth, 0, labelWidth, self.height())
        }
    }
}
