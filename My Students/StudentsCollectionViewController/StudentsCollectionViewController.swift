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

class StudentsCollectionViewController: UICollectionViewController {
    
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
    
    private lazy var addStudentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 25 // половина ширины
        return button
    }()
    
    private lazy var editStudentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.isHidden = true
        return button
    }()
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Checking for memory leak
    
    deinit {
            print("StudentsCollectionViewController is being deallocated")
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            print("StudentsCollectionViewController received a memory warning")
        }
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchStudents()
        self.updateStartScreenLabel(with: "Add first student \n\n Tap + in the right corner of the screen", isEmpty: self.viewModel.students.isEmpty, collectionView: self.collectionView ?? UICollectionView())
        collectionView.reloadData()
        
        updateButtonsVisibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.collectionView.reloadData()
                self?.updateStartScreenLabel(with: "Add first student \n\n Tap + in the right corner of the screen", isEmpty: students.isEmpty, collectionView: self?.collectionView ?? UICollectionView())
                self?.updateButtonsVisibility()
            }
            .store(in: &cancellables)
        
        view.backgroundColor = UIColor.systemGroupedBackground
                self.title = "Students List"
        
        
        setupSearchController()
        setupCollectionView()
        
        setupAddButton()
        setupEditButton()
        
        setupStartScreenLabel(with: "Add first student \n\n Tap + in the right corner of the screen")
    }
    
    // MARK: - Student Add / Edit Methods
    
    func setupAddButton() {
        view.addSubview(addStudentButton)
        addStudentButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
        }
        addStudentButton.addTarget(self, action: #selector(addNewStudent), for: .touchUpInside)
    }
    
    @objc func addNewStudent() {
        let studentCardVC = StudentCardViewController(viewModel: viewModel, editMode: .add)
        navigationController?.pushViewController(studentCardVC, animated: true)
    }
    
    func setupEditButton() {
        view.addSubview(editStudentButton)
        editStudentButton.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            make.bottom.equalTo(addStudentButton.snp.top).offset(-20)
        }
        editStudentButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    @objc func editButtonTapped() {
        isEditingCells.toggle() // Переключаем значение флага редактирования
        
        // Устанавливаем изображение кнопки в зависимости от режима редактирования
        let buttonImageName = isEditingCells ? "checkmark" : "pencil"
        let buttonImage = UIImage(systemName: buttonImageName)
        editStudentButton.setImage(buttonImage, for: .normal)
        
        // Выполняем анимацию изменения
        UIView.animate(withDuration: 0.3) {
            self.collectionView.reloadData() // Перезагружаем коллекцию для отображения изменений
        }
    }
    
    private func updateButtonsVisibility() {
        if viewModel.students.isEmpty {
            editStudentButton.isHidden = true
        } else {
            editStudentButton.isHidden = false
        }
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
            self?.navigationController?.pushViewController(studentCardVC, animated: true)
            self?.isEditingCells.toggle()
            self?.editStudentButton.setImage(UIImage(systemName: "pencil"), for: .normal)
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
        return [dragItem]
    }
}

// MARK: - UICollectionViewDropDelegate

extension StudentsCollectionViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else { return }
            
            collectionView.performBatchUpdates {
                let student = viewModel.students.remove(at: sourceIndexPath.item)
                viewModel.students.insert(student, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }
            coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
        }
        collectionView.reloadData()
        
        // Save the new order to the backend
        FirebaseManager.shared.saveStudentsOrder(viewModel.students) { error in
            if let error = error {
                print("Failed to save students order: \(error.localizedDescription)")
            } else {
                print("Successfully saved students order")
            }
        }
        
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
        guard indexPath.item < viewModel.students.count else {
            print("Invalid index path")
            return
        }
        
        // Remove the student from the local array and update collection view
        let studentToDelete = viewModel.students.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        
        // Delete from Firebase
        FirebaseManager.shared.deleteStudent(studentToDelete) { error in
            if let error = error {
                print("Ошибка при удалении студента из Firebase: \(error.localizedDescription)")
                // Можно добавить дополнительную логику обработки ошибки или уведомления пользователей здесь
            } else {
                print("Студент успешно удален из Firebase")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
