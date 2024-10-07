//
//  SideMenuViewController.swift
//  My Students
//
//  Created by Марк Кулик on 11.07.2024.
//

import UIKit
import FirebaseAuth
import SnapKit

protocol SideMenuDelegate: AnyObject {
    func didSelectMenuItem(at index: Int)
    func toggleDarkMode()
}

class SideMenuViewController: UIViewController {
    
    weak var delegate: SideMenuDelegate?
    weak var coordinator: AppCoordinator?
    
    let buttonPointSize: CGFloat = 23
    let buttonFontSize: CGFloat = 20
    
    private let userEmailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var darkModeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: buttonPointSize)
        let darkModeImage = UIImage(systemName: "moon.circle.fill", withConfiguration: config)
        
        button.setTitle(" Dark Mode", for: .normal)
        button.setImage(darkModeImage, for: .normal)
        button.tintColor = .darkGray
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        button.addTarget(self, action: #selector(darkModeButtonTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: buttonPointSize)
        let logoutImage = UIImage(systemName: "arrow.backward.to.line.circle.fill", withConfiguration: config)
        
        button.setTitle(" Log out", for: .normal)
        button.setImage(logoutImage, for: .normal)
        button.tintColor = .darkGray
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ViewColor")
        
        setupUI()
        updateUserEmailLabel()
    }
    
    private func setupUI() {
        view.addSubview(userEmailLabel)
        userEmailLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        view.addSubview(darkModeButton)
        darkModeButton.snp.makeConstraints { make in
            make.top.equalTo(userEmailLabel.snp.bottom).offset(40)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(30)
        }
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(darkModeButton.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(30)
        }
    }
    
    // MARK: - Background Update
    
    func updateBackground(isDarkMode: Bool = false) {
        if isDarkMode {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }
    
    // MARK: - Actions
    
    @objc private func darkModeButtonTapped() {
        delegate?.toggleDarkMode()
    }
    
    @objc private func logoutButtonTapped() {
        guard let coordinator = coordinator else {
            print("Coordinator is nil")
            return
        }
        coordinator.logout()
    }
    
    private func updateUserEmailLabel() {
        if let user = Auth.auth().currentUser {
            userEmailLabel.text = "Logged in as: \(user.email ?? "Unknown")"
        } else {
            userEmailLabel.text = "Not logged in"
        }
    }
}
