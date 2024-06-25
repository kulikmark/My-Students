//
//  StudentCardSetupUI.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit

// MARK: - UI Setup

extension StudentCardViewController {
    
    func setupUI() {
        
        view.backgroundColor = UIColor.systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Add Content View inside Scroll View
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()  // Ensure the content view width matches the scroll view width
        }
        
        // Add a stack view to hold all the elements
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        // Image Button Container
        let imageButtonContainer = UIView()
        stackView.addArrangedSubview(imageButtonContainer)
        imageButtonContainer.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        // Add Image Button
        imageButtonContainer.addSubview(imageButton)
        imageButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
        imageButton.setTitle("Adding photo", for: .normal)
        imageButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
//        imageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        imageButton.layer.cornerRadius = 100
        imageButton.layer.borderWidth = 1
        imageButton.layer.borderColor = UIColor.systemBlue.cgColor
        imageButton.contentMode = .scaleToFill
        imageButton.clipsToBounds = true
        
        switch (selectedImage, student?.imageForCell) {
        case (let selectedImageName?, _):
            imageButton.setImage(selectedImageName.withRenderingMode(.alwaysOriginal), for: .normal)
        case (_, let studentImageName?):
            imageButton.setImage(studentImageName.withRenderingMode(.alwaysOriginal), for: .normal)
        default:
            break
        }
        
        // Student Type Segmented Control
            stackView.addArrangedSubview(studentTypeSegmentedControl)
            if let student = student {
                studentTypeSegmentedControl.selectedSegmentIndex = student.type == .schoolchild ? 0 : 1
            }
        
        // Student Name Label
        stackView.addArrangedSubview(studentNameLabel)
        studentNameLabel.text = "Student's Name"
        studentNameLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Student Name TextField
        stackView.addArrangedSubview(studentNameTextField)
        studentNameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        studentNameTextField.borderStyle = .roundedRect
        studentNameTextField.placeholder = "Enter student's name"
        studentNameTextField.text = student?.name ?? ""
        
        // Parent Name Label
        stackView.addArrangedSubview(parentNameLabel)
        parentNameLabel.text = "Parent's Name"
        parentNameLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Parent Name TextField
        stackView.addArrangedSubview(parentNameTextField)
        parentNameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        parentNameTextField.borderStyle = .roundedRect
        parentNameTextField.placeholder = "Enter parent's name"
        parentNameTextField.text = student?.parentName ?? ""
        
        // Phone Label
        stackView.addArrangedSubview(phoneLabel)
        phoneLabel.text = "Phone Number"
        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Phone TextField
        stackView.addArrangedSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.placeholder = "Enter phone number"
        phoneTextField.keyboardType = .phonePad
        phoneTextField.text = student?.phoneNumber ?? ""
        
        // Lesson Price Label
        stackView.addArrangedSubview(lessonPriceLabel)
        lessonPriceLabel.text = "Lesson Price"
        lessonPriceLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Lesson Price TextField
        stackView.addArrangedSubview(lessonPriceTextField)
        lessonPriceTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        lessonPriceTextField.borderStyle = .roundedRect
        lessonPriceTextField.placeholder = "Price"
        lessonPriceTextField.keyboardType = .decimalPad
        lessonPriceTextField.text = student != nil ? "\(student!.lessonPrice.price)" : ""
        
        // Currency Label
        stackView.addArrangedSubview(currencyLabel)
        currencyLabel.text = "Currency"
        currencyLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Currenct TextField
        stackView.addArrangedSubview(currencyTextField)
        currencyTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        currencyTextField.borderStyle = .roundedRect
        currencyTextField.placeholder = "Currency"
        currencyTextField.text = student != nil ? "\(student!.lessonPrice.currency)" : ""
        
        // Schedule Label
        stackView.addArrangedSubview(scheduleLabel)
        scheduleLabel.text = "Schedule"
        scheduleLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Schedule TextField
        stackView.addArrangedSubview(scheduleTextField)
        scheduleTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        scheduleTextField.borderStyle = .roundedRect
        scheduleTextField.placeholder = "Select the days of the week and time"
        scheduleTextField.isUserInteractionEnabled = true
        scheduleTextField.adjustsFontSizeToFitWidth = true
        scheduleTextField.minimumFontSize = 9.5
        
        // Add tap gesture recognizer to schedule text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectSchedule))
        scheduleTextField.addGestureRecognizer(tapGesture)
        
//        studentNameTextField.delegate = self
//        parentNameTextField.delegate = self
//        phoneTextField.delegate = self
//        lessonPriceTextField.delegate = self
//        currencyTextField.delegate = self
    }
    
}

