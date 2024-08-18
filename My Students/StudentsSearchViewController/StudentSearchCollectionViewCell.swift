//
//  StudentSearchHistoryTableViewCell.swift
//  My Students
//
//  Created by Марк Кулик on 30.06.2024.
//

import UIKit
import Kingfisher

class StudentSearchCollectionViewCell: UICollectionViewCell {
    let profileImageView = UIImageView()
    let studentNameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 35
        profileImageView.layer.masksToBounds = true
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        studentNameLabel.textAlignment = .center
        studentNameLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(studentNameLabel)
        studentNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with student: Student) {
           studentNameLabel.text = student.name

           if let imageUrlString = student.studentImageURL, let imageUrl = URL(string: imageUrlString) {
               profileImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "defaultImage"))
           } else {
               profileImageView.image = UIImage(named: "defaultImage")
           }
       }
}
