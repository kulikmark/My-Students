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


class LessonsTableViewController: UIViewController, UITableViewDelegate {
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var studentId: String
    var selectedMonth: Month
    var lessonsForStudent: [Lesson] = []
    
    init(viewModel: StudentViewModel, studentId: String, selectedMonth: Month, lessonsForStudent: [Lesson]) {
        self.viewModel = viewModel
        self.studentId = studentId
        self.selectedMonth = selectedMonth
        self.lessonsForStudent = lessonsForStudent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tableView: UITableView?
    let addScheduledLessonsButton = UIButton(type: .system)
    let addLessonButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupUI()
        
        viewModel.studentsSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadLessons()
            }
            .store(in: &cancellables)
        
        tableView?.reloadData()
        
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "LessonCell")
        
        setupNavigationItems()
        
        checkIfScheduledLessonsAdded()
    }
    
    // Load lessons from Firebase
    func loadLessons() {
        viewModel.loadLessons(for: studentId, month: selectedMonth) { result in
            switch result {
            case .success(let lessons):
                self.lessonsForStudent = lessons
                print(lessons)
                self.tableView?.reloadData()
                self.checkIfScheduledLessonsAdded()
            case .failure(let error):
                print("Error loading lessons: \(error)")
            }
        }
    }
    
    func saveLessons() {
        viewModel.saveLessons(for: studentId, lessons: lessonsForStudent, month: selectedMonth) { result in
            switch result {
            case .success:
                print("Lessons saved successfully.")
            case .failure(let error):
                print("Error saving lessons: \(error)")
            }
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateMonthSum() {
        let totalAmount = lessonsForStudent.count * (selectedMonth.lessonPrice?.price ?? 0)
            viewModel.updateMonthSum(for: studentId, month: selectedMonth, totalAmount: totalAmount) { result in
                switch result {
                case .success:
                    print("Month sum updated successfully.")
                case .failure(let error):
                    print("Error updating month sum: \(error)")
                }
            }
        }
    
    @objc func addScheduledLessonsButtonTapped() {
        print("Кнопка добавления расписания нажата")
        generateLessonsForMonth()
        checkIfScheduledLessonsAdded()
        tableView?.reloadData()
    }
    
    // Add lesson button tapped
    @objc func addLessonButtonTapped() {
        showDatePickerForLesson()
        tableView?.reloadData()
    }
    
    func showDatePickerForLesson() {
        let alertController = UIAlertController(title: "Select Lesson Date", message: nil, preferredStyle: .alert)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        alertController.view.addSubview(datePicker)
        
        // Устанавливаем ограничения для UIDatePicker
        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(30)
            make.height.equalTo(300)
        }
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let selectedDate = dateFormatter.string(from: datePicker.date)
            
            self.addLesson(date: selectedDate, attended: false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func addLesson(date: String, attended: Bool) {
        
        // Проверяем существует ли уже урок с такой датой
           if doesLessonExist(date: date) {
               // Если урок уже существует, показываем сообщение об ошибке
               let alert = UIAlertController(title: "Error", message: "The lesson has been already added.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               present(alert, animated: true, completion: nil)
               return
           }
        
        let lesson = Lesson(id: UUID().uuidString, date: date, attended: attended, homework: nil, HWPhotos: [], monthId: selectedMonth.id)
        lessonsForStudent.append(lesson)
        
        // Сначала сохраняем данные в Firebase
        saveLessons { success in
            if success {
                // Обновляем сумму месяца после успешного сохранения
                self.updateMonthSum()
                // Перезагружаем таблицу после сохранения данных
                self.tableView?.reloadData()
            } else {
                // Обработка ошибки
                print("Ошибка сохранения уроков")
            }
        }
    }
    
    // Проверка существования урока по дате
    func doesLessonExist(date: String) -> Bool {
        return lessonsForStudent.contains { $0.date == date }
    }


    func saveLessons(completion: @escaping (Bool) -> Void) {
        viewModel.saveLessons(for: studentId, lessons: lessonsForStudent, month: selectedMonth) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Ошибка сохранения уроков: \(error)")
                completion(false)
            }
        }
    }

    
    // Метод удаления конкретного урока
    func deleteLesson(at indexPath: IndexPath) {
        let lessonToDelete = lessonsForStudent[indexPath.row]
        
        // Удаление из локального массива
        lessonsForStudent.remove(at: indexPath.row)
        
        // Обновление таблицы
        tableView?.deleteRows(at: [indexPath], with: .automatic)
        
        // Обновление состояния кнопок
        checkIfScheduledLessonsAdded()
       
        // Сохранение изменений в Firebase
            viewModel.deleteLesson(for: studentId, month: selectedMonth, lessonId: lessonToDelete.id) { [weak self] result in
                switch result {
                case .success:
                    // Пересчет суммы после успешного удаления из Firebase
                    DispatchQueue.main.async {
                        self?.updateMonthSum()
                    }
                    print("Lesson deleted successfully.")
                case .failure(let error):
                    print("Error deleting lesson: \(error)")
                    // В случае ошибки можно вернуть урок обратно в массив, если это нужно
                }
            }
        }
    
    @objc func deleteAllLessons() {
        
        print("Delete all lessons button tapped")
        
        // Очистка массива уроков
        lessonsForStudent.removeAll()
        // Обновление состояния таблицы
        tableView?.reloadData()
        // Обновление состояния кнопок
        checkIfScheduledLessonsAdded()
        
        // Сохранение изменений в Firebase
        viewModel.deleteAllLessons(for: studentId, month: selectedMonth) { result in
            switch result {
            case .success:
                // Пересчет суммы после успешного удаления из Firebase
                DispatchQueue.main.async {
                    self.updateMonthSum()
                }
                print("All lessons deleted successfully.")
            case .failure(let error):
                print("Error deleting lessons: \(error)")
            }
        }
    }
    
    // Generate lessons for the month
    func generateLessonsForMonth() {
        // Словарь месяцев
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
        
        // Получение номера месяца
        guard let monthNumber = monthDictionary[selectedMonth.monthName] else {
            print("Не удалось найти номер месяца для: \(selectedMonth.monthName)")
            return
        }
        
        // Создание строки даты
        let dateString = "01.\(monthNumber).\(selectedMonth.monthYear)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        // Преобразование строки в дату
        guard let date = dateFormatter.date(from: dateString) else {
            print("Не удалось преобразовать строку в дату: \(dateString)")
            return
        }
        
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            print("Не удалось получить диапазон дней для месяца") // Отладочное сообщение
            return
        }
        
        // Извлечение расписания студента
        guard let student = viewModel.getStudentById(studentId) else {
            print("Студент с указанным ID не найден")
            return
        }
        let schedule = student.schedule
        
        for day in range {
            let dayString = String(format: "%02d", day)
            let currentDateString = "\(dayString).\(monthNumber).\(selectedMonth.monthYear)"
            
            if let currentDate = dateFormatter.date(from: currentDateString) {
                let weekday = calendar.component(.weekday, from: currentDate)
                let weekdayString = DateFormatter().shortWeekdaySymbols[weekday - 1].lowercased()
                
                for scheduleEntry in schedule {
                    let scheduleWeekday = scheduleEntry.weekday.lowercased()
                    if scheduleWeekday == weekdayString {
                        addLesson(date: currentDateString, attended: false)
                    }
                }
            } else {
                print("Не удалось преобразовать текущую строку в дату: \(currentDateString)")
            }
        }
    }
    
    // Set up UI elements
    func setupUI() {
        // Create table view
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        self.tableView = tableView
        
        // Add lesson button
        view.addSubview(addLessonButton)
        addLessonButton.setTitle("Add a lesson", for: .normal)
        addLessonButton.layer.cornerRadius = 10
        addLessonButton.setTitleColor(.white, for: .normal)
        addLessonButton.backgroundColor = .systemBlue
        addLessonButton.addTarget(self, action: #selector(addLessonButtonTapped), for: .touchUpInside)
        
        // Add scheduled lessons button
        view.addSubview(addScheduledLessonsButton)
        addScheduledLessonsButton.setTitle("Add lessons according to the schedule", for: .normal)
        addScheduledLessonsButton.layer.cornerRadius = 10
        addScheduledLessonsButton.setTitleColor(.white, for: .normal)
        addScheduledLessonsButton.backgroundColor = .systemBlue
        addScheduledLessonsButton.addTarget(self, action: #selector(addScheduledLessonsButtonTapped), for: .touchUpInside)
        
        // Set up constraints for buttons
        addScheduledLessonsButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        addLessonButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
            make.bottom.equalTo(addScheduledLessonsButton.snp.top).offset(-20)
        }
        
        // Set up constraints for the table view
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addLessonButton.snp.top).offset(-20)
        }
    }
    
    
    // Setup navigation items
    func setupNavigationItems() {
        self.title = "Lessons List"
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        //        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItems = [/*saveButton*/ shareButton]
    }
    
    func checkIfScheduledLessonsAdded() {
        print("Checking if scheduled lessons are added. Current lessons count: \(lessonsForStudent.count)")  // Добавьте отладочный вывод

        if !lessonsForStudent.isEmpty {
            addScheduledLessonsButton.setTitle("Delete all lessons", for: .normal)
            addScheduledLessonsButton.removeTarget(self, action: #selector(addScheduledLessonsButtonTapped), for: .touchUpInside)
            addScheduledLessonsButton.addTarget(self, action: #selector(deleteAllLessons), for: .touchUpInside)
        } else {
            addScheduledLessonsButton.setTitle("Add lessons according to the schedule", for: .normal)
            addScheduledLessonsButton.addTarget(self, action: #selector(addScheduledLessonsButtonTapped), for: .touchUpInside)
            addLessonButton.isHidden = false
        }
    }

}

// MARK: - UITableViewDataSource

extension LessonsTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonsForStudent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle , reuseIdentifier: "LessonCell")
        // Получаем урок для текущего индекса
        let lesson = lessonsForStudent[indexPath.row]
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
        
        let lesson = lessonsForStudent[indexPath.row]
        
        // Создаем экземпляр LessonDetailsViewController
        let lessonDetailVC = LessonDetailsViewController(viewModel: viewModel, studentId:studentId, selectedLesson: lesson)
        
        // Переходим на экран LessonDetailsViewController
        navigationController?.pushViewController(lessonDetailVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Разрешаем редактирование строки
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteLesson(at: indexPath)
        }
    }
}

extension Date {
    func weekday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}


// MARK: - createShareMessage & shareButtonTapped

extension LessonsTableViewController {
    
    func isRussianLanguage(for student: Student) -> Bool {
        let name = student.type == .schoolchild ? student.parentName : student.name
        // Проверка, содержит ли имя кириллические символы
        return name.range(of: "\\p{Cyrillic}", options: .regularExpression) != nil
    }
    
    // Функция для перевода названий месяцев
        func translateMonth(_ month: String, isRussian: Bool) -> String {
            let monthsEnglishToRussian = [
                "January": "Январе", "February": "Феврале", "March": "Марте",
                "April": "Апреле", "May": "Мае", "June": "Июне",
                "July": "Июле", "August": "Августе", "September": "Сентябре",
                "October": "Октябре", "November": "Ноябре", "December": "Декабре"
            ]
            return isRussian ? (monthsEnglishToRussian[month] ?? month) : month
        }

        // Функция для перевода дней недели
        func translateWeekday(_ weekday: String, isRussian: Bool) -> String {
            let weekdaysEnglishToRussian = [
                "MON": "ПН", "TUE": "ВТ", "WED": "СР",
                "THU": "ЧТ", "FRI": "ПТ", "SAT": "СБ", "SUN": "ВС"
            ]
            return isRussian ? (weekdaysEnglishToRussian[weekday] ?? weekday) : weekday
        }
    
    func createShareMessage(for student: Student) -> String {
        let isRussian = isRussianLanguage(for: student)
        
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
        
        // Перевод названия месяца
        let translatedMonth = translateMonth(selectedMonth.monthName, isRussian: isRussian)
        
        // Формирование сообщения
        let message: String
        if isRussian {
            message = "Здравствуйте, \(name)! В \(translatedMonth) \(selectedMonth.monthYear) у вас \(lessonCount) уроков, что составляет \(totalSum) \(currency). Переводом на Тинькофф."
        } else {
            message = "Hello, \(name)! There are \(lessonCount) lessons in \(translatedMonth) \(selectedMonth.monthYear) = \(totalSum) \(currency). Transfer to Tinkoff."
        }
        
        // Добавление текста о расписании
        let scheduleText = createScheduleText(for: student, isRussian: isRussian)
        
        return "\(message)\n\(scheduleText)"
    }
    
    func createScheduleText(for student: Student, isRussian: Bool) -> String {
        let schedule = student.schedule
        let scheduleDetails: String
        
        if isRussian {
            scheduleDetails = schedule.map { "\(translateWeekday($0.weekday, isRussian: true)) в \($0.time)" }.joined(separator: "\n")
            return "Ваше расписание:\n\(scheduleDetails)"
        } else {
            scheduleDetails = schedule.map { "\(translateWeekday($0.weekday, isRussian: false)) at \($0.time)" }.joined(separator: "\n")
            return "Your schedule:\n\(scheduleDetails)"
        }
    }
    
    
    @objc func shareButtonTapped() {
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return }
        let message = createShareMessage(for: selectedStudent)
        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItems?.last
            popoverController.sourceView = self.view
        }
        present(activityViewController, animated: true, completion: nil)
    }
}
