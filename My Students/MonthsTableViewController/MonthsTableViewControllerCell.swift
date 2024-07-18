//
//  PaidMonthCell.swift
//  Accounting
//
//  Created by Марк Кулик on 24.04.2024.
//

import UIKit
import SnapKit

class MonthCell: UITableViewCell {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    let monthLabel: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.spacing = 10
        stackview.alignment = .fill
        stackview.distribution = .fill
        return stackview
    }()
    
    let monthYearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    lazy var totalSumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 1
        return label
    }()
    
    let paymentStatusLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = false
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Устанавливаем фон ячейки на прозрачный
        self.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(monthLabel)
        monthLabel.addArrangedSubview(monthYearLabel)
        monthLabel.addArrangedSubview(totalSumLabel)
        
        containerView.addSubview(paymentStatusLabel)
        containerView.addSubview(switchControl)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
            make.height.equalTo(70)
        }
        
        monthLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        paymentStatusLabel.snp.makeConstraints { make in
            make.trailing.equalTo(switchControl.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        switchControl.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with student: Student, month: Month, index: Int, target: Any?, action: Selector) {
        monthYearLabel.text = "\(month.monthName) \(month.monthYear)"
        
        let lessons = month.lessons
        let lessonsCount = Int(lessons.count)
        
        let lessonPrice = month.lessonPrice
        let moneySum = lessonsCount * (lessonPrice?.price ?? 0)
        
        totalSumLabel.text = String(format: "Total Sum: %.2f %@", moneySum, lessonPrice?.currency ?? "")
        
        switchControl.tag = index
        switchControl.isOn = month.isPaid
        switchControl.addTarget(target, action: action, for: .valueChanged)
        
        paymentStatusLabel.text = switchControl.isOn ? "Paid" : "Unpaid"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


