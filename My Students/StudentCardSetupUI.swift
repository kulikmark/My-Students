//
//  StudentCardSetupUI.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import RealmSwift

// MARK: - UI Setup

extension StudentCardViewController {
    
    func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        let imageContainerView = UIView()
        mainStackView.addArrangedSubview(imageContainerView)
        imageContainerView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
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
        profileImageView.layer.shadowColor = UIColor.black.cgColor
        profileImageView.layer.shadowOpacity = 0.5
        profileImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileImageView.layer.shadowRadius = 5
        
        if let selectedImage = selectedImage {
            profileImageView.image = selectedImage
        } else if let studentImageFilePath = student?.studentImage, let studentImage = UIImage(contentsOfFile: studentImageFilePath) {
            profileImageView.image = studentImage
        } else {
            profileImageView.image = UIImage(named: "defaultImage")
        }
        
        let buttonContainerView = UIView()
        mainStackView.addArrangedSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
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
        addProfileImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        addProfileImageButton.setTitleColor(.white, for: .normal)
        addProfileImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        mainStackView.addArrangedSubview(studentTypeSegmentedControl)
        mainStackView.setCustomSpacing(40, after: studentTypeSegmentedControl)
        if let student = student {
            let type = StudentType(rawValue: student.type) ?? .schoolchild
            studentTypeSegmentedControl.selectedSegmentIndex = type == .schoolchild ? 0 : 1
        }
        
        let labelsTextFieldsStackView = UIStackView()
        labelsTextFieldsStackView.axis = .vertical
        labelsTextFieldsStackView.spacing = 10
        labelsTextFieldsStackView.alignment = .fill
        labelsTextFieldsStackView.distribution = .fill
        mainStackView.addArrangedSubview(labelsTextFieldsStackView)
        
        labelsTextFieldsStackView.addArrangedSubview(studentNameLabel)
        studentNameLabel.text = "Student's Name"
        studentNameLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        studentNameLabel.textColor = .darkGray
        studentNameLabel.text = studentNameLabel.text?.uppercased()
        
        labelsTextFieldsStackView.addArrangedSubview(studentNameTextField)
        studentNameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        studentNameTextField.borderStyle = .roundedRect
        studentNameTextField.placeholder = "Enter student's name"
        studentNameTextField.text = student?.name ?? ""
        studentNameTextField.clearButtonMode = .whileEditing
        
        labelsTextFieldsStackView.addArrangedSubview(parentNameLabel)
        parentNameLabel.text = "Parent's Name"
        parentNameLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        parentNameLabel.textColor = .darkGray
        parentNameLabel.text = parentNameLabel.text?.uppercased()
        
        labelsTextFieldsStackView.addArrangedSubview(parentNameTextField)
        parentNameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        parentNameTextField.borderStyle = .roundedRect
        parentNameTextField.placeholder = "Enter parent's name"
        parentNameTextField.text = student?.parentName ?? ""
        parentNameTextField.clearButtonMode = .whileEditing
        
        labelsTextFieldsStackView.addArrangedSubview(phoneLabel)
        phoneLabel.text = "Phone Number"
        phoneLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        phoneLabel.textColor = .darkGray
        phoneLabel.text = phoneLabel.text?.uppercased()
        
        labelsTextFieldsStackView.addArrangedSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.placeholder = "Enter phone number"
        phoneTextField.keyboardType = .phonePad
        phoneTextField.text = student?.phoneNumber ?? ""
        phoneTextField.clearButtonMode = .whileEditing
        
        labelsTextFieldsStackView.addArrangedSubview(lessonPriceLabel)
        lessonPriceLabel.text = "Lesson Price"
        lessonPriceLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lessonPriceLabel.textColor = .darkGray
        lessonPriceLabel.text = lessonPriceLabel.text?.uppercased()
        
        labelsTextFieldsStackView.addArrangedSubview(lessonPriceTextField)
        lessonPriceTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        lessonPriceTextField.borderStyle = .roundedRect
        lessonPriceTextField.placeholder = "Enter Price"
        lessonPriceTextField.keyboardType = .decimalPad
        lessonPriceTextField.text = student != nil ? "\(student!.lessonPrice?.price ?? 0)" : ""
        lessonPriceTextField.clearButtonMode = .whileEditing
        
        labelsTextFieldsStackView.addArrangedSubview(currencyLabel)
        currencyLabel.text = "Currency"
        currencyLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        currencyLabel.textColor = .darkGray
        currencyLabel.text = currencyLabel.text?.uppercased()
        
        labelsTextFieldsStackView.addArrangedSubview(currencyTextField)
        currencyTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        currencyTextField.borderStyle = .roundedRect
        currencyTextField.placeholder = "Enter Currency name"
        currencyTextField.text = student != nil ? "\(student!.lessonPrice?.currency ?? "")" : ""
        currencyTextField.clearButtonMode = .whileEditing
        
        labelsTextFieldsStackView.addArrangedSubview(scheduleLabel)
        scheduleLabel.text = "Schedule"
        scheduleLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        scheduleLabel.textColor = .darkGray
        scheduleLabel.text = scheduleLabel.text?.uppercased()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        scheduleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        scheduleCollectionView.backgroundColor = .white
        scheduleCollectionView.layer.cornerRadius = 10
        scheduleCollectionView.layer.shadowColor = UIColor.black.cgColor
        scheduleCollectionView.layer.shadowOpacity = 0.2
        scheduleCollectionView.layer.shadowOffset = CGSize(width: 0, height: 1)
        scheduleCollectionView.layer.shadowRadius = 3
        scheduleCollectionView.delegate = self
        scheduleCollectionView.dataSource = self
        scheduleCollectionView.register(ScheduleCell.self, forCellWithReuseIdentifier: "ScheduleCell")
        
        mainStackView.addArrangedSubview(scheduleCollectionView)
        scheduleCollectionView.snp.makeConstraints { make in
            make.height.equalTo(150)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 10.0
        paragraphStyle.maximumLineHeight = 18.0
        
        let weekdayTextField = UITextField()
        mainStackView.addArrangedSubview(weekdayTextField)
        weekdayTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        weekdayTextField.borderStyle = .roundedRect
        let weekdayAttributedPlaceholder = NSAttributedString(string: "Enter weekday (e.g., MON, TUE, WED, etc.)", attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle])
        weekdayTextField.attributedPlaceholder = weekdayAttributedPlaceholder
        weekdayTextField.placeholder = "Enter weekday (e.g., MON, TUE, WED, etc.)"
        weekdayTextField.clearButtonMode = .whileEditing
        
        let timeTextField = UITextField()
        mainStackView.addArrangedSubview(timeTextField)
        timeTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        timeTextField.borderStyle = .roundedRect
        let timeAttributedPlaceholder = NSAttributedString(string: "Enter time for each weekday separated by ;", attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle])
        timeTextField.attributedPlaceholder = timeAttributedPlaceholder
        timeTextField.placeholder = "Enter time for each weekday separated by ;"
        timeTextField.keyboardType = .numbersAndPunctuation
        timeTextField.clearButtonMode = .whileEditing
        
        self.weekdayTextField = weekdayTextField
        self.timeTextField = timeTextField
        
        let addScheduleButton = UIButton()
        addScheduleButton.setTitle("Add", for: .normal)
        addScheduleButton.setTitleColor(.white, for: .normal)
        addScheduleButton.backgroundColor = .systemBlue
        addScheduleButton.layer.cornerRadius = 8
        addScheduleButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
        
        mainStackView.addArrangedSubview(addScheduleButton)
        addScheduleButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        studentNameTextField.delegate = self
        parentNameTextField.delegate = self
        phoneTextField.delegate = self
        lessonPriceTextField.delegate = self
        currencyTextField.delegate = self
        weekdayTextField.delegate = self
        timeTextField.delegate = self
    }

    
    @objc private func addSchedule() {
        guard let timeInput = timeTextField?.text, !timeInput.isEmpty else {
            displayErrorAlert(message: "Please enter time.")
            return
        }
        
        var formattedTimes: [String] = []
        
        // Split the time input based on semicolon for days and comma for times
        let timeGroups = timeInput.components(separatedBy: ";")
        
        let weekdays = weekdayTextField?.text?.components(separatedBy: ",") ?? []
        for (index, weekday) in weekdays.enumerated() {
            let uppercaseWeekday = weekday.trimmingCharacters(in: .whitespaces).uppercased()
            let validWeekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            
            // Check for valid weekday input
            if !validWeekdays.contains(uppercaseWeekday) {
                displayErrorAlert(message: "Please enter valid weekday abbreviations separated by commas (e.g., MON, TUE, WED).")
                return
            }
            
            // Ensure corresponding time group exists
            guard index < timeGroups.count else {
                displayErrorAlert(message: "Please enter time for each specified weekday (e.g., 15; 15, 17; 15-17).")
                return
            }
            
            var formattedTimeItems: [String] = []
            
            // Split the time group based on comma, and handle each part
            let timeRanges = timeGroups[index].components(separatedBy: ",")
            for timeRange in timeRanges {
                if timeRange.contains("-") {
                    // Handle time range (e.g., 15-17)
                    let timeComponents = timeRange.split(separator: "-")
                    if timeComponents.count == 2,
                       let formattedStartTime = formatTime(String(timeComponents[0]).trimmingCharacters(in: .whitespaces)),
                       let formattedEndTime = formatTime(String(timeComponents[1]).trimmingCharacters(in: .whitespaces)) {
                        formattedTimeItems.append("\(formattedStartTime)-\(formattedEndTime)")
                    } else {
                        displayErrorAlert(message: "Please enter a valid time range (e.g., 15:00-17:00).")
                        return
                    }
                } else {
                    // Handle single time (e.g., 15)
                    if let formattedTime = formatTime(timeRange.trimmingCharacters(in: .whitespaces)) {
                        formattedTimeItems.append(formattedTime)
                    } else {
                        displayErrorAlert(message: "Please enter a valid time separated by ; (e.g., 15; 15, 17; 15-17).")
                        return
                    }
                }
            }
            
            formattedTimes.append("\(uppercaseWeekday) \(formattedTimeItems.joined(separator: ", "))")
        }
        
        // Create new schedule items and add them to the collection
        for formattedTime in formattedTimes {
            let newScheduleItem = Schedule()
            let components = formattedTime.split(separator: " ")
            newScheduleItem.weekday = String(components[0])
            newScheduleItem.time = String(components[1...].joined(separator: " "))
            
            scheduleItems.append(newScheduleItem)
        }
        
        // Sort schedule items
        scheduleItems.sort { orderOfDay($0.weekday) < orderOfDay($1.weekday) }
        
        scheduleCollectionView.reloadData()
        
        // Clear text fields after adding
        weekdayTextField?.text = ""
        timeTextField?.text = ""
    }
    
    
    // Метод для форматирования времени в "HH:mm"
    private func formatTime(_ time: String) -> String? {
        let timeComponents = time.split(separator: ":")
        if timeComponents.count == 1 {
            // Если введены только часы (например, "15"), добавить ":00"
            if let hour = Int(timeComponents[0]), hour >= 0 && hour < 24 {
                return String(format: "%02d:00", hour)
            }
        } else if timeComponents.count == 2 {
            // Если введены часы и минуты (например, "15:30")
            if let hour = Int(timeComponents[0]), let minute = Int(timeComponents[1]),
               hour >= 0 && hour < 24 && minute >= 0 && minute < 60 {
                return String(format: "%02d:%02d", hour, minute)
            }
        }
        // Если введено некорректное время, возвращать nil
        return nil
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
    
    // Method to remove schedule item
    func removeScheduleItem(at index: Int) {
        scheduleItems.remove(at: index)
        scheduleCollectionView.reloadData()
    }
}

extension StudentCardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scheduleItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let scheduleItem = scheduleItems[indexPath.item]
        cell.configure(with: scheduleItem)
        return cell
    }
    
    // This method sets the size for the items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the width to make sure 3 columns fit in the collection view with spacing
        let totalSpacing: CGFloat = 2 * 8 + (3 - 1) * 8 // (left + right) spacing + (numberOfItemsInRow - 1) * interItemSpacing
        let width = (collectionView.bounds.width - totalSpacing) / 3
        return CGSize(width: width, height: 40)
    }
    
    // Minimum spacing between items in the same row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    // Minimum spacing between rows
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    // Insets for the section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
                self.removeScheduleItem(at: indexPath.item)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
        return configuration
    }
}

extension StudentCardViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case lessonPriceTextField:
            let currentText = textField.text ?? ""
            if currentText.contains(",") && string.contains(",") {
                return false
            }
            let allowedCharacters = CharacterSet(charactersIn: "0123456789,")
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }
        case studentNameTextField, parentNameTextField, currencyTextField:
            let allowedCharacters = CharacterSet.letters
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }
        case phoneTextField:
            let allowedCharacters = CharacterSet(charactersIn: "+0123456789")
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }
        case weekdayTextField:
            let characterSet = CharacterSet.decimalDigits
            if string.rangeOfCharacter(from: characterSet) != nil {
                return false
            }
        case timeTextField:
            let allowedCharacters = CharacterSet(charactersIn: "0123456789,-;")
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }
        default:
            break
        }
        
        return true
    }
}

extension StudentCardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        if let selectedImage = info[.editedImage] as? UIImage {
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
}
