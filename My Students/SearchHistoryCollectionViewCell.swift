//
//  SearchHistoryCollectionViewCell.swift
//  My Students
//
//  Created by Марк Кулик on 30.06.2024.
//

import UIKit

class SearchHistoryCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with student: Student) {
        if let image = UIImage(contentsOfFile: student.studentImage) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "defaultImage")
        }
        nameLabel.text = student.name
    }
}

