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
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        return label
    }()
    
    lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .darkGray
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "trash.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .red
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var showDeleteConfirmation: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        contentView.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(studentNameLabel)
        containerView.addSubview(scheduleLabel)
        contentView.addSubview(deleteButton)
        
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
        
        studentNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        scheduleLabel.snp.makeConstraints { make in
            make.top.equalTo(studentNameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(containerView).inset(5)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(5)
        }
    }
    
    @objc func deleteButtonTapped() {
        showDeleteConfirmation?()
    }
    
    func configure(with student: Student, image: UIImage?) {
        self.student = student
        
        if let profileImage = image {
            profileImageView.image = profileImage
        } else if let studentImage = student.imageForCell {
            profileImageView.image = studentImage
        } else {
            profileImageView.image = UIImage(named: "unknown_logo")
        }
        
        studentNameLabel.text = student.name
        updateScheduleTextField()
    }
    
    func updateScheduleTextField() {
        var scheduleStrings = [String]()
        
        if let sortedSchedules = student?.schedule.sorted(by: { orderOfDay($0.weekday) < orderOfDay($1.weekday) }) {
            scheduleStrings = sortedSchedules.map { "\($0.weekday) \($0.time)" }
        }
        
        let formattedSchedule = scheduleStrings.joined(separator: ", ")
        
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
            let additionalRotation = CGFloat(0.5 * (.pi / 180.0)) // 1 degree in radians
            let shakeRotation = CGFloat(0.005)
            
            animation.fromValue = -shakeRotation - additionalRotation
            animation.toValue = shakeRotation + additionalRotation
            animation.duration = 0.1
            animation.repeatCount = .infinity
            animation.autoreverses = true
            
            layer.add(animation, forKey: "shake")
        } else {
            layer.removeAnimation(forKey: "shake")
        }
    }
}