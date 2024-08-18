//
//  StudentsSearchTableViewController.swift
//  My Students
//
//  Created by Марк Кулик on 01.07.2024.
//

import UIKit
import SwiftUI
import Combine
import SnapKit

class StudentsSearchViewController: UIViewController {
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    let searchController = UISearchController(searchResultsController: nil)
    var studentsTableView: UITableView!
    
    private var filteredStudents = [Student]()
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.searchController.isActive = true
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.backButtonTitle = nil
        
        setupSearchController()
        setupStudentsTableView()
        
        viewModel.studentsSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.studentsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.searchHistorySubject
            .receive(on: RunLoop.main)
            .sink { [weak self] history in
                self?.studentsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        // Load initial search history
        viewModel.fetchSearchHistory()
        
    }
    
    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Students"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    func setupStudentsTableView() {
        studentsTableView = UITableView()
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        studentsTableView.register(StudentSearchHistoryTableViewCell.self, forCellReuseIdentifier: "StudentCell")
        studentsTableView.register(SearchHistoryHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHistoryHeaderView")
        
        view.addSubview(studentsTableView)
        
        studentsTableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(-20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension StudentsSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text ?? ""
        if searchText.isEmpty {
            filteredStudents = viewModel.students.filter { student in
                viewModel.searchHistory.contains { $0.studentId == student.id }
            }
        } else {
            filteredStudents = viewModel.students.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // Сортируем filteredStudents по времени последнего поиска в обратном порядке
        filteredStudents.sort { student1, student2 in
            guard let history1 = viewModel.searchHistory.first(where: { $0.studentId == student1.id }),
                  let history2 = viewModel.searchHistory.first(where: { $0.studentId == student2.id })
            else { return false }
            return history1.timestamp > history2.timestamp
        }
        
        studentsTableView.reloadData()
    }
}


// MARK: - UISearchBarDelegate

extension StudentsSearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Additional logic when search bar begins editing
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Additional logic when search bar ends editing
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension StudentsSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredStudents.count : viewModel.searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentSearchHistoryTableViewCell
        let student = searchController.isActive ? filteredStudents[indexPath.row] : viewModel.students.first { $0.id == viewModel.searchHistory[indexPath.row].studentId }
        if let student = student {
            cell.configure(with: student)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = searchController.isActive ? filteredStudents[indexPath.row] : viewModel.students.first { $0.id == viewModel.searchHistory[indexPath.row].studentId }
        
        if let student = student {
            // Update search history
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.viewModel.addSearchHistoryItem(for: student)
            }
            
            navigateToMonths(for: student)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SearchHistoryHeaderView(viewModel: viewModel)
        headerView.configure(with: viewModel.students, delegate: self)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 140
    }
}

// MARK: - StudentsTableViewHeaderDelegate

extension StudentsSearchViewController: StudentsTableViewHeaderDelegate {
    func clearSearchHistory() {
        
        DispatchQueue.main.async {
            self.viewModel.clearSearchHistory()
        }
        
        searchController.isActive = false
        
        studentsTableView.reloadData()
    }
    
    func navigateToMonths(for student: Student) {
        guard let studentId = student.id else {
            print("Student ID is missing.")
            return
        }
        
        DispatchQueue.main.async {
            let monthsTableVC = MonthsTableViewController(
                viewModel: self.viewModel,
                studentID: studentId
            )
            self.navigationController?.pushViewController(monthsTableVC, animated: true)
            
        }
        
    }
}

protocol StudentsTableViewHeaderDelegate: AnyObject {
    func clearSearchHistory()
    func navigateToMonths(for student: Student)
}
