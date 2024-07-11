//
//  SideMenuViewController.swift
//  My Students
//
//  Created by Марк Кулик on 11.07.2024.
//

import UIKit

protocol SideMenuDelegate: AnyObject {
    func didSelectMenuItem(at index: Int)
    func toggleDarkMode()
    func logout()
}

class SideMenuViewController: UIViewController {
    
    weak var delegate: SideMenuDelegate?
    
    let buttonPointSize: CGFloat = 23
    let buttonFontSize: CGFloat = 20
    
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
        view.backgroundColor = .white // Настройте цвет фона по вашему желанию
        
        setupButtons()
    }
    
    private func setupButtons() {
        view.addSubview(darkModeButton)
        darkModeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(view.snp.leading).offset(30)
        }
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(darkModeButton.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).offset(30)
        }
    }
    
    // MARK: - Actions
    
    @objc private func darkModeButtonTapped() {
        delegate?.toggleDarkMode()
    }
    
    @objc private func logoutButtonTapped() {
        delegate?.logout()
    }
}
