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
    
    @ObservedObject var studentViewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
   
    var studentID: String

    init(viewModel: StudentViewModel, studentID: String) {
           self.studentViewModel = viewModel
           self.studentID = studentID
           super.init(style: .plain)
           
           self.tableView.reloadData()
       }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

            studentViewModel.studentsSubject
                .receive(on: RunLoop.main)
                .sink { [weak self] students in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
    
        if let selectedStudent = studentViewModel.getStudentById(studentID) {
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
            tableView.separatorColor = UIColor.lightGray
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        if let selectedStudent = studentViewModel.getStudentById(studentID) {
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
            if let selectedStudent = studentViewModel.getStudentById(studentID) {
                monthYearVC.existingMonths = selectedStudent.months
            }
            
            monthYearVC.didSelectMonthYear = { [weak self] month, year in
                self?.addMonth(year, monthName: month)
            }
            let navigationController = UINavigationController(rootViewController: monthYearVC)
            present(navigationController, animated: true)
        }
    
    private func addMonth(_ monthYear: String, monthName: String) {
         guard let selectedStudent = studentViewModel.getStudentById(studentID) else { return }

         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MMMM yyyy"
         let dateString = "\(monthName) \(monthYear)"

         guard let date = dateFormatter.date(from: dateString) else { return }
         let timestamp = date.timeIntervalSince1970

         let moneySum = 0
         let lessonPrice = selectedStudent.lessonPrice

         studentViewModel.addMonth(to: selectedStudent, monthName: monthName, monthYear: monthYear, lessonPrice: lessonPrice, moneySum: moneySum, timestamp: timestamp)

         tableView.reloadData()
     }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
            guard let selectedStudent = studentViewModel.getStudentById(studentID) else { return 0 }
            let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
            return groupedMonths.keys.count
        }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let selectedStudent = studentViewModel.getStudentById(studentID) else { return nil }
        let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
        let sortedKeys = groupedMonths.keys.sorted()
        let title = sortedKeys[section]

        let headerView = UIView()
        headerView.backgroundColor = .clear

        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = .darkGray

        headerView.addSubview(label)

        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           guard let selectedStudent = studentViewModel.getStudentById(studentID) else { return 0 }
           let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
           let sortedKeys = groupedMonths.keys.sorted()
           return groupedMonths[sortedKeys[section]]?.count ?? 0
       }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MonthCell", for: indexPath) as? MonthsTableViewControllerCell else { return UITableViewCell() }
        guard let selectedStudent = studentViewModel.getStudentById(studentID) else { return cell }
        let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
        let sortedKeys = groupedMonths.keys.sorted()
        let monthsForYear = groupedMonths[sortedKeys[indexPath.section]] ?? []
        let month = monthsForYear[indexPath.row]

        cell.configure(with: selectedStudent, month: month, delegate: self)

        cell.selectionStyle = .none
        return cell
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let selectedStudent = studentViewModel.getStudentById(studentID) else { return }

            let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
            let sortedKeys = groupedMonths.keys.sorted()
            let selectedMonth = groupedMonths[sortedKeys[indexPath.section]]?[indexPath.row]

            guard let selectedMonth = selectedMonth else { return }

            Task {
                do {
                    let lessons = try await studentViewModel.loadLessons(for: studentID, month: selectedMonth)
                    DispatchQueue.main.async {
                        let lessonsTableVC = LessonsTableViewController(
                            viewModel: self.studentViewModel,
                            studentId: self.studentID,
                            selectedMonth: selectedMonth,
                            lessonsForStudent: lessons
                        )
                        self.navigationController?.pushViewController(lessonsTableVC, animated: true)
                        print("tableView \(lessons)")
                    }
                } catch {
                    print("Failed to load lessons: \(error)")
                }
            }
        }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           guard let selectedStudent = studentViewModel.getStudentById(studentID) else { return nil }
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
        guard let selectedStudent = studentViewModel.getStudentById(studentID) else { return }
        let groupedMonths = Dictionary(grouping: selectedStudent.months, by: { $0.monthYear })
        let sortedKeys = groupedMonths.keys.sorted()
        let monthToDelete = groupedMonths[sortedKeys[indexPath.section]]?[indexPath.row]
        
        guard let monthToDelete = monthToDelete else { return }
        
        studentViewModel.deleteMonth(for: studentID, month: monthToDelete)
        tableView.reloadData()
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
        
            let buttonHeight: CGFloat = 44
            let buttonBottomInset: CGFloat = 40
            let totalInset = buttonHeight + buttonBottomInset

            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: totalInset, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: totalInset, right: 0)

        tableView.register(MonthsTableViewControllerCell.self, forCellReuseIdentifier: "MonthCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

}
