//
//  StudentsTableViewController.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import SwiftUI
import Combine
import SnapKit
import RealmSwift

class StudentsCollectionViewController: UIViewController {
    var realm: Realm!
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    var studentsCollectionView: UICollectionView!
  
    
    private var isEditingCells: Bool = false
    private var filteredStudents = [Student]()
    private var searchHistory = [Student]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStartScreenLabelVisibility(for: studentsCollectionView)
        studentsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.filteredStudents = students
                self?.studentsCollectionView.reloadData()
                self?.updateStartScreenLabelVisibility(for: self?.studentsCollectionView)
            }
            .store(in: &cancellables)
        
        view.backgroundColor = UIColor.systemGroupedBackground
        self.title = "Students List"
        
        setupSearchController()
        setupCollectionView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewStudent))
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupStartScreenLabel(with: "Add first student \n\n Tap + in the left corner of the screen")
        updateStartScreenLabelVisibility(for: studentsCollectionView)
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
    
    func setupCollectionView() {
        studentsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createTwoColumnsFlowLayout())
        studentsCollectionView.delegate = self
        studentsCollectionView.dataSource = self
        studentsCollectionView.backgroundColor = .clear
        studentsCollectionView.register(StudentCollectionViewCell.self, forCellWithReuseIdentifier: "StudentCell")
        
        view.addSubview(studentsCollectionView)
        studentsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func createTwoColumnsFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 10
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = width - (padding * 3) - minimumItemSpacing
        let itemWidth = availableWidth / 2
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 145)
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.minimumInteritemSpacing = minimumItemSpacing
        flowLayout.minimumLineSpacing = minimumItemSpacing
        return flowLayout
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        isEditingCells = editing
        studentsCollectionView.reloadData()
    }
    
    @objc func addNewStudent() {
        let studentCardVC = StudentCardViewController(viewModel: viewModel, editMode: .add)
        navigationController?.pushViewController(studentCardVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension StudentsCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        filterStudents(for: searchController.searchBar.text ?? "")
    }
}

// MARK: - UISearchBarDelegate

extension StudentsCollectionViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let studentsSearchVC = StudentsSearchViewController(viewModel: self.viewModel)
        self.navigationController?.pushViewController(studentsSearchVC, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
      
    }
    
}

extension StudentsCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditingCells {
            return
        }
        let monthsVC = MonthsTableViewController()
        let student = viewModel.students[indexPath.item]
        monthsVC.student = student
        navigationController?.pushViewController(monthsVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
                self.showDeleteConfirmation(at: indexPath)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
        return configuration
    }
}

// MARK: - UICollectionViewDataSource

extension StudentsCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.students.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudentCell", for: indexPath) as! StudentCollectionViewCell
        let student = viewModel.students[indexPath.item]
            cell.configure(with: student)
            cell.isEditing = isEditingCells
            cell.showDeleteConfirmation = { [weak self] in
                self?.showDeleteConfirmation(at: indexPath)
            }
            
            cell.editAction = { [weak self] in
                let studentCardVC = StudentCardViewController(viewModel: self!.viewModel, editMode: .edit)
                studentCardVC.student = student
         self?.isEditing = false
                self?.navigationController?.pushViewController(studentCardVC, animated: true)
            }
            return cell
    }
}

extension StudentsCollectionViewController {
    func showDeleteConfirmation(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Student", message: "Are you sure you want to delete this student?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteStudent(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteStudent(at indexPath: IndexPath) {
        viewModel.removeStudent(at: indexPath.item)
        studentsCollectionView.deleteItems(at: [indexPath])
        updateStartScreenLabelVisibility(for: studentsCollectionView)
    }
}
