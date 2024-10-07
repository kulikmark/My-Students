//
//  StudentsTableViewController.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//


import UIKit
import Combine
import SnapKit

class StudentsCollectionViewController: UICollectionViewController {
    
    private var studentViewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    private var studentId: String
    
    private var allStudents: [Student] = []
    private var filteredStudents: [Student] = []
    private var isFilteringUnpaid: Bool = false
    
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
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        return button
    }()
    
    private lazy var whoPaidButton:  UIButton = {
        let button = UIButton(type: .system)
        //        button.tintColor = .white
        //        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.titleLabel?.numberOfLines = 1 // Ограничение на одну строку
        button.titleLabel?.lineBreakMode = .byTruncatingTail // Установка обрезки текста
        button.sizeToFit() // Установка размера кнопки в соответствии с её содержимым
        return button
    }()
    
    init(viewModel: StudentViewModel, studentId: String) {
        self.studentViewModel = viewModel
        self.studentId = studentId
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
        studentViewModel.fetchStudents()
        self.updateStartScreenLabel(with: "Add first student \n\n Tap + in the right corner of the screen", isEmpty: self.studentViewModel.students.isEmpty, collectionView: self.collectionView ?? UICollectionView())
        
        let currentMonth = getCurrentMonth()
        let unpaidCount = studentViewModel.unpaidStudentsCount(forMonth: currentMonth)
        
        if unpaidCount == 0 {
            isFilteringUnpaid = false
            filteredStudents = [] // Сброс фильтрации
        } else {
            filteredStudents = []
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentViewModel.start()
        setupCollectionView()
        setupSearchController()
        setupAddButton()
        setupWhoPaidButton()
        
        view.backgroundColor = UIColor.systemGroupedBackground
        self.title = "Students List"
        
        // Инициализация данных всех студентов
        allStudents = studentViewModel.students
        setupWhoPaidButton()
        
        // Subscribe to students updates
        studentViewModel.studentsSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.allStudents = students
                self?.collectionView.reloadData()
                self?.updateStartScreenLabel(with: "Add first student \n\n Tap + in the right corner of the screen", isEmpty: students.isEmpty, collectionView: self?.collectionView ?? UICollectionView())
                self?.updateWhoPaidButton()
            }
            .store(in: &cancellables)
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
        let studentCardVC = StudentCardViewController(viewModel: studentViewModel, editMode: .add)
        navigationController?.pushViewController(studentCardVC, animated: true)
    }
    
    func setupWhoPaidButton() {
        updateWhoPaidButton()
        
        whoPaidButton.addTarget(self, action: #selector(whoPaidButtonTapped), for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: whoPaidButton)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    // Метод для обновления кнопки и фильтрации учеников
    @objc func whoPaidButtonTapped() {
        isFilteringUnpaid.toggle()
        if isFilteringUnpaid {
            let currentMonth = getCurrentMonth()
            filteredStudents = studentViewModel.unpaidStudents(forMonth: currentMonth)
            collectionView.reloadData()
        } else {
            filteredStudents = []
            collectionView.reloadData()
        }
    }
    
    func updateWhoPaidButton() {
        let currentMonth = getCurrentMonth()
        let unpaidCount = studentViewModel.unpaidStudentsCount(forMonth: currentMonth)
        
        if unpaidCount == 0 {
            whoPaidButton.setTitle("All paid in \(currentMonth)", for: .normal)
            whoPaidButton.backgroundColor = .clear
            whoPaidButton.setTitleColor(.darkGray, for: .normal)
            whoPaidButton.isEnabled = false
        } else {
            whoPaidButton.setTitle("Unpaid: \(unpaidCount)", for: .normal)
            whoPaidButton.backgroundColor = .systemBlue
            whoPaidButton.setTitleColor(.white, for: .normal)
            whoPaidButton.isEnabled = true
        }
        
        whoPaidButton.sizeToFit()
    }
    
    func getCurrentMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: Date())
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
        let studentsSearchVC = StudentsSearchViewController(viewModel: self.studentViewModel)
        self.navigationController?.pushViewController(studentsSearchVC, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Implement your logic here if needed
    }
}

// MARK: - UICollectionViewDataSource

extension StudentsCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFilteringUnpaid ? filteredStudents.count : allStudents.count
    }
    
    // Настраиваем ячейку в зависимости от фильтрации
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudentCell", for: indexPath) as! StudentCollectionViewCell
        let student = isFilteringUnpaid ? filteredStudents[indexPath.item] : allStudents[indexPath.item]
        cell.configure(with: student)
        cell.delegate = self
        
        let studentBottomSheetVC = StudentCardBottomSheetViewController(student: student)
        studentBottomSheetVC.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Получаем выбранного студента в зависимости от состояния фильтрации
        let student = isFilteringUnpaid ? filteredStudents[indexPath.item] : allStudents[indexPath.item]
        
        // Создаем и отображаем контроллер для отображения месяцев
        let monthsTableVC = MonthsTableViewController(viewModel: self.studentViewModel, studentID: student.id ?? "")
        self.navigationController?.pushViewController(monthsTableVC, animated: true)
    }
    
    // Deleting student with the long tap
    //    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
    //        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
    //            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
    //                self.showDeleteConfirmation(at: indexPath)
    //            }
    //            return UIMenu(title: "", children: [deleteAction])
    //        }
    //        return configuration
    //    }
}

// MARK: - UICollectionViewDragDelegate

extension StudentsCollectionViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let student = studentViewModel.students[indexPath.item]
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
                let student = studentViewModel.students.remove(at: sourceIndexPath.item)
                studentViewModel.students.insert(student, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }
            coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
        }
        collectionView.reloadData()
        
        // Save the new order to the backend
        FirebaseManager.shared.saveStudentsOrder(studentViewModel.students) { error in
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

// MARK: - Deleting Student

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
        guard indexPath.item < studentViewModel.students.count else {
            print("Invalid index path")
            return
        }
        
        // Remove the student from the local array and update collection view
        let studentToDelete = studentViewModel.students.remove(at: indexPath.item)
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

// MARK: - Student Bottom Sheet methods

extension StudentsCollectionViewController: StudentCollectionViewCellDelegate {
    
    func presentStudentCardBottomSheet(for student: Student) {
        let studentBottomSheetVC = StudentCardBottomSheetViewController(student: student)
        studentBottomSheetVC.delegate = self
        studentBottomSheetVC.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = studentBottomSheetVC.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom(resolver: { context in
                        return 190
                    })]
                } else {
                    // Fallback on earlier versions
                }
                sheet.prefersGrabberVisible = true
            }
        }
        present(studentBottomSheetVC, animated: true, completion: nil)
    }
}

extension StudentsCollectionViewController: StudentBottomSheetDelegate {
    
    func didTapEditButton(for student: Student) {
        dismiss(animated: true) {
            let studentCardVC = StudentCardViewController(viewModel: self.studentViewModel, editMode: .edit)
            studentCardVC.student = student
            self.navigationController?.pushViewController(studentCardVC, animated: true)
        }
        
    }
    
    func didTapDeleteButton(for student: Student) {
        dismiss(animated: true) {
            if let indexPath = self.studentViewModel.students.firstIndex(where: { $0.id == student.id }) {
                self.showDeleteConfirmation(at: IndexPath(item: indexPath, section: 0))
                print("didTapDeleteButton")
                
            }
        }
    }
}
