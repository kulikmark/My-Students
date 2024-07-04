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
    let searchController = UISearchController(searchResultsController: nil)
    var studentsTableView: UITableView!
    
    private var searchHistory = [Student]()
    
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
        
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.studentsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$searchHistory
            .receive(on: RunLoop.main)
            .sink { [weak self] history in
                self?.searchHistory = history
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
//            make.edges.equalToSuperview()
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
            searchHistory = viewModel.searchHistory
        } else {
            searchHistory = viewModel.students.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            //Ша we want to save history search but it's not so cool
//            if let foundStudent = searchHistory.first {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                   self.viewModel.addSearchHistoryItem(for: foundStudent)
//                                   self.studentsTableView.reloadData()
//                               }
//                           }
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
        return searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentSearchHistoryTableViewCell
        let student = searchHistory[indexPath.row]
        cell.configure(with: student)
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
        let student = searchHistory[indexPath.row]
        viewModel.addSearchHistoryItem(for: student)
        let monthsVC = MonthsTableViewController()
        monthsVC.student = student
        navigationController?.pushViewController(monthsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SearchHistoryHeaderView(viewModel: viewModel)
        headerView.configure(with: viewModel.students, delegate: self)
        return headerView
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 140 // Высота для хедера с коллекцией
    }
}

// MARK: - StudentsTableViewHeaderDelegate

extension StudentsSearchViewController: StudentsTableViewHeaderDelegate {
    func clearSearchHistory() {
        viewModel.clearSearchHistory()
        studentsTableView.reloadData()
    }
    
    func navigateToMonths(for student: Student) {
        let monthsVC = MonthsTableViewController()
        monthsVC.student = student
        navigationController?.pushViewController(monthsVC, animated: true)
    }
}


protocol StudentsTableViewHeaderDelegate: AnyObject {
    func clearSearchHistory()
    func navigateToMonths(for student: Student)
}

import UIKit

class SearchHistoryHeaderView: UITableViewHeaderFooterView, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    var students = [Student]()
    weak var delegate: StudentsTableViewHeaderDelegate?
    var viewModel: StudentViewModel  // Добавлено свойство viewModel
    
    let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        return button
    }()
    
    // Конструктор, принимающий viewModel
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(reuseIdentifier: "SearchHistoryHeaderView")
        setupCollectionView()
        setupClearButton()
        configure(with: viewModel.students, delegate: nil) // Используем viewModel для конфигурации
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 95)
        layout.minimumLineSpacing = 10
        let padding: CGFloat = 10
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemGray6
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(StudentSearchCollectionViewCell.self, forCellWithReuseIdentifier: "SearchHistoryCell")
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(100)
            
        }
    }
    
    private func setupClearButton() {
        contentView.addSubview(clearButton)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        clearButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(10)
            make.width.equalTo(50)
            make.height.equalTo(20)
        }
        updateClearButtonVisibility()
    }
        
    func configure(with students: [Student], delegate: StudentsTableViewHeaderDelegate?) {
        self.students = students
        self.delegate = delegate
        collectionView.reloadData()
        updateClearButtonVisibility()
    }
        
    private func updateClearButtonVisibility() {
        clearButton.isHidden = viewModel.searchHistory.isEmpty
    }
        
    @objc private func clearButtonTapped() {
        delegate?.clearSearchHistory()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return students.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchHistoryCell", for: indexPath) as! StudentSearchCollectionViewCell
        let student = students[indexPath.item]
        cell.configure(with: student)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let student = students[indexPath.item]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel.addSearchHistoryItem(for: student)
        }
        delegate?.navigateToMonths(for: student)
    }
}

import UIKit

class StudentSearchCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with student: Student) {
        if let image = UIImage(contentsOfFile: student.studentImage) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "defaultImage")
        }
        nameLabel.text = student.name
    }
}

import UIKit
import SnapKit

class StudentSearchHistoryTableViewCell: UITableViewCell {
    
    var student: Student?
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    let studentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let studentNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    let studentClassLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        contentView.addSubview(containerView)
        containerView.addSubview(studentImageView)
        containerView.addSubview(studentNameLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalTo(80)
        }
        
        studentImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(50)
        }
        
        studentNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(studentImageView.snp.right).offset(10)
        }
    }
    
    func configure(with student: Student) {
        self.student = student
        studentNameLabel.text = student.name
        
        if let image = UIImage(contentsOfFile: student.studentImage) {
            studentImageView.image = image
        } else {
            studentImageView.image = UIImage(named: "defaultImage")
        }
    }
}
