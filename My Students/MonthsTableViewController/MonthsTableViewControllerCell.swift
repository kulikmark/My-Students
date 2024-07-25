//
//  PaidMonthCell.swift
//  Accounting
//
//  Created by Марк Кулик on 24.04.2024.
//

import UIKit
import SnapKit

class MonthsTableViewControllerCell: UITableViewCell {
    
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
        
        contentView.addSubview(monthLabel)
        monthLabel.addArrangedSubview(monthYearLabel)
        monthLabel.addArrangedSubview(totalSumLabel)
        
        contentView.addSubview(paymentStatusLabel)
        contentView.addSubview(switchControl)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
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
    
    // Configure method
//    func configure(with student: Student, month: Month, lessons: [Lesson], index: Int, target: Any?, action: Selector) {
//        monthYearLabel.text = "\(month.monthName) \(month.monthYear)"
//        
//        let lessonsCount = lessons.count
//        let lessonPrice = student.lessonPrice
//        let moneySum = lessonsCount * lessonPrice.price
//        
//        // Проверка значений перед установкой
//            print("Lessons Count: \(lessonsCount)")
//            print("Lesson Price: \(lessonPrice.price)")
//            print("Calculated Money Sum: \(moneySum)")
//        
//        totalSumLabel.text = "Total Sum: \(String(moneySum)) \(lessonPrice.currency)"
//
//        // Ensure the layout is updated
//        totalSumLabel.setNeedsDisplay()
//              contentView.setNeedsLayout()
//              contentView.layoutIfNeeded()
//        
//        switchControl.tag = index
//        switchControl.isOn = month.isPaid
//        switchControl.addTarget(target, action: action, for: .valueChanged)
//        
//        paymentStatusLabel.text = switchControl.isOn ? "Paid" : "Unpaid"
//        
//        print("Total Sum Label Text: \(totalSumLabel.text ?? "nil")")
//    }
    
    func configure(with student: Student, month: Month, lessons: [Lesson], index: Int, target: Any?, action: Selector) {
        monthYearLabel.text = "\(month.monthName) \(month.monthYear)"
        
        // Используем сохраненную сумму вместо пересчета
        let moneySum = month.moneySum ?? 0
        
        totalSumLabel.text = "Total Sum: \(String(moneySum)) \(student.lessonPrice.currency)"
        
        print("totalSumLabel \(totalSumLabel.text)")
        
        switchControl.tag = index
        switchControl.isOn = month.isPaid
        switchControl.addTarget(target, action: action, for: .valueChanged)
        
        paymentStatusLabel.text = switchControl.isOn ? "Paid" : "Unpaid"
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
