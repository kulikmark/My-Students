//
//  ContainerViewController.swift
//  My Students
//
//  Created by Марк Кулик on 11.07.2024.
//

//import UIKit
//
//class ContainerViewController: UIViewController {
//    
//    // MARK: - Properties
//    private var viewModel: StudentViewModel
//    
//    private var sideMenuWidth: CGFloat = 250 // Ширина бокового меню (можно настроить)
//    private var sideMenuVisible = false
//    
//    private lazy var sideMenuViewController: SideMenuViewController = {
//        let viewController = SideMenuViewController()
//        viewController.delegate = self
//        return viewController
//    }()
//    
//    lazy var mainNavigationController: UINavigationController = {
//        let navigationController = UINavigationController(rootViewController: StudentsCollectionViewController(viewModel: StudentViewModel()))
//        return navigationController
//    }()
//    
//    init(viewModel: StudentViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//        setupMenuBarButton()
//    }
//    
//    // MARK: - Setup
//    
//    private func setupViews() {
//        view.addSubview(mainNavigationController.view)
//        addChild(mainNavigationController)
//        mainNavigationController.didMove(toParent: self)
//        
//        view.addSubview(sideMenuViewController.view)
//        addChild(sideMenuViewController)
//        sideMenuViewController.didMove(toParent: self)
//        sideMenuViewController.view.frame = CGRect(x: -sideMenuWidth, y: 0, width: sideMenuWidth, height: view.bounds.height)
//    }
//    
//    private func setupMenuBarButton() {
//        
//        let config = UIImage.SymbolConfiguration(pointSize: 25) // Установите нужный размер
//        let menuImage = UIImage(systemName: "line.horizontal.3", withConfiguration: config)
//        
//        // Создаем UIButton и настраиваем его
//        let menuButton = UIButton(type: .system)
//        menuButton.setImage(menuImage, for: .normal)
//        menuButton.tintColor = .darkGray
//        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
//        
//        // Создаем UIBarButtonItem с кастомным видом
//        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
//        mainNavigationController.topViewController?.navigationItem.leftBarButtonItem = menuBarButtonItem
//    }
//    
//    
//    // MARK: - Actions
//    
//    @objc private func menuButtonTapped() {
//        toggleSideMenu()
//    }
//    
//    
//    // MARK: - Side Menu Handling
// 
//    private func toggleSideMenu() {
//        print("Toggle side menu")
//        sideMenuVisible = !sideMenuVisible
//        
//        UIView.animate(withDuration: 0.3) {
//            // Сдвигаем основной контент вправо при открытии бокового меню
//            self.mainNavigationController.view.frame.origin.x = self.sideMenuVisible ? self.sideMenuWidth : 0
//            
//            // Сдвигаем боковое меню вправо при открытии
//            self.sideMenuViewController.view.frame.origin.x = self.sideMenuVisible ? 0 : -self.sideMenuWidth
//            
//            // Устанавливаем альфа-канал для затемнения основного экрана
//            self.mainNavigationController.view.alpha = self.sideMenuVisible ? 0.5 : 1.0
//        }
//    }
//}
//
//// MARK: - SideMenuDelegate
//
//extension ContainerViewController: SideMenuDelegate {
//    func didSelectMenuItem(at index: Int) {
//        // Implement logic for handling menu item selection here
//        toggleSideMenu()
//    }
//    
//    func toggleDarkMode() {
//        // Логика для переключения темы
//        let isDarkMode = UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark
//        UIApplication.shared.windows.forEach { window in
//            window.overrideUserInterfaceStyle = isDarkMode ? .light : .dark
//        }
//        toggleSideMenu()
//    }
//    
////    func logout() {
////        LoginManager.shared.isLoggedIn = false
////        showLoginScreen()
////        toggleSideMenu()
////    }
//    
////    private func showLoginScreen() {
////        let viewModel = StudentViewModel()
////        let loginVC = LoginViewController(viewModel: viewModel)
////        mainNavigationController.setViewControllers([loginVC], animated: true)
////    }
//    
//        func logout() {
//            LoginManager.shared.isLoggedIn = false
//            let loginVC = LoginViewController(viewModel: StudentViewModel())
//            let navigationController = UINavigationController(rootViewController: loginVC)
//            UIApplication.shared.windows.first?.rootViewController = navigationController
//            UIApplication.shared.windows.first?.makeKeyAndVisible()
//        }
//}


import UIKit

class ContainerViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: StudentViewModel
    
    private var sideMenuWidth: CGFloat = 250 // Ширина бокового меню (можно настроить)
    private var sideMenuVisible = false
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
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
        setupPanGesture()
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
    
    private func setupPanGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Actions
    
    @objc private func menuButtonTapped() {
        toggleSideMenu()
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        
        switch recognizer.state {
        case .changed:
            if translation.x > 0 { // Swiping right
                let newX = min(translation.x, sideMenuWidth)
                mainNavigationController.view.frame.origin.x = newX
                sideMenuViewController.view.frame.origin.x = newX - sideMenuWidth
            } else { // Swiping left
                let newX = max(translation.x, -sideMenuWidth)
                mainNavigationController.view.frame.origin.x = sideMenuWidth + newX
                sideMenuViewController.view.frame.origin.x = newX
            }
        case .ended:
            if velocity.x > 500 {
                showSideMenu()
            } else if velocity.x < -500 {
                hideSideMenu()
            } else {
                toggleSideMenu()
            }
        default:
            break
        }
    }
    
    // MARK: - Side Menu Handling
    
    private func toggleSideMenu() {
        sideMenuVisible = !sideMenuVisible
        animateSideMenu(shouldOpen: sideMenuVisible)
    }
    
    private func showSideMenu() {
        sideMenuVisible = true
        animateSideMenu(shouldOpen: true)
    }
    
    private func hideSideMenu() {
        sideMenuVisible = false
        animateSideMenu(shouldOpen: false)
    }
    
    private func animateSideMenu(shouldOpen: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.mainNavigationController.view.frame.origin.x = shouldOpen ? self.sideMenuWidth : 0
            self.sideMenuViewController.view.frame.origin.x = shouldOpen ? 0 : -self.sideMenuWidth
            self.mainNavigationController.view.alpha = shouldOpen ? 0.5 : 1.0
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
        toggleSideMenu()
    }
    
    func logout() {
        LoginManager.shared.isLoggedIn = false
        let loginVC = LoginViewController(viewModel: StudentViewModel())
        let navigationController = UINavigationController(rootViewController: loginVC)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
