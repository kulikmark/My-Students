//
//  StudentCardSetupUI.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit

// MARK: - UI Setup

extension StudentCardViewController {
    
    @objc private func selectImage() {
        setImagePicker(source: .photoLibrary)
    }
    
    func setImagePicker(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                self.selectedImage = selectedImage
                profileImageView.image = selectedImage
            }
            dismiss(animated: true, completion: nil)
        }
    
    private func saveImageToDocumentsDirectory(image: UIImage) -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return "" }
        
        let filename = UUID().uuidString + ".jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Unable to save image to documents directory: \(error)")
            return ""
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
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
            make.width.equalToSuperview()
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
        
        // Image View Container
        let imageContainerView = UIView()
        stackView.addArrangedSubview(imageContainerView)
        imageContainerView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        // Add Profile Image View
        imageContainerView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(imageContainerView.snp.top)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        profileImageView.image = UIImage(named: "defaultImage")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 100
        
        // Set Initial Image
        if let selectedImage = selectedImage {
            profileImageView.image = selectedImage
        } else if let studentImageFilePath = student?.studentImage, let studentImage = UIImage(contentsOfFile: studentImageFilePath) {
            profileImageView.image = studentImage
        } else {
            profileImageView.image = UIImage(named: "defaultImage")
        }
        
        // Add Image Button View Container
        let buttonContainerView = UIView()
        stackView.addArrangedSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        
        // Add Image Button
        let addProfileImageButton = UIButton()
        buttonContainerView.addSubview(addProfileImageButton)
        addProfileImageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        addProfileImageButton.backgroundColor = .systemBlue
        addProfileImageButton.layer.cornerRadius = 10
        addProfileImageButton.setTitle("Add photo", for: .normal)
        addProfileImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        addProfileImageButton.setTitleColor(.white, for: .normal)
        addProfileImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        stackView.addArrangedSubview(studentTypeSegmentedControl)
        if let student = student {
            let type = StudentType(rawValue: student.type) ?? .schoolchild // Assuming .schoolchild as default
            studentTypeSegmentedControl.selectedSegmentIndex = type == .schoolchild ? 0 : 1
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
        lessonPriceTextField.text = student != nil ? "\(student!.lessonPrice?.price ?? 0)" : ""
        
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
        currencyTextField.text = student != nil ? "\(student!.lessonPrice?.currency ?? "")" : ""
        
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
    }

}
