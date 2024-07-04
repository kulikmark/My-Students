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

class StudentsCollectionViewController: UICollectionViewController {
    var realm: Realm!
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
  
    private var isEditingCells: Bool = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // Properties for layout
        private let padding: CGFloat = 10
        private let minimumItemSpacing: CGFloat = 10
        private var itemWidth: CGFloat {
            let width = view.bounds.width
            let availableWidth = width - (padding * 3) - minimumItemSpacing
            return availableWidth / 2
        }
    
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewFlowLayout()) // Initialize with a layout here
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStartScreenLabelVisibility(for: collectionView)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.updateStartScreenLabelVisibility(for: self?.collectionView)
            }
            .store(in: &cancellables)
        
        view.backgroundColor = UIColor.systemGroupedBackground
        self.title = "Students List"
        
        setupSearchController()
        setupCollectionView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewStudent))
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupStartScreenLabel(with: "Add first student \n\n Tap + in the left corner of the screen")
        updateStartScreenLabelVisibility(for: collectionView)
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.register(StudentCollectionViewCell.self, forCellWithReuseIdentifier: "StudentCell")
        
        // Set the layout if not initialized in the init
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 145)
            flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            flowLayout.minimumInteritemSpacing = minimumItemSpacing
            flowLayout.minimumLineSpacing = minimumItemSpacing
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        isEditingCells = editing
        collectionView.reloadData()
    }
    
    @objc func addNewStudent() {
        let studentCardVC = StudentCardViewController(viewModel: viewModel, editMode: .add)
        navigationController?.pushViewController(studentCardVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension StudentsCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Implement your search logic here
    }
}

// MARK: - UISearchBarDelegate

extension StudentsCollectionViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let studentsSearchVC = StudentsSearchViewController(viewModel: self.viewModel)
        self.navigationController?.pushViewController(studentsSearchVC, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Implement your logic here if needed
    }
}

// MARK: - UICollectionViewDataSource

extension StudentsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.students.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
        override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
                    self.showDeleteConfirmation(at: indexPath)
                }
                return UIMenu(title: "", children: [deleteAction])
            }
            return configuration
        }
}

// MARK: - UICollectionViewDragDelegate

extension StudentsCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let student = viewModel.students[indexPath.item]
        let itemProvider = NSItemProvider(object: student.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = student
        collectionView.reloadData()
        return [dragItem]
    }
}

// MARK: - UICollectionViewDropDelegate

extension StudentsCollectionViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        coordinator.items.forEach { dropItem in
            if let sourceIndexPath = dropItem.sourceIndexPath {
                collectionView.performBatchUpdates {
                    let student = viewModel.students.remove(at: sourceIndexPath.item)
                    viewModel.students.insert(student, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }
                coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
            }
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
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
        collectionView.deleteItems(at: [indexPath])
        updateStartScreenLabelVisibility(for: collectionView)
    }
}
