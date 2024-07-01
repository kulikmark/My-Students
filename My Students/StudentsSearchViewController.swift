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
import RealmSwift

class StudentsSearchViewController: UIViewController {
    var realm: Realm!
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    var searchHistoryCollectionView: UICollectionView!
    
    private var filteredStudents = [Student]()
    private var searchHistory = [Student]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        setupSearchController()
        setupSearchHistoryCollectionView()
        
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.filteredStudents = students
                self?.searchHistoryCollectionView.reloadData()
                self?.searchHistoryCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Students"
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    func setupSearchHistoryCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 95)
        layout.minimumLineSpacing = 10
        let padding: CGFloat = 10
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        searchHistoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        searchHistoryCollectionView.delegate = self
        searchHistoryCollectionView.dataSource = self
        searchHistoryCollectionView.backgroundColor = .white
        searchHistoryCollectionView.register(SearchHistoryCollectionViewCell.self, forCellWithReuseIdentifier: "SearchHistoryCell")
        
        view.addSubview(searchHistoryCollectionView)
        searchHistoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(110)
        }
    }
    
    private func filterStudents(for searchText: String) {
        if searchText.isEmpty {
            filteredStudents = viewModel.students
        } else {
            filteredStudents = viewModel.students.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        searchHistoryCollectionView.reloadData()
    }
}

// MARK: - UISearchResultsUpdating

extension StudentsSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterStudents(for: searchController.searchBar.text ?? "")
    }
}

// MARK: - UISearchBarDelegate

extension StudentsSearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Можно добавить дополнительную логику при начале редактирования поиска
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Можно добавить дополнительную логику при завершении редактирования поиска
    }
}

// MARK: - UICollectionViewDelegate

extension StudentsSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let student = searchHistory[indexPath.item]
        let monthsVC = MonthsTableViewController()
        monthsVC.student = student
        navigationController?.pushViewController(monthsVC, animated: true)
        
        if let index = searchHistory.firstIndex(where: { $0.id == student.id }) {
            searchHistory.remove(at: index)
        }
        searchHistory.insert(student, at: 0)
        searchHistoryCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension StudentsSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchHistoryCell", for: indexPath) as! SearchHistoryCollectionViewCell
        let student = searchHistory[indexPath.item]
        cell.configure(with: student)
        return cell
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension StudentsSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentTableViewCell
        let student = filteredStudents[indexPath.row]
        cell.configure(with: student)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = filteredStudents[indexPath.row]
        let monthsVC = MonthsTableViewController()
        monthsVC.student = student
        navigationController?.pushViewController(monthsVC, animated: true)
    }
}
