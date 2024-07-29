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

    init(viewModel: StudentViewModel, studentId: String) {
           self.viewModel = viewModel
           self.studentId = studentId
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
        showMonthYearSelection()
    }
    
    private func displayErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showMonthYearSelection() {
            let monthYearVC = MonthYearSelectionViewController()
            
            // Pass existing months to the selection controller
            if let selectedStudent = viewModel.getStudentById(studentId) {
                monthYearVC.existingMonths = selectedStudent.months
            }
            
            monthYearVC.didSelectMonthYear = { [weak self] month, year in
                self?.addMonth(year, monthName: month)
            }
            let navigationController = UINavigationController(rootViewController: monthYearVC)
            present(navigationController, animated: true)
        }
    
    private func addMonth(_ monthYear: String, monthName: String) {
         guard let selectedStudent = viewModel.getStudentById(studentId) else { return }

         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MMMM yyyy"
         let dateString = "\(monthName) \(monthYear)"

         guard let date = dateFormatter.date(from: dateString) else { return }
         let timestamp = date.timeIntervalSince1970

         let moneySum = 0
         let lessonPrice = selectedStudent.lessonPrice

         viewModel.addMonth(to: selectedStudent, monthName: monthName, monthYear: monthYear, lessonPrice: lessonPrice, moneySum: moneySum, timestamp: timestamp)

         tableView.reloadData()
     }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
            guard let selectedStudent = viewModel.getStudentById(studentId) else { return 0 }
            let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
            return groupedMonths.keys.count
        }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return nil }
        let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
        let sortedKeys = groupedMonths.keys.sorted()
        let title = sortedKeys[section]

        // Создаем UIView для заголовка
        let headerView = UIView()
        headerView.backgroundColor = .clear

        // Создаем UILabel для заголовка
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 25) // Измените размер шрифта здесь
        label.textColor = .darkGray

        // Добавляем UILabel в headerView
        headerView.addSubview(label)

        // Настраиваем отступы с помощью SnapKit
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16) // Отступ слева
            make.trailing.equalToSuperview().offset(-16) // Отступ справа
            make.top.equalToSuperview().offset(8) // Отступ сверху
            make.bottom.equalToSuperview().offset(-8) // Отступ снизу
        }

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Установите нужную высоту заголовка секции
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           guard let selectedStudent = viewModel.getStudentById(studentId) else { return 0 }
           let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
           let sortedKeys = groupedMonths.keys.sorted()
           return groupedMonths[sortedKeys[section]]?.count ?? 0
       }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "MonthCell", for: indexPath) as! MonthsTableViewControllerCell
//
//            guard let selectedStudent = viewModel.getStudentById(studentId) else { return cell }
//            let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
//            let sortedKeys = groupedMonths.keys.sorted()
//            let monthsForYear = groupedMonths[sortedKeys[indexPath.section]] ?? []
//            let month = monthsForYear[indexPath.row]
//
//            cell.configure(with: selectedStudent, month: month, index: indexPath.row, target: self, action: #selector(switchValueChanged(_:)))
//
//            cell.selectionStyle = .none
//            return cell
//        }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonthCell", for: indexPath) as! MonthsTableViewControllerCell
        // TODO: Say NO to force unwrap '!'  guard let... else { return UITableViewCell() }
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return cell }
        let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
        let sortedKeys = groupedMonths.keys.sorted()
        let monthsForYear = groupedMonths[sortedKeys[indexPath.section]] ?? []
        let month = monthsForYear[indexPath.row]

        cell.configure(with: selectedStudent, month: month, delegate: self)

        cell.selectionStyle = .none
        return cell
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let selectedStudent = viewModel.getStudentById(studentId) else { return }

            let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
            let sortedKeys = groupedMonths.keys.sorted()
            let selectedMonth = groupedMonths[sortedKeys[indexPath.section]]?[indexPath.row]

            guard let selectedMonth = selectedMonth else { return }

            Task {
                do {
                    let lessons = try await viewModel.loadLessons(for: studentId, month: selectedMonth)
                    DispatchQueue.main.async {
                        let lessonsTableVC = LessonsTableViewController(
                            viewModel: self.viewModel,
                            studentId: self.studentId,
                            selectedMonth: selectedMonth,
                            lessonsForStudent: lessons
                        )
                        self.navigationController?.pushViewController(lessonsTableVC, animated: true)
                    }
                } catch {
                    print("Failed to load lessons: \(error)")
                }
            }
        }
    
    // TODO: - Such logic should be handled in viewModel. It's a business logic it has nothing to do with UIViewController 
    func updatePaidStatus(for month: Month, isPaid: Bool) {
        guard var selectedStudent = viewModel.getStudentById(studentId) else { return }
        
        if let index = selectedStudent.months.firstIndex(where: { $0.id == month.id }) {
            selectedStudent.months[index].isPaid = isPaid
            selectedStudent.months[index].paymentDate = month.paymentDate
            
            // Обновление в Firebase
            FirebaseManager.shared.addOrUpdateStudent(selectedStudent) { [weak self] result in
                switch result {
                case .success:
                    self?.viewModel.fetchStudents() // Обновление списка студентов
                case .failure(let error):
                    print("Error updating paid status: \(error)")
                }
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           guard let selectedStudent = viewModel.getStudentById(studentId) else { return nil }
           let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
           let sortedKeys = groupedMonths.keys.sorted()
           return sortedKeys[section]
       }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
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
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return }
        let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
        let sortedKeys = groupedMonths.keys.sorted()
        let monthToDelete = groupedMonths[sortedKeys[indexPath.section]]?[indexPath.row]
        
        guard let monthToDelete = monthToDelete else { return }
        
        viewModel.deleteMonth(for: studentId, month: monthToDelete)
        tableView.reloadData() // Reload data to reflect changes in sections
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
        
        // Adjust table view content inset to account for the button
            let buttonHeight: CGFloat = 44
            let buttonBottomInset: CGFloat = 40
            let totalInset = buttonHeight + buttonBottomInset

            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: totalInset, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: totalInset, right: 0)

        // Настройка таблицы оплаченных месяцев
        tableView.register(MonthsTableViewControllerCell.self, forCellReuseIdentifier: "MonthCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

}
