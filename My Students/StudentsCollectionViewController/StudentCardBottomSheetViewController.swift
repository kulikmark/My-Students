//
//  StudentCardBottomSheetViewController.swift
//  My Students
//
//  Created by Марк Кулик on 14.07.2024.
//

import UIKit
import SnapKit

protocol StudentBottomSheetDelegate: AnyObject {
    func didTapEditButton(for student: Student)
    func didTapDeleteButton(for student: Student)
}

class StudentCardBottomSheetViewController: UIViewController {
    
    weak var delegate: StudentBottomSheetDelegate?
    let student: Student
    
    let editButton: UIButton = {
        
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 19)
        let editButtonImage = UIImage(systemName: "pencil", withConfiguration: config)
        button.setImage(editButtonImage, for: .normal)
        button.tintColor = .darkGray
        button.setTitle("  Edit student card", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18)
        let deleteButtonImage = UIImage(systemName: "trash.fill", withConfiguration: config)
        button.setImage(deleteButtonImage, for: .normal)
        button.tintColor = .darkGray
        button.setTitle("  Delete the student card", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    init(student: Student) {
        self.student = student
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ViewColor")
        setupUI()
    }
    
    private func setupUI() {
        let nameLabel = UILabel()
        nameLabel.textColor = .darkGray
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.text = "Student: \(student.name)"
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(20)
        }
        
        view.addSubview(editButton)
        view.addSubview(deleteButton)
        
        editButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(editButton.snp.bottom).offset(20)
        }
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func editButtonTapped() {
            delegate?.didTapEditButton(for: student)
        }
        
        @objc func deleteButtonTapped() {
            delegate?.didTapDeleteButton(for: student)
        }
}

