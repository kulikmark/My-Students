//
//  StudentTableViewCell.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import SnapKit

class StudentCollectionViewCell: UICollectionViewCell {
    
    var student: Student?
    var isEditing: Bool = false {
        didSet {
            editButton.isHidden = !isEditing
            deleteButton.isHidden = !isEditing
            animateShake(isEditing: isEditing)
        }
    }

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = .zero
        return imageView
    }()
    
    lazy var studentNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let editButton: UIButton = {
            let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.isHidden = true
       
            return button
        }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "trash.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .red
        button.isHidden = true
        return button
    }()
    
    var editAction: (() -> Void)?
    var showDeleteConfirmation: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(studentNameLabel)
        containerView.addSubview(scheduleLabel)
        containerView.addSubview(editButton)
        contentView.addSubview(deleteButton)
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(containerView.snp.width).inset(10)
        }
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        
        studentNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.width.equalTo(containerView.snp.width)
            make.centerX.equalToSuperview()
        }
        
        scheduleLabel.snp.makeConstraints { make in
            make.top.equalTo(studentNameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(containerView).inset(5)
        }
        
        editButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(containerView.snp.width).inset(10)
            make.height.equalTo(30)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(5)
        }
    }
    
    @objc private func editButtonTapped() {
            editAction?()
        }
    
    @objc func deleteButtonTapped() {
        showDeleteConfirmation?()
    }
    
    func configure(with student: Student) {
        self.student = student
        
        studentNameLabel.text = student.name
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
        if !student.studentImage.isEmpty {
                  if let image = UIImage(contentsOfFile: student.studentImage) {
                      profileImageView.image = image
                  } else {
                      profileImageView.image = UIImage(named: "defaultImage")
                  }
              } else {
                  profileImageView.image = UIImage(named: "defaultImage")
              }
        
        updateScheduleTextField()
    }

    func updateScheduleTextField() {
        var scheduleStrings = [String]()
        
        // Проверяем, что у студента есть расписание и оно отсортировано по дням недели
        if let student = student {
            let sortedSchedules = student.schedule.sorted(by: { orderOfDay($0.weekday) < orderOfDay($1.weekday) })
            scheduleStrings = sortedSchedules.map { "\($0.weekday) \($0.time)" }
        }
        
        // Формируем строку расписания
        let formattedSchedule = scheduleStrings.joined(separator: ", ")
        
        // Обновляем текст метки в зависимости от наличия расписания
        if formattedSchedule.isEmpty {
            scheduleLabel.text = "Schedule not yet added"
        } else {
            scheduleLabel.text = formattedSchedule
        }
    }
    
    func orderOfDay(_ weekday: String) -> Int {
        switch weekday {
        case "MON": return 0
        case "TUE": return 1
        case "WED": return 2
        case "THU": return 3
        case "FRI": return 4
        case "SAT": return 5
        case "SUN": return 6
        default: return 7
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateShake(isEditing: Bool) {
        if isEditing {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            let additionalRotation = CGFloat(0.1 * (.pi / 180.0))
            let shakeRotation = CGFloat(0.005)
            
            animation.fromValue = -shakeRotation - additionalRotation
            animation.toValue = shakeRotation + additionalRotation
            animation.duration = 0.15
            animation.repeatCount = .infinity
            animation.autoreverses = true
            
            layer.add(animation, forKey: "shake")
        } else {
            layer.removeAnimation(forKey: "shake")
        }
    }
}
