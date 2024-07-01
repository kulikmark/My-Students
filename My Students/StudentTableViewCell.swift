//
//  StudentTableViewCell.swift
//  My Students
//
//  Created by Марк Кулик on 01.07.2024.
//

import UIKit
import SnapKit

class StudentTableViewCell: UITableViewCell {
    
    var student: Student?
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var studentNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(studentNameLabel)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalTo(containerView).offset(10)
            make.width.height.equalTo(100)
            make.bottom.lessThanOrEqualTo(containerView).offset(-10).priority(.medium)
        }
        
        studentNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(23)
            make.trailing.equalTo(containerView).offset(-10)
        }
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
