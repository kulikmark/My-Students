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

class StudentsCollectionViewController: UIViewController {
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    private var collectionView: UICollectionView!
    
    private var isEditingCells: Bool = false
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("students viewDidLoad StudentsCollectionViewController \(viewModel.students)")
        
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.collectionView.reloadData()
//                print("students in StudentsCollectionViewController: \(students)")
            }
            .store(in: &cancellables)
        
        view.backgroundColor = UIColor.systemGroupedBackground
        self.title = "Students List"
        
        setupCollectionView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewStudent))
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupStartScreenLabel(with: "Add first student \n\n Tap + in the left corner of the screen")
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createThreeColumnsFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(StudentCollectionViewCell.self, forCellWithReuseIdentifier: "StudentCell")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func createThreeColumnsFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 10
        let minimumItemSpacing: CGFloat = 15
        let availableWidth = width - (padding * 2) - minimumItemSpacing
        let itemWidth = availableWidth / 2
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5) // увеличиваем высоту для расписания
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.minimumInteritemSpacing = minimumItemSpacing
        flowLayout.minimumLineSpacing = minimumItemSpacing
        return flowLayout
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        isEditingCells = editing
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    @objc func addNewStudent() {
        let studentCardVC = StudentCardViewController(viewModel: viewModel, editMode: .add, delegate: self)
        navigationController?.pushViewController(studentCardVC, animated: true)
    }
}

extension StudentsCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditingCells {
            return
        }
        let studentCardVC = StudentCardViewController(viewModel: viewModel, editMode: .edit, delegate: self)
        let student = viewModel.students[indexPath.item]
        studentCardVC.student = student
        navigationController?.pushViewController(studentCardVC, animated: true)
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
        cell.configure(with: student, image: student.imageForCellData)
        cell.isEditing = isEditingCells
        cell.showDeleteConfirmation = { [weak self] in
            self?.showDeleteConfirmation(at: indexPath)
        }
        return cell
    }
}

// MARK: - StudentCardDelegate

extension StudentsCollectionViewController: StudentCardDelegate {
    func didSaveStudent() {
        collectionView.reloadData()
        setupStartScreenLabel(with: "Add first student \n\n Tap + in the left corner of the screen")
    }
}

// MARK: - Private Methods

extension StudentsCollectionViewController {
    
    func showDeleteConfirmation(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Confirm deletion", message: "Are you sure you want to delete this student?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteStudent(at: indexPath)
        }
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteStudent(at indexPath: IndexPath) {
        viewModel.removeStudent(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        setupStartScreenLabel(with: "Add first student \n\n Tap + in the left corner of the screen")
    }
}
