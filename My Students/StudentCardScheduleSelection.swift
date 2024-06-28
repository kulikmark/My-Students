//
//  StudentCardScheduleSelection.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import RealmSwift

// MARK: - Schedule Management

extension StudentCardViewController {
    
    // MARK: - Actions
    
//    @objc func selectSchedule() {
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        
//        let addScheduleAction = UIAlertAction(title: "Add a schedule", style: .default) { [weak self] _ in
//            self?.showWeekdaysPicker()
//        }
//        actionSheet.addAction(addScheduleAction)
//        
//        switch editMode {
//        case .add:
//           if !selectedSchedules.isEmpty {
//                let deleteAction = UIAlertAction(title: "Delete the schedule", style: .destructive) { [weak self] _ in
//                    self?.showDeleteScheduleAlert()
//                }
//                actionSheet.addAction(deleteAction)
//            }
//        
//        case .edit:
//            if !(student?.schedule.isEmpty ?? true) || !selectedSchedules.isEmpty {
//                let deleteAction = UIAlertAction(title: "Delete the schedule", style: .destructive) { [weak self] _ in
//                    self?.showDeleteScheduleAlert()
//                }
//                actionSheet.addAction(deleteAction)
//            }
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        actionSheet.addAction(cancelAction)
//        
//        // Configure popover presentation for iPad
//           if let popoverController = actionSheet.popoverPresentationController {
//               popoverController.sourceView = self.view
//               popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//               popoverController.permittedArrowDirections = []
//           }
//        
//        present(actionSheet, animated: true, completion: nil)
//    }
//
//    func showWeekdaysPicker() {
//        let weekdaysPickerController = UIAlertController(title: "Choose a day of the week", message: nil, preferredStyle: .actionSheet)
//        
//        let weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
//        
//        for weekday in weekdays {
//            let action = UIAlertAction(title: weekday, style: .default) { [weak self] _ in
//                self?.showTimesPicker(for: weekday)
//            }
//            weekdaysPickerController.addAction(action)
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        weekdaysPickerController.addAction(cancelAction)
//        
//        // Configure popover presentation for iPad
//          if let popoverController = weekdaysPickerController.popoverPresentationController {
//              popoverController.sourceView = self.view
//              popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//              popoverController.permittedArrowDirections = []
//          }
//        
//        present(weekdaysPickerController, animated: true, completion: nil)
//    }
//    
//    func showTimesPicker(for weekday: String) {
//        // Создаем экземпляр UIDatePicker с типом .time
//        let timePicker = UIDatePicker()
//        timePicker.datePickerMode = .time
//        timePicker.preferredDatePickerStyle = .wheels
//        
//        // Установим начальное время, например, 12:00
//        let calendar = Calendar.current
//        var components = DateComponents()
//        components.hour = 12
//        components.minute = 0
//        if let initialDate = calendar.date(from: components) {
//            timePicker.setDate(initialDate, animated: false)
//        }
//        
//        // Создаем UIAlertController
//        let timesPickerController = UIAlertController(title: "Choose a time for \(weekday)", message: "", preferredStyle: .actionSheet)
//        
//        // Добавляем UIDatePicker в UIAlertController
//        timesPickerController.view.addSubview(timePicker)
//        
//        // Создаем действия для выбора времени и отмены
//        let selectAction = UIAlertAction(title: "Choose", style: .default) { [weak self] _ in
//            guard let self = self else { return }
//            let selectedTime = self.formatTime(timePicker.date)
//            let newSchedule = (weekday: weekday, time: selectedTime)
//            self.selectedSchedules.append(newSchedule)
//            self.updateScheduleTextField()
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        // Добавляем действия в UIAlertController
//        timesPickerController.addAction(selectAction)
//        timesPickerController.addAction(cancelAction)
//        
//        // Configure popover presentation for iPad
//          if let popoverController = timesPickerController.popoverPresentationController {
//              popoverController.sourceView = self.view
//              popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//              popoverController.permittedArrowDirections = []
//          }
//        
//        // Показываем UIAlertController
//        present(timesPickerController, animated: true, completion: nil)
//        
//        timesPickerController.view.snp.makeConstraints { make in
//            make.leading.equalTo(timesPickerController.view.snp.leading)
//            make.trailing.equalTo(timesPickerController.view.snp.trailing)
//            make.height.equalTo(300)
//        }
//        
//        timePicker.snp.makeConstraints { make in
//            make.height.equalTo(160)
//            make.top.equalTo(timesPickerController.view.snp.top).offset(30)
//            make.leading.equalTo(timesPickerController.view.snp.leading)
//            make.trailing.equalTo(timesPickerController.view.snp.trailing)
//        }
//    }
//    
//    // MARK: - Helper Methods
//    
//    func updateScheduleTextField() {
//        var scheduleStrings = [String]()
//        
//        switch editMode {
//        case .add:
//            // Отсортируйте выбранные расписания по дням недели перед отображением
//            let sortedSchedules = selectedSchedules.sorted { orderOfDay($0.weekday) < orderOfDay($1.weekday) }
//            scheduleStrings = sortedSchedules.map { "\($0.weekday) \($0.time)" }
//        case .edit:
//            // Преобразуйте расписание ученика к формату [(weekday: String, time: String)]
//            let studentSchedules = student?.schedule.map { ($0.weekday, $0.time) } ?? []
//            
//            // Объедините выбранные пользователем расписания и расписание ученика
//            let allSchedules = studentSchedules + selectedSchedules
//            
//            // Отсортируйте все расписания по дням недели перед отображением
//            scheduleStrings = allSchedules.sorted { orderOfDay($0.0) < orderOfDay($1.0) }.map { "\($0.0) \($0.1)" }
//        }
//        
//        let scheduleText = scheduleStrings.joined(separator: ", ")
//        scheduleTextField.text = scheduleText
//    }
//
//    func orderOfDay(_ weekday: String) -> Int {
//        switch weekday {
//        case "MON": return 0
//        case "TUE": return 1
//        case "WED": return 2
//        case "THU": return 3
//        case "FRI": return 4
//        case "SAT": return 5
//        case "SUN": return 6
//        default: return 7 // Для непредвиденных случаев
//        }
//    }
//
//
//    func showDeleteScheduleAlert() {
//        let alert = UIAlertController(title: "Select the day of the week and the time to delete", message: nil, preferredStyle: .actionSheet)
//        
//        switch editMode {
//        case .add:
//            for schedule in selectedSchedules {
//                let action = UIAlertAction(title: "\(schedule.weekday) \(schedule.time)", style: .default) { [weak self] _ in
//                    self?.removeSchedule(schedule.weekday, from: .add)
//                }
//                alert.addAction(action)
//            }
//        case .edit:
//            // Преобразуем расписание ученика к формату [(weekday: String, time: String)]
//            let studentSchedules = student?.schedule.map { ($0.weekday, $0.time) } ?? []
//            
//            // Объединяем выбранные пользователем расписания и расписание ученика
//            let allSchedules = studentSchedules + selectedSchedules
//            
//            for schedule in allSchedules {
//                let action = UIAlertAction(title: "\(schedule.0) \(schedule.1)", style: .default) { [weak self] _ in
//                    self?.removeSchedule(schedule.0, from: .edit)
//                }
//                alert.addAction(action)
//            }
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true, completion: nil)
//    }
//
//
//    func removeSchedule(_ schedule: String, from mode: EditMode) {
//        switch mode {
//        case .add:
//            if let index = selectedSchedules.firstIndex(where: { $0.weekday == schedule }) {
//                selectedSchedules.remove(at: index)
//                updateScheduleTextField()
//            }
//        case .edit:
//            if let index = selectedSchedules.firstIndex(where: { $0.weekday == schedule }) {
//                selectedSchedules.remove(at: index)
//                updateScheduleTextField()
//            }
//            if let index = student?.schedule.firstIndex(where: { $0.weekday == schedule }) {
//                student?.schedule.remove(at: index)
//                updateScheduleTextField()
//            }
//        }
//    }
//
//    // Метод для форматирования выбранного времени
//    func formatTime(_ date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm"
//        return dateFormatter.string(from: date)
//    }
}
