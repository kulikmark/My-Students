
//  StudentTableViewCell.swift
//  My Students
//
//  Created by Марк Кулик on 01.07.2024.
//


import UIKit
import SnapKit

class StudentSearchHistoryTableViewCell: UITableViewCell {
    
    var student: Student?
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    let studentImageView: UIImageView = {
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
        containerView.addSubview(studentImageView)
        containerView.addSubview(studentNameLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalTo(80)
        }
        
        studentImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(50)
        }
        
        studentNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(studentImageView.snp.right).offset(10)
        }
    }
    
    func configure(with student: Student) {
//        self.student = student
//        studentNameLabel.text = student.name
//        
//        if let imageData = student.studentImageData {
//            if let image = UIImage(data: imageData) {
//                studentImageView.image = image
//            } else {
//                studentImageView.image = UIImage(named: "defaultImage")
//            }
//        }
    }
}
