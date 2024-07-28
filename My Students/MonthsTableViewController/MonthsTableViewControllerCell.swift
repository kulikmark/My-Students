//
//  PaidMonthCell.swift
//  Accounting
//
//  Created by Марк Кулик on 24.04.2024.
//

//import UIKit
//import SnapKit
//
//class MonthsTableViewControllerCell: UITableViewCell {
//    
//    let monthLabel: UIStackView = {
//        let stackview = UIStackView()
//        stackview.axis = .vertical
//        stackview.spacing = 10
//        stackview.alignment = .fill
//        stackview.distribution = .fill
//        return stackview
//    }()
//    
//    let monthYearLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        label.textColor = .darkGray
//        label.numberOfLines = 1
//        return label
//    }()
//    
//    lazy var totalSumLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = .darkGray
//        label.numberOfLines = 1
//        return label
//    }()
//    
//    let paymentStatusLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .darkGray
//        label.isHidden = true
//        return label
//    }()
//    
//    let paidStatusButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Paid", for: .normal)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 5
//        return button
//    }()
//    
//    private var month: Month?
//    private weak var delegate: MonthsTableViewController?
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        self.backgroundColor = .white
//        
//        contentView.addSubview(monthLabel)
//        monthLabel.addArrangedSubview(monthYearLabel)
//        monthLabel.addArrangedSubview(totalSumLabel)
//        
//        contentView.addSubview(paymentStatusLabel)
//        contentView.addSubview(paidStatusButton)
//        
//        setupConstraints()
//        
//        paidStatusButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
//    }
//    
//    private func setupConstraints() {
//        monthLabel.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(20)
//            make.centerY.equalToSuperview()
//        }
//        
//        paymentStatusLabel.snp.makeConstraints { make in
////            make.trailing.equalTo(paidStatusButton.snp.leading).offset(-10)
//            make.trailing.equalToSuperview().inset(20)
//            make.centerY.equalToSuperview()
//        }
//        
//        paidStatusButton.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().inset(20)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(60)
//            make.height.equalTo(30)
//        }
//    }
//    
//    func configure(with student: Student, month: Month, delegate: MonthsTableViewController) {
//        self.month = month
//        self.delegate = delegate
//        monthYearLabel.text = "\(month.monthName) \(month.monthYear)"
//        
//        let moneySum = month.moneySum ?? 0
//        totalSumLabel.text = "Total Sum: \(String(moneySum)) \(student.lessonPrice.currency)"
//        
//        if month.isPaid {
//            paidStatusButton.isHidden = true
//            paymentStatusLabel.isHidden = false
//            paymentStatusLabel.text = "Paid on \(month.paymentDate)"
//        } else {
//            paidStatusButton.isHidden = false
//            paymentStatusLabel.isHidden = true
//        }
//    }
//    
//    @objc private func payButtonTapped() {
//        guard var month = month, let delegate = delegate else { return }
//        
//        // Создайте UIAlertController с UIDatePicker
//        let alertController = UIAlertController(title: "Select Payment Date", message: nil, preferredStyle: .alert)
//        
//        let datePicker = UIDatePicker()
//        datePicker.datePickerMode = .date
//        datePicker.preferredDatePickerStyle = .wheels
//        
//        alertController.view.addSubview(datePicker)
//        
//        // Добавьте ограничения для UIDatePicker
//        datePicker.snp.makeConstraints { make in
//            make.edges.equalToSuperview().inset(30)
//            make.height.width.equalTo(400)
//        }
//        
//        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            month.paymentDate = dateFormatter.string(from: datePicker.date)
//            
//            delegate.updatePaidStatus(for: month, isPaid: true)
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alertController.addAction(selectAction)
//        alertController.addAction(cancelAction)
//        
//        delegate.present(alertController, animated: true, completion: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

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
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .darkGray
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
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    let paidStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Paid", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let editDateButton: UIButton = {
        let button = UIButton(type: .system)
        let pencilImage = UIImage(systemName: "pencil")
        button.setImage(pencilImage, for: .normal)
        button.tintColor = .darkGray
        button.isHidden = true
        return button
    }()
    
    private var month: Month?
    private weak var delegate: MonthsTableViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white
        
        contentView.addSubview(monthLabel)
        monthLabel.addArrangedSubview(monthYearLabel)
        monthLabel.addArrangedSubview(totalSumLabel)
        
        contentView.addSubview(paymentStatusLabel)
        contentView.addSubview(paidStatusButton)
        contentView.addSubview(editDateButton)
        
        setupConstraints()
        
        paidStatusButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        editDateButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(payButtonTapped)))
        paymentStatusLabel.isUserInteractionEnabled = true
    }
    
    private func setupConstraints() {
        monthLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        paymentStatusLabel.snp.makeConstraints { make in
            make.trailing.equalTo(editDateButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        paidStatusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        editDateButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30) // Установите одинаковую ширину и высоту для иконки
        }
    }
    
    func configure(with student: Student, month: Month, delegate: MonthsTableViewController) {
        self.month = month
        self.delegate = delegate
        monthYearLabel.text = "\(month.monthName) \(month.monthYear)"
        
        let moneySum = month.moneySum ?? 0
        totalSumLabel.text = "Total Sum: \(String(moneySum)) \(student.lessonPrice.currency)"
        
        if month.isPaid {
            paidStatusButton.isHidden = true
            editDateButton.isHidden = false
            paymentStatusLabel.isHidden = false
            paymentStatusLabel.text = "Paid on \(month.paymentDate)"
        } else {
            paidStatusButton.isHidden = false
            editDateButton.isHidden = true
            paymentStatusLabel.isHidden = true
        }
        editDateButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
    }
    
    @objc private func payButtonTapped() {
        guard var month = month, let delegate = delegate else { return }
        
        // Создайте UIAlertController с UIDatePicker
        let alertController = UIAlertController(title: "Select Payment Date", message: nil, preferredStyle: .alert)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        alertController.view.addSubview(datePicker)
        
        // Добавьте ограничения для UIDatePicker
        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(30)
            make.height.equalTo(300)
        }
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            month.paymentDate = dateFormatter.string(from: datePicker.date)
            
            delegate.updatePaidStatus(for: month, isPaid: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        delegate.present(alertController, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
