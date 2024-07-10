//
//  SearchHistoryHeaderView.swift
//  My Students
//
//  Created by Марк Кулик on 09.07.2024.
//

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

