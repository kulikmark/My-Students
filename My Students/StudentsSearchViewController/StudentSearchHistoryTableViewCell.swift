
//  StudentTableViewCell.swift
//  My Students
//
//  Created by Марк Кулик on 01.07.2024.
//

import UIKit
import SnapKit
import Kingfisher

class StudentSearchHistoryTableViewCell: UITableViewCell {
    
    var student: Student?
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "ViewColor")
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let studentNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    let studentClassLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        contentView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(studentNameLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalTo(80)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(50)
        }
        
        studentNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(profileImageView.snp.right).offset(10)
        }
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
