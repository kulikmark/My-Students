//
//  MonthLessonsViewController.swift
//  Accounting
//
//  Created by Марк Кулик on 16.04.2024.
//

import UIKit
import SwiftUI
import Combine
import SnapKit

class LessonsTableviewController: UIViewController, UITableViewDelegate {
    
    var student: Student!
    
    var selectedMonth: Month!
    
    var lessonPrice: Double = 0.0
    var selectedSchedules = [(weekday: String, time: String)]()
    var schedule: [String] {
        var scheduleStrings = selectedSchedules.map { "\($0.weekday) \($0.time)" }
        scheduleStrings.sort()
        return scheduleStrings
    }
    var lessonsForStudent: [Lesson] = []
    
    let addScheduledLessonsButton = UIButton(type: .system)
    let addLessonButton = UIButton(type: .system)
    var tableView: UITableView?
    private let datePicker = UIDatePicker()
    let monthDictionary: [String: String] = [
        "January": "01",
        "February": "02",
        "March": "03",
        "April": "04",
        "May": "05",
        "June": "06",
        "July": "07",
        "August": "08",
        "September": "09",
        "October": "10",
        "November": "11",
        "December": "12"
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        tableView?.reloadData()
        
        self.title = "Lessons List"
        // Регистрируем ячейку с использованием стиля .subtitle
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "LessonCell")
        
        // Ensure selectedMonth is set correctly
        print("Selected Month: \(selectedMonth.monthName) \(selectedMonth.monthYear)")
        
        // Заменяем кнопку "Back" на кастомную кнопку
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        // Создаем кнопку "Поделиться"
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        // Создаем кнопку "Сохранить"
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        // Устанавливаем обе кнопки в правую часть навигационного бара
        navigationItem.rightBarButtonItems = [saveButton, shareButton]
        checkIfScheduledLessonsAdded()
    }
    
    @objc func saveButtonTapped() {
        // Update lessons in the Month object in monthsArray
        selectedMonth.lessons = lessonsForStudent
        
        // Update student data
        if let index = student.months.firstIndex(where: { $0.monthName == selectedMonth.monthName && $0.monthYear == selectedMonth.monthYear }) {
            student.months[index] = selectedMonth
        }
    
        navigationController?.popViewController(animated: true)
        
        // Reload table view to reflect changes
        tableView?.reloadData()
        
        // Debug output
           print("Saved lessons for \(selectedMonth.monthName) \(selectedMonth.monthYear):")
           for lesson in selectedMonth.lessons {
               print("\(lesson.date) - \(lesson.attended ? "Present" : "Absent")")
           }
    }
    
    @objc private func backButtonTapped() {
//        savingConfirmation()
    }
    
    func checkIfScheduledLessonsAdded() {
        // Проверяем, пуст ли словарь lessonsForStudent для текущего месяца
        if !lessonsForStudent.isEmpty {
            addScheduledLessonsButton.setTitle("Delete all lessons", for: .normal)
            // Добавляем действие для кнопки при её нажатии после добавления уроков
            addScheduledLessonsButton.removeTarget(self, action: #selector(addScheduledLessonsButtonTapped), for: .touchUpInside)
            addScheduledLessonsButton.addTarget(self, action: #selector(deleteAllLessons), for: .touchUpInside)
        } else {
            addScheduledLessonsButton.setTitle("Add lessons according to the schedule", for: .normal)
            // Восстанавливаем действие для кнопки при её нажатии
            addScheduledLessonsButton.removeTarget(self, action: #selector(deleteAllLessons), for: .touchUpInside)
            addScheduledLessonsButton.addTarget(self, action: #selector(addScheduledLessonsButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func deleteAllLessons() {
        print("Deleting all lessons for \(selectedMonth.monthName) \(selectedMonth.monthYear)")
        // Удаляем все уроки для выбранного месяца из временного хранилища
        lessonsForStudent.removeAll()
        selectedMonth.lessons = lessonsForStudent
        
        tableView?.reloadData()
        // Обновляем состояние кнопки
        checkIfScheduledLessonsAdded()
        
        print("lessonsForStudent после удаления: \(lessonsForStudent)")
    }
    
    @objc func addScheduledLessonsButtonTapped() {
        
        print("Adding scheduled lessons for \(selectedMonth.monthName) \(selectedMonth.monthYear)")
        generateLessonsForMonth()
        
        selectedMonth.lessons = lessonsForStudent
        
        tableView?.reloadData()
        
        // Проверяем, были ли добавлены уроки согласно расписанию
        checkIfScheduledLessonsAdded()
        
        print("Adding scheduled lessons to selectedMonth.lessons \(selectedMonth.lessons)")
    }
    
    @objc func addLessonButtonTapped() {
        showDatePicker()
    }
    
    func showDatePicker() {
        let datePickerSheet = UIAlertController(title: "Lesson date", message: "\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePickerSheet.view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.width.equalTo(400)
            make.height.equalTo(300)
        }
        datePickerSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        datePickerSheet.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let selectedDate = datePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: selectedDate)
            self.addLesson(date: dateString, year: self.selectedMonth.monthYear, month: self.selectedMonth.monthYear, attended: false)
        }))
        tableView?.reloadData()
        present(datePickerSheet, animated: true, completion: nil)
    }
}

extension LessonsTableviewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMonth.lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle , reuseIdentifier: "LessonCell")
        guard indexPath.row < selectedMonth.lessons.count else {
            fatalError("Lessons for selected month not found or index out of range")
        }
        // Получаем урок для текущего индекса
        let lesson = selectedMonth.lessons[indexPath.row]
        // Форматирование даты
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        // Получаем дату из строки даты
        guard let lessonDate = dateFormatter.date(from: lesson.date) else {
            fatalError("Failed to convert lesson date to Date.")
        }
        // Получаем название дня недели из даты
        let weekdayString = lessonDate.weekday() // Вызываем метод weekday
        // Создание строки для отображения в ячейке
        let lessonDateString = "\(indexPath.row + 1). \(dateFormatter.string(from: lessonDate))"
        // Установка текста в ячейку в зависимости от того, присутствовал ли студент на уроке
        cell.textLabel?.text = lessonDateString
        cell.detailTextLabel?.text = lesson.attended ? "Was present (\(weekdayString))" : "Was absent (\(weekdayString))"
        // Устанавливаем или снимаем галочку в зависимости от состояния урока
        cell.accessoryType = lesson.attended ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let lesson = selectedMonth.lessons[indexPath.row]
        
        // Создаем экземпляр LessonDetailsViewController
        let lessonDetailVC = LessonDetailsViewController()
        
        // Передаем необходимые данные в LessonDetailsViewController
        lessonDetailVC.student = student
        lessonDetailVC.lesson = lesson
        lessonDetailVC.updatedlessonsForStudent = lessonsForStudent
        lessonDetailVC.homeworksArray = selectedMonth.lessons.map { $0.homework ?? "" }
        
        // Устанавливаем делегата для обратного обновления данных
        lessonDetailVC.delegate = self
        
        // Переходим на экран LessonDetailsViewController
        navigationController?.pushViewController(lessonDetailVC, animated: true)
        
        print("Selected student: \(String(describing: student))")
        print("Selected lesson: \(lesson)")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDeletion(at: indexPath)
        }
    }
    
    private func confirmDeletion(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Confirm the deletion", message: "Are you sure you want to delete this month?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteLesson(at: indexPath)
        }
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    private func deleteLesson(at indexPath: IndexPath) {
        selectedMonth.lessons.remove(at: indexPath.row)
        lessonsForStudent = selectedMonth.lessons
        
        tableView?.deleteRows(at: [indexPath], with: .fade)
        tableView?.reloadData()
    }
}

extension Date {
    func weekday(using calendar: Calendar = Calendar(identifier: .gregorian)) -> String {
        let weekdayIndex = calendar.component(.weekday, from: self)
        let dateFormatter = DateFormatter()
        return dateFormatter.shortWeekdaySymbols[weekdayIndex - 1]
    }
}

// MARK: - Lesson Management

extension LessonsTableviewController {
    
    func addLesson(date: String, year: String, month: String, attended: Bool) {
        print("Adding lesson for date: \(date)")
        let lesson = Lesson(date: date, attended: attended, photoUrls: [])
        selectedMonth.lessons.append(lesson)
        lessonsForStudent = selectedMonth.lessons
        updateUI()
    }
    
    func updateUI() {
        guard let lessonTableView = self.tableView else { return }
        lessonTableView.reloadData()
    }
    
    func generateLessonsForMonth() {
        guard let monthName = selectedMonth?.monthName, let monthYear = selectedMonth?.monthYear else {
            print("Month or year is not set.")
            return
        }
        
        print("Generating lessons for month: \(monthName), year: \(monthYear)")
        
        let calendar = Calendar.current
        guard let monthNumber = monthDictionary[monthName] else {
            print("Failed to get month number for \(monthName)")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        selectedMonth.lessons.removeAll() // Очищаем уроки только для выбранного месяца
        
        guard let date = dateFormatter.date(from: "01.\(monthNumber).\(monthYear)") else {
            print("Failed to convert month to date with string: 01.\(monthNumber).\(monthYear)")
            return
        }
        
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            print("Failed to get range of days in month for date: \(date)")
            return
        }
        
        for day in range.lowerBound..<range.upperBound {
            let dateString = String(format: "%02d.%02d.%@", day, Int(monthNumber)!, monthYear)
            if let currentDate = dateFormatter.date(from: dateString) {
                let weekday = calendar.component(.weekday, from: currentDate)
                let weekdayString = dateFormatter.shortWeekdaySymbols[weekday - 1].lowercased()
                
                for scheduleEntry in selectedSchedules {
                    let scheduleWeekday = scheduleEntry.0.lowercased()
                    if scheduleWeekday == weekdayString {
                        addLesson(date: dateString, year: monthYear, month: monthName, attended: false)
                    }
                }
            } else {
                print("Failed to convert dateString to date: \(dateString)")
            }
        }
    }
}

// MARK: - createShareMessage & shareButtonTapped

extension LessonsTableviewController {
    
    func createShareMessage() -> String {
        guard let student = student else { return "" }
        let studentType = student.type
        let name = studentType == .schoolchild ? student.parentName : student.name
        let lessonsForSelectedMonth = lessonsForStudent
        let lessonCount = lessonsForSelectedMonth.count
        let lessonPrice: Int
        let currency: String
        if let month = student.months.first(where: { $0.monthName == selectedMonth.monthName && $0.monthYear == selectedMonth.monthYear }) {
            lessonPrice = month.lessonPrice?.price ?? 0
            currency = month.lessonPrice?.currency ?? ""
        } else {
            lessonPrice = student.lessonPrice.price
            currency = student.lessonPrice.currency
        }
        let totalSum = lessonPrice * Int(lessonCount)
        return "Hello, \(name)! There are \(lessonCount) lessons in \(selectedMonth.monthName) \(selectedMonth.monthYear) = \(totalSum) \(currency)."
    }
    
    @objc func shareButtonTapped() {
        let message = createShareMessage()
        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        // Настройка для iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItems?.last
            popoverController.sourceView = self.view // для безопасности, хотя barButtonItem должно быть достаточно
        }
        present(activityViewController, animated: true, completion: nil)
    }
}


extension LessonsTableviewController {
    
    func setupUI() {
        // Создаем таблицу для отображения уроков
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self // Добавляем настройку делегата
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LessonCell")
        view.addSubview(tableView)
        
        // Устанавливаем стиль ячейки, чтобы включить detailTextLabel
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        
        // Добавляем таблицу на представление
        view.addSubview(tableView)
        
        // Присваиваем созданную таблицу свойству tableView
        self.tableView = tableView
        
        // Add Scheduled Lessons Button
        view.addSubview(addScheduledLessonsButton)
        addScheduledLessonsButton.snp.makeConstraints { make in
            //            make.bottom.equalTo(addScheduledLessonsButton.snp.top).offset(-20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
        }
        addScheduledLessonsButton.setTitle("Add lessons according to the schedule", for: .normal)
        addScheduledLessonsButton.layer.cornerRadius = 10
        addScheduledLessonsButton.setTitleColor(.white, for: .normal)
        addScheduledLessonsButton.backgroundColor = .systemBlue
        addScheduledLessonsButton.addTarget(self, action: #selector(addScheduledLessonsButtonTapped), for: .touchUpInside)
        
        // Add Scheduled Lessons Button
        view.addSubview(addLessonButton)
        addLessonButton.snp.makeConstraints { make in
            make.top.equalTo(addScheduledLessonsButton.snp.bottom).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
        }
        addLessonButton.setTitle("Add a lesson", for: .normal)
        addLessonButton.layer.cornerRadius = 10
        addLessonButton.setTitleColor(.white, for: .normal)
        addLessonButton.backgroundColor = .systemBlue
        addLessonButton.addTarget(self, action: #selector(addLessonButtonTapped), for: .touchUpInside)
    }
}
