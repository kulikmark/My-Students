//
//  MonthsTableViewController.swift
//  Accounting
//
//  Created by Марк Кулик on 29.04.2024.
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
    
    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.clear
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        if let selectedStudent = viewModel.getStudentById(studentId) {
            FirebaseManager.shared.addOrUpdateStudent(selectedStudent) { error in
                if let error = error {
                    print("Error adding student: \(error.localizedDescription)")
                } else {
                    print("Student months updated successfully.")
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func addMonthButtonTapped() {
        guard let selectedStudent = viewModel.getStudentById(studentId), hasSelectedSchedule(student: selectedStudent) else {
            displayErrorMessage("Add a schedule in the student card")
            return
        }
        showMonthSelection()
    }
    
    private func hasSelectedSchedule(student: Student) -> Bool {
        return !student.schedule.isEmpty
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
    
    private func addMonth(_ monthYear: String, monthName: String) {
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return }
        
        // Проверяем уникальность месяца и года
        if selectedStudent.months.contains(where: { $0.monthName == monthName && $0.monthYear == monthYear }) {
            let errorAlert = UIAlertController(title: "Error", message: "This month and year already exists.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlert, animated: true, completion: nil)
        } else {
            viewModel.addMonth(to: selectedStudent, monthName: monthName, monthYear: monthYear)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return 0 }
        return selectedStudent.months.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonthCell", for: indexPath) as! MonthCell
        
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return cell }
        let month = selectedStudent.months[indexPath.row]
        
        cell.configure(with: selectedStudent, month: month, index: indexPath.row, target: self, action: #selector(switchValueChanged(_:)))
        cell.selectionStyle = .none
        return cell
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        guard let selectedStudent = viewModel.getStudentById(studentId) else { return }
        viewModel.updatePaidStatus(for: studentId, at: index, isPaid: sender.isOn)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDeletion(at: indexPath)
        }
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
        tableView.register(MonthCell.self, forCellReuseIdentifier: "MonthCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}
