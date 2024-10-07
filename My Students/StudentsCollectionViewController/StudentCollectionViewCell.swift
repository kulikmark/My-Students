//
//  StudentTableViewCell.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import SnapKit
import Kingfisher

protocol StudentCollectionViewCellDelegate: AnyObject {
    func presentStudentCardBottomSheet(for student: Student)
}

class StudentCollectionViewCell: UICollectionViewCell {
    
    var student: Student?
    
    weak var delegate: StudentCollectionViewCellDelegate?
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
//    lazy var studentNameLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.textColor = .black
//        label.adjustsFontSizeToFitWidth = true
//        label.lineBreakMode = .byWordWrapping
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        return label
//    }()
//    
//    lazy var scheduleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 12)
//        label.textColor = .darkGray
//        label.adjustsFontSizeToFitWidth = true
//        label.lineBreakMode = .byWordWrapping
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        return label
//    }()
    
    lazy var studentNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        // Используем цвет для текста из Assets
        label.textColor = UIColor(named: "StudentNameColor")
        
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        
        // Используем цвет для текста из Assets
        label.textColor = UIColor(named: "ScheduleLabelColor")
        
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    
    lazy var studentCellManageButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "ellipsis", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(studentNameLabel)
        contentView.addSubview(scheduleLabel)
        contentView.addSubview(studentCellManageButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(contentView.snp.width).offset(-20)
        }
        
        studentNameLabel.snp.makeConstraints { make in
               make.top.equalTo(profileImageView.snp.bottom).offset(10)
               make.leading.trailing.equalToSuperview().inset(10)
           }
        
        scheduleLabel.snp.makeConstraints { make in
            make.top.equalTo(studentNameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(5)
        }
        
        studentCellManageButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(7)
            make.right.equalToSuperview().offset(-7)
        }
        studentCellManageButton.addTarget(self, action: #selector(studetnCellManageButtonTapped), for: .touchUpInside)
    }
    
    @objc func studetnCellManageButtonTapped() {
        guard let student = student else { return }
        delegate?.presentStudentCardBottomSheet(for: student)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = UIColor(named: "ViewColor")
        contentView.layer.cornerRadius = 10
        
        // Установка круглой формы изображения
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    func configure(with student: Student) {
        self.student = student
        studentNameLabel.text = student.name
        
        if let imageUrlString = student.studentImageURL, let imageUrl = URL(string: imageUrlString) {
            // Используем Kingfisher для загрузки и кэширования изображения
            profileImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "defaultImage")) { result in
                switch result {
                case .success(let value):
                    self.profileImageView.image = value.image
                    // Убедимся, что layout завершен перед установкой cornerRadius
                    self.profileImageView.layoutIfNeeded()
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
                    self.profileImageView.clipsToBounds = true
                case .failure(let error):
                    print("Ошибка загрузки изображения: \(error.localizedDescription)")
                    self.profileImageView.image = UIImage(named: "defaultImage")
                    self.profileImageView.layoutIfNeeded()
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
                    self.profileImageView.clipsToBounds = true
                }
            }
        } else {
            profileImageView.image = UIImage(named: "defaultImage")
            profileImageView.layoutIfNeeded()
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.clipsToBounds = true
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
}
