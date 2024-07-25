//
//  MonthsTableViewController.swift
//  Accounting
//
//  Created by Марк Кулик on 13.04.2024.
//

import UIKit
import SwiftUI
import Combine
import SnapKit

class MonthsTableViewController: UITableViewController {
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
   
    var studentId: String
    var studentLessonPrice: Int
    var lessonsByMonth: [String: [Lesson]] = [:]

    init(viewModel: StudentViewModel, studentId: String, studentLessonPrice: Int, lessonsByMonth: [String: [Lesson]]) {
           self.viewModel = viewModel
           self.studentId = studentId
           self.studentLessonPrice = studentLessonPrice
           self.lessonsByMonth = lessonsByMonth
           super.init(style: .plain)
           
           // Reload table view with preloaded lessons
           self.tableView.reloadData()
       }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        if let selectedStudent = viewModel.getStudentById(studentId) {
                title = "Months list of \(selectedStudent.name)"
            }
        
        setupUI()
        setupTableView()
        setupNavigationBar()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    private func setupTableView() {
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = UIColor.lightGray // Custom color for separators
            tableView.separatorInset = UIEdgeInsets.zero // Remove any inset if needed
            tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        if let selectedStudent = viewModel.getStudentById(studentId) {
            FirebaseManager.shared.addOrUpdateStudent(selectedStudent) { result in
                switch result {
                case .success:
                    print("Student months updated successfully.")
                case .failure(let error):
                    print("Error adding student: \(error.localizedDescription)")
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    
    @objc private func addMonthButtonTapped() {
        showMonthSelection()
    }
    
    private func displayErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showMonthSelection() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        for month in ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"] {
            alertController.addAction(UIAlertAction(title: month, style: .default, handler: { [weak self] _ in
                self?.showYearInput(forMonth: month)
            }))
        }
        
        present(alertController, animated: true)
    }
    
    private func showYearInput(forMonth month: String) {
        let yearAlertController = UIAlertController(title: "Enter Year", message: nil, preferredStyle: .alert)
        
        yearAlertController.addTextField { textField in
            textField.placeholder = "Year"
            textField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let yearText = yearAlertController.textFields?.first?.text {
                self?.addMonth(yearText, monthName: month)
            }
        }
        
        yearAlertController.addAction(cancelAction)
        yearAlertController.addAction(addAction)
        
        present(yearAlertController, animated: true)
    }
    
//    private func addMonth(_ monthYear: String, monthName: String) {
//        guard let selectedStudent = viewModel.getStudentById(studentId) else { return }
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMMM yyyy"
//        let dateString = "\(monthName) \(monthYear)"
//        
//        guard let date = dateFormatter.date(from: dateString) else { return }
//        let timestamp = date.timeIntervalSince1970
//        
//        // Проверяем уникальность месяца и года
//        if selectedStudent.months.contains(where: { $0.monthName == monthName && $0.monthYear == monthYear }) {
//            let errorAlert = UIAlertController(title: "Error", message: "This month and year already exists.", preferredStyle: .alert)
//            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(errorAlert, animated: true, completion: nil)
//        } else {
//            viewModel.addMonth(to: selectedStudent, monthName: monthName, monthYear: monthYear, timestamp: timestamp)
//            tableView.reloadData()
//        }
//    }
    
    private func addMonth(_ monthYear: String, monthName: String) {
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let dateString = "\(monthName) \(monthYear)"
        
        guard let date = dateFormatter.date(from: dateString) else { return }
        let timestamp = date.timeIntervalSince1970
        
        // Проверяем уникальность месяца и года
        if selectedStudent.months.contains(where: { $0.monthName == monthName && $0.monthYear == monthYear }) {
            let errorAlert = UIAlertController(title: "Error", message: "This month and year already exists.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlert, animated: true, completion: nil)
        } else {
           
            let moneySum = 0
            
            viewModel.addMonth(to: selectedStudent, monthName: monthName, monthYear: monthYear, moneySum: moneySum, timestamp: timestamp)
            
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return 0 }
//        return selectedStudent.months.count
        return sortedMonths(from: selectedStudent).count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonthCell", for: indexPath) as! MonthsTableViewControllerCell
        
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return cell }
//        let month = selectedStudent.months[indexPath.row]
        let sortedMonths = sortedMonths(from: selectedStudent)
                let month = sortedMonths[indexPath.row]
        let lessons = lessonsByMonth[month.id] ?? []
        cell.configure(with: selectedStudent, month: month, lessons: lessons, index: indexPath.row, target: self, action: #selector(switchValueChanged(_:)))
        
        cell.selectionStyle = .none
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let selectedStudent = viewModel.getStudentById(studentId) else { return }
//        
////        let selectedMonth = selectedStudent.months[indexPath.row]
//        let selectedMonth = sortedMonths(from: selectedStudent)[indexPath.row]
//        
//        let lessonsTableVC = LessonsTableViewController(
//                    viewModel: viewModel,
//                    studentId: studentId,
//                    selectedMonth: selectedMonth,
//                    studentLessonPrice: studentLessonPrice
//                )
//        navigationController?.pushViewController(lessonsTableVC, animated: true)
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return }
        
        let selectedMonth = sortedMonths(from: selectedStudent)[indexPath.row]

        Task {
            do {
                // Load lessons for the selected month
                let lessons = try await viewModel.loadLessons(for: studentId, month: selectedMonth)
                DispatchQueue.main.async {
                    // Initialize the LessonsTableViewController with the loaded lessons
                    let lessonsTableVC = LessonsTableViewController(
                        viewModel: self.viewModel,
                        studentId: self.studentId,
                        selectedMonth: selectedMonth,
                        studentLessonPrice: self.studentLessonPrice,
                        lessonsForStudent: lessons // Pass the loaded lessons here
                    )
                    self.navigationController?.pushViewController(lessonsTableVC, animated: true)
                }
            } catch {
                print("Failed to load lessons: \(error)")
            }
        }
    }


    @objc private func switchValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        viewModel.updatePaidStatus(for: studentId, at: index, isPaid: sender.isOn)
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDeletion(at: indexPath)
        }
    }
    
    private func sortedMonths(from student: Student) -> [Month] {
        return student.months.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func confirmDeletion(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Confirm the deletion", message: "Are you sure you want to delete this month?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteMonth(at: indexPath)
        }
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteMonth(at indexPath: IndexPath) {
        viewModel.deleteMonth(for: studentId, at: indexPath.row)
    }
    
    // MARK: - Sorting months
    
    private func findInsertIndex(for newMonth: Month, in student: Student) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        guard let newDate = dateFormatter.date(from: "\(newMonth.monthName) \(newMonth.monthYear)") else {
            return student.months.count
        }
        
        for (index, month) in student.months.enumerated() {
            guard let monthDate = dateFormatter.date(from: "\(month.monthName) \(month.monthYear)") else {
                continue
            }
            if newDate < monthDate {
                return index
            }
        }
        return student.months.count
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Add Paid Month Button
        let addPaidMonthButton = UIButton(type: .system)
        addPaidMonthButton.setTitle("Add month", for: .normal)
        addPaidMonthButton.layer.cornerRadius = 10
        addPaidMonthButton.setTitleColor(.white, for: .normal)
        addPaidMonthButton.backgroundColor = .systemBlue
        addPaidMonthButton.addTarget(self, action: #selector(addMonthButtonTapped), for: .touchUpInside)
        
        view.addSubview(addPaidMonthButton)
        addPaidMonthButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
        }
        
        // Настройка таблицы оплаченных месяцев
        tableView.register(MonthsTableViewControllerCell.self, forCellReuseIdentifier: "MonthCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}
