//
//  MonthYearSelectionViewController.swift
//  My Students
//
//  Created by Марк Кулик on 26.07.2024.
//

import UIKit
import SnapKit

class MonthYearSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var existingMonths: [Month] = []
    
    private let collectionView: UICollectionView
    private let months: [String] = Calendar.current.monthSymbols
    private let years: [String]
    
    private let customStepper: UIView
    private let decrementButton: UIButton
    private let incrementButton: UIButton
    private let yearLabel: UILabel
    private let closeButton: UIButton
    
    var selectedMonth: String?
    var didSelectMonthYear: ((String, String) -> Void)?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        let currentYear = Calendar.current.component(.year, from: Date())
        years = (currentYear...currentYear + 10).map { "\($0)" }
        
        customStepper = UIView()
        decrementButton = UIButton(type: .system)
        incrementButton = UIButton(type: .system)
        yearLabel = UILabel()
        closeButton = UIButton(type: .custom)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MonthCell")
        
        setupCloseButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Select Month and Year"
        
        setupCollectionView()
        setupCustomStepper()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
        }
        
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MonthCell")
    }
    
    private func setupCustomStepper() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-60)
        }
        
        containerView.addSubview(customStepper)
        
        customStepper.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(230)
            make.height.equalTo(60)
            
        }
        
        customStepper.addSubview(decrementButton)
        customStepper.addSubview(yearLabel)
        customStepper.addSubview(incrementButton)
        
        decrementButton.snp.makeConstraints { make in
            make.leading.equalTo(customStepper.snp.leading)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        yearLabel.snp.makeConstraints { make in
            make.leading.equalTo(decrementButton.snp.trailing).offset(10)
            make.trailing.equalTo(incrementButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
        yearLabel.font = UIFont.systemFont(ofSize: 29, weight: .semibold)
        yearLabel.textColor = .darkGray
        
        incrementButton.snp.makeConstraints { make in
            make.trailing.equalTo(customStepper.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        decrementButton.setTitle("-", for: .normal)
        decrementButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        decrementButton.setTitleColor(.darkGray, for: .normal)
        decrementButton.backgroundColor = .white
        decrementButton.layer.borderColor = UIColor.systemBlue.cgColor
        decrementButton.layer.borderWidth = 1
        decrementButton.layer.cornerRadius = 15
        decrementButton.addTarget(self, action: #selector(decrementYear), for: .touchUpInside)
        
        incrementButton.setTitle("+", for: .normal)
        incrementButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        incrementButton.setTitleColor(.darkGray, for: .normal)
        incrementButton.backgroundColor = .white
        incrementButton.layer.borderColor = UIColor.systemBlue.cgColor
        incrementButton.layer.borderWidth = 1
        incrementButton.layer.cornerRadius = 15
        incrementButton.addTarget(self, action: #selector(incrementYear), for: .touchUpInside)
        
        yearLabel.textAlignment = .center
        yearLabel.textColor = .darkGray
        yearLabel.text = String(Calendar.current.component(.year, from: Date()))
    }
    
    private func setupCloseButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        let image = UIImage(systemName: "xmark.circle", withConfiguration: config)
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = .systemGray
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalTo(view.snp.trailing).offset(-10)
            make.width.height.equalTo(30)
        }
    }
    
    @objc private func decrementYear() {
        let currentYear = Int(yearLabel.text ?? "") ?? Calendar.current.component(.year, from: Date())
        let newYear = currentYear - 1
        if newYear >= Calendar.current.component(.year, from: Date()) - 1 {
            yearLabel.text = "\(newYear)"
        }
    }
    
    @objc private func incrementYear() {
        let currentYear = Int(yearLabel.text ?? "") ?? Calendar.current.component(.year, from: Date())
        let newYear = currentYear + 1
        if newYear <= Calendar.current.component(.year, from: Date()) + 10 {
            yearLabel.text = "\(newYear)"
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath)
        cell.backgroundColor = .systemBlue
//        cell.layer.borderColor = UIColor.systemBlue.cgColor
//        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 15
        
        let label = UILabel()
        label.textAlignment = .center
        label.frame = cell.contentView.frame
        label.textColor = .white
        label.text = months[indexPath.row]
        cell.contentView.addSubview(label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectedMonth = months[indexPath.row]
            if let month = selectedMonth {
                let selectedYear = yearLabel.text ?? ""
                
                // Check for duplicates
                if existingMonths.contains(where: { $0.monthName == month && $0.monthYear == selectedYear }) {
                    let errorAlert = UIAlertController(title: "Error", message: "This month and year already exist.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(errorAlert, animated: true, completion: nil)
                } else {
                    didSelectMonthYear?(month, selectedYear)
                    dismiss(animated: true)
                }
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2) - 20
        return CGSize(width: width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Расстояние между ячейками в строке
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20 // Расстояние между строками ячеек
    }
}
