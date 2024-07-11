//
//  ContainerViewController.swift
//  My Students
//
//  Created by Марк Кулик on 11.07.2024.
//

import UIKit

class ContainerViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: StudentViewModel
    
    private var sideMenuWidth: CGFloat = 250 // Ширина бокового меню (можно настроить)
    private var sideMenuVisible = false
    
    private lazy var sideMenuViewController: SideMenuViewController = {
        let viewController = SideMenuViewController()
        viewController.delegate = self
        return viewController
    }()
    
    lazy var mainNavigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: StudentsCollectionViewController(viewModel: StudentViewModel()))
        return navigationController
    }()
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMenuBarButton()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(mainNavigationController.view)
        addChild(mainNavigationController)
        mainNavigationController.didMove(toParent: self)
        
        view.addSubview(sideMenuViewController.view)
        addChild(sideMenuViewController)
        sideMenuViewController.didMove(toParent: self)
        sideMenuViewController.view.frame = CGRect(x: -sideMenuWidth, y: 0, width: sideMenuWidth, height: view.bounds.height)
    }
    
    private func setupMenuBarButton() {
        
        let config = UIImage.SymbolConfiguration(pointSize: 25) // Установите нужный размер
        let menuImage = UIImage(systemName: "line.horizontal.3", withConfiguration: config)
        
        // Создаем UIButton и настраиваем его
        let menuButton = UIButton(type: .system)
        menuButton.setImage(menuImage, for: .normal)
        menuButton.tintColor = .darkGray
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        // Создаем UIBarButtonItem с кастомным видом
        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        mainNavigationController.topViewController?.navigationItem.leftBarButtonItem = menuBarButtonItem
    }
    
    
    // MARK: - Actions
    
    @objc private func menuButtonTapped() {
        toggleSideMenu()
    }
    
    
    // MARK: - Side Menu Handling
 
    private func toggleSideMenu() {
        print("Toggle side menu")
        sideMenuVisible = !sideMenuVisible
        
        UIView.animate(withDuration: 0.3) {
            // Сдвигаем основной контент вправо при открытии бокового меню
            self.mainNavigationController.view.frame.origin.x = self.sideMenuVisible ? self.sideMenuWidth : 0
            
            // Сдвигаем боковое меню вправо при открытии
            self.sideMenuViewController.view.frame.origin.x = self.sideMenuVisible ? 0 : -self.sideMenuWidth
            
            // Устанавливаем альфа-канал для затемнения основного экрана
            self.mainNavigationController.view.alpha = self.sideMenuVisible ? 0.5 : 1.0
        }
    }
}

// MARK: - SideMenuDelegate

extension ContainerViewController: SideMenuDelegate {
    func didSelectMenuItem(at index: Int) {
        // Implement logic for handling menu item selection here
        toggleSideMenu()
    }
    
    func toggleDarkMode() {
        // Логика для переключения темы
        let isDarkMode = UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = isDarkMode ? .light : .dark
        }
    }
    
//    func logout() {
//        LoginManager.shared.isLoggedIn = false
//        showLoginScreen()
//        toggleSideMenu()
//    }
    
//    private func showLoginScreen() {
//        let viewModel = StudentViewModel()
//        let loginVC = LoginViewController(viewModel: viewModel)
//        mainNavigationController.setViewControllers([loginVC], animated: true)
//    }
    
        func logout() {
            LoginManager.shared.isLoggedIn = false
            let loginVC = LoginViewController(viewModel: StudentViewModel())
            let navigationController = UINavigationController(rootViewController: loginVC)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
}
