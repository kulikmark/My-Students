//
//  ScheduleBottomSheetViewController.swift
//  My Students
//
//  Created by Марк Кулик on 16.07.2024.
//

import UIKit
import SnapKit

class ScheduleBottomSheetViewController: UIViewController {

    var studentCardVC: StudentCardViewController?
    var currentScheduleItems: [Schedule] = []

    let daysOfWeekOriginal: [String] = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    var dayTimeTextFields: [String: UITextField] = [:] // Dictionary to store time text fields by day of the week

    var onSave: (([Schedule]) -> Void)?
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return button
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true

        setupUI()
        setupKeyboardObservers()
        setupTapGestureRecognizer()
    }

    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        view.addSubview(stackView)

        let daysStackView = UIStackView()
        daysStackView.axis = .vertical
        daysStackView.spacing = 10
        daysStackView.alignment = .fill
        daysStackView.distribution = .fill
        stackView.addArrangedSubview(daysStackView)

        let textFieldStackView = UIStackView()
        textFieldStackView.axis = .vertical
        textFieldStackView.spacing = 10
        textFieldStackView.alignment = .fill
        textFieldStackView.distribution = .fill
        stackView.addArrangedSubview(textFieldStackView)

        for day in daysOfWeekOriginal {
            if !currentScheduleItems.contains(where: { $0.weekday == day }) {
                let dayLabel = UILabel()
                dayLabel.text = day
                dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                dayLabel.setContentHuggingPriority(.required, for: .horizontal)
                daysStackView.addArrangedSubview(dayLabel)

                let timeTextField = UITextField()
                timeTextField.borderStyle = .roundedRect
                timeTextField.placeholder = "Enter time"
                timeTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
                timeTextField.keyboardType = .numbersAndPunctuation
                dayTimeTextFields[day] = timeTextField // Save the time text field in the dictionary
                textFieldStackView.addArrangedSubview(timeTextField)

                dayLabel.snp.makeConstraints { make in
                    make.width.greaterThanOrEqualTo(40)
                    make.height.greaterThanOrEqualTo(40)
                }

                timeTextField.snp.makeConstraints { make in
                    make.width.greaterThanOrEqualTo(200)
                    make.height.greaterThanOrEqualTo(40)
                }
            }
        }

        

        view.addSubview(saveButton)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(saveButton.snp.top).offset(-20)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(50)
        }
        saveButton.addTarget(self, action: #selector(saveSchedule), for: .touchUpInside)

        view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(stackView.snp.width).inset(20)
        }

        updateInfoLabel()
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            saveButton.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-keyboardHeight - 20)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        saveButton.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    
    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func updateInfoLabel() {
        if currentScheduleItems.count == daysOfWeekOriginal.count {
            infoLabel.text = "All weekdays are added to the schedule. Remove a day to edit."
            infoLabel.isHidden = false
        } else {
            infoLabel.isHidden = true
        }
    }

    @objc private func saveSchedule() {
        var updatedScheduleItems: [Schedule] = []

        for day in daysOfWeekOriginal {
            if let timeTextField = dayTimeTextFields[day], let timeText = timeTextField.text, !timeText.isEmpty {
                if var existingSchedule = currentScheduleItems.first(where: { $0.weekday == day }) {
                    if let formattedTimes = formatTime(timeText) {
                        existingSchedule.time = formattedTimes.joined(separator: ", ")
                        updatedScheduleItems.append(existingSchedule)
                    } else {
                        showAlert("Invalid Time", "Please enter a valid time for \(day).")
                        return
                    }
                } else {
                    if let formattedTimes = formatTime(timeText) {
                        let schedule = Schedule(weekday: day, time: formattedTimes.joined(separator: ", "))
                        updatedScheduleItems.append(schedule)
                    } else {
                        showAlert("Invalid Time", "Please enter a valid time for \(day).")
                        return
                    }
                }
            }
        }

        // Update currentScheduleItems with sorted items
        currentScheduleItems = updatedScheduleItems

        // Trigger onSave callback with the updated schedule items
        onSave?(currentScheduleItems)
        dismiss(animated: true, completion: nil)

        // Update the info label
        updateInfoLabel()
    }

    private func formatTime(_ time: String) -> [String]? {
        let timeParts = time.split(separator: ",")
        var formattedTimes: [String] = []

        for part in timeParts {
            let trimmedPart = part.trimmingCharacters(in: .whitespaces)
            if let rangeSeparatorIndex = trimmedPart.firstIndex(of: "-") {
                let startHour = String(trimmedPart[..<rangeSeparatorIndex])
                let endHour = String(trimmedPart[trimmedPart.index(after: rangeSeparatorIndex)...])
                if let formattedStartHour = formatSingleTime(startHour), let formattedEndHour = formatSingleTime(endHour) {
                    formattedTimes.append("\(formattedStartHour)-\(formattedEndHour)")
                } else {
                    return nil
                }
            } else {
                if let formattedTime = formatSingleTime(trimmedPart) {
                    formattedTimes.append(formattedTime)
                } else {
                    return nil
                }
            }
        }

        return formattedTimes
    }

    private func formatSingleTime(_ time: String) -> String? {
        let timeComponents = time.split(separator: ":")
        if timeComponents.count == 1 {
            if let hour = Int(timeComponents[0]), hour >= 0 && hour < 24 {
                return String(format: "%02d:00", hour)
            }
        } else if timeComponents.count == 2 {
            if let hour = Int(timeComponents[0]), let minute = Int(timeComponents[1]),
               hour >= 0 && hour < 24 && minute >= 0 && minute < 60 {
                return String(format: "%02d:%02d", hour, minute)
            }
        }
        return nil
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
