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
        
        
        //        // Initialize Collection view for displaying schedule items
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        scheduleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        scheduleCollectionView.backgroundColor = .white
        scheduleCollectionView.layer.cornerRadius = 10
        scheduleCollectionView.delegate = self
        scheduleCollectionView.dataSource = self
        scheduleCollectionView.register(ScheduleCell.self, forCellWithReuseIdentifier: "ScheduleCell")
        
        // Add schedule collection view
        stackView.addArrangedSubview(scheduleCollectionView)
        scheduleCollectionView.snp.makeConstraints { make in
            make.height.equalTo(150) // Adjust height as needed
        }
        
        // Weekday TextField
        let weekdayTextField = UITextField()
        weekdayTextField.delegate = self // Set the delegate to restrict input
        stackView.addArrangedSubview(weekdayTextField)
        weekdayTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        weekdayTextField.borderStyle = .roundedRect
        weekdayTextField.placeholder = "Enter weekday (e.g., MON, TUE, WED, etc.)"
        
        // Time TextField
        let timeTextField = UITextField()
        stackView.addArrangedSubview(timeTextField)
        timeTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        timeTextField.borderStyle = .roundedRect
        timeTextField.placeholder = "Enter time (e.g., 15, 17 or 15-17)"
        
        // Store references to the text fields
        self.weekdayTextField = weekdayTextField
        self.timeTextField = timeTextField
        
        // Add Schedule button
        let addScheduleButton = UIButton()
        addScheduleButton.setTitle("Add", for: .normal)
        addScheduleButton.setTitleColor(.white, for: .normal)
        addScheduleButton.backgroundColor = .systemBlue
        addScheduleButton.layer.cornerRadius = 8
        addScheduleButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
        
        stackView.addArrangedSubview(addScheduleButton)
        addScheduleButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    @objc private func addSchedule() {
        guard let weekday = weekdayTextField?.text, !weekday.isEmpty,
              let timeInput = timeTextField?.text, !timeInput.isEmpty else {
            displayErrorAlert(message: "Please enter both weekday and time.")
            return
        }
        
        let validWeekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        let uppercaseWeekday = weekday.uppercased()
        
        // Проверка на валидность введенного дня недели
        if !validWeekdays.contains(uppercaseWeekday) {
            displayErrorAlert(message: "Please enter a valid weekday abbreviation without any spaces or signs (e.g., MON, TUE, WED, etc.).")
            return
        }
        
        // Проверка на уже добавленный день недели
        if scheduleItems.contains(where: { $0.weekday == uppercaseWeekday }) {
            displayErrorAlert(message: "You can only add one day of the week.")
            return
        }
        
        var formattedTimes: [String] = []
        
        // Разделение введенного времени по разделителю '-' или ','
        let timeComponents = timeInput.components(separatedBy: CharacterSet(charactersIn: "-,"))
        
        for component in timeComponents {
            guard let formattedTime = formatTime(component.trimmingCharacters(in: .whitespaces)) else {
                displayErrorAlert(message: "Please enter a valid time or time range (e.g., 15, 17 or 15-17).")
                return
            }
            formattedTimes.append(formattedTime)
        }
        
        // Создание нового элемента расписания и добавление его в коллекцию
        let newScheduleItem = Schedule()
        newScheduleItem.weekday = uppercaseWeekday
        newScheduleItem.time = formattedTimes.joined(separator: ", ") // объединяем форматированные времена через запятую
        
        scheduleItems.append(newScheduleItem)
        
        // Сортировка элементов расписания
        scheduleItems.sort { orderOfDay($0.weekday) < orderOfDay($1.weekday) }
        
        scheduleCollectionView.reloadData()
        
        // Очистка текстовых полей после добавления
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

extension StudentCardViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == weekdayTextField {
            // Запретить ввод цифр
            let characterSet = CharacterSet.decimalDigits
            if string.rangeOfCharacter(from: characterSet) != nil {
                return false
            }
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
}
