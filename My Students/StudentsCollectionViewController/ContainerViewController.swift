//
//  ContainerViewController.swift
//  My Students
//
//  Created by Марк Кулик on 11.07.2024.
//

import UIKit

class ContainerViewController: UIViewController {

    // MARK: - Properties
    private let studentViewModel: StudentViewModel
    private var loginScreenViewModel: LoginScreenViewModel
    weak var coordinator: AppCoordinator?
    
    private lazy var sideMenuViewController: SideMenuViewController = {
        let viewController = SideMenuViewController()
        viewController.delegate = self
        viewController.coordinator = coordinator // Здесь передаем координатор
        return viewController
    }()
    
    private var sideMenuWidth: CGFloat = 250 // Ширина бокового меню (можно настроить)
    private var sideMenuVisible = false
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    lazy var mainNavigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: StudentsCollectionViewController(viewModel: StudentViewModel(), studentId: ""))
        navigationController.delegate = self
        return navigationController
    }()
    
    private var dimmingView: UIView?
    
    init(studentViewModel: StudentViewModel, loginScreenViewModel: LoginScreenViewModel, coordinator: AppCoordinator?) {
        self.studentViewModel = studentViewModel
        self.loginScreenViewModel = loginScreenViewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("ContainerViewController is being deallocated")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("ContainerViewController received a memory warning")
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
        
        // Initialize the dimming view
        dimmingView = UIView(frame: view.bounds)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView?.alpha = 0 // Start with hidden
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView?.addGestureRecognizer(tapGesture)
    }
    
    private func setupMenuBarButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let menuImage = UIImage(systemName: "line.horizontal.3", withConfiguration: config)
        
        let menuButton = UIButton(type: .system)
        menuButton.setImage(menuImage, for: .normal)
        menuButton.tintColor = .darkGray
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
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
    
    @objc private func dimmingViewTapped() {
        // Handle dimming view tap to close menu
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
                updateDimmingViewAlpha(for: newX / sideMenuWidth)
            } else { // Swiping left
                let newX = max(translation.x, -sideMenuWidth)
                mainNavigationController.view.frame.origin.x = sideMenuWidth + newX
                sideMenuViewController.view.frame.origin.x = newX
                updateDimmingViewAlpha(for: (sideMenuWidth + newX) / sideMenuWidth)
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
        UIView.animate(withDuration: 0.3, animations: {
            self.mainNavigationController.view.frame.origin.x = shouldOpen ? self.sideMenuWidth : 0
            self.sideMenuViewController.view.frame.origin.x = shouldOpen ? 0 : -self.sideMenuWidth
            
            // Add or remove the dimming view
            if shouldOpen {
                if let dimmingView = self.dimmingView {
                    self.mainNavigationController.view.addSubview(dimmingView)
                    dimmingView.alpha = 0.5
                }
            } else {
                self.dimmingView?.alpha = 0
                self.dimmingView?.removeFromSuperview()
            }
        })
    }
    
    private func updateDimmingViewAlpha(for fraction: CGFloat) {
        // Adjust the alpha of the dimming view based on the swipe distance
        dimmingView?.alpha = 0.5 * fraction
    }
}

// MARK: - UINavigationControllerDelegate

extension ContainerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is StudentsCollectionViewController {
            panGestureRecognizer.isEnabled = true
        } else {
            panGestureRecognizer.isEnabled = false
        }
    }
}

// MARK: - SideMenuDelegate

extension ContainerViewController: SideMenuDelegate {
    func didSelectMenuItem(at index: Int) {
        toggleSideMenu()
    }
    
    func toggleDarkMode() {
        let isDarkMode = UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = isDarkMode ? .light : .dark
        }
        sideMenuViewController.updateBackground(isDarkMode: !isDarkMode)
        toggleSideMenu()
    }
}
