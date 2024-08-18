//
//  AppCoordinator.swift
//  My Students
//
//  Created by Марк Кулик on 17.08.2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var studentViewModel: StudentViewModel?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let studentViewModel = StudentViewModel()
        let loginScreenViewModel = LoginScreenViewModel(studentViewModel: studentViewModel)
        
        let loginVC = LoginViewController(studentViewModel: studentViewModel, loginScreenViewModel: loginScreenViewModel)
        loginVC.coordinator = self
        
        navigationController.setViewControllers([loginVC], animated: false)
    }
    
    func showContainerScreen() {
        let studentViewModel = StudentViewModel()
        let loginScreenViewModel = LoginScreenViewModel(studentViewModel: studentViewModel)
        
        let containerVC = ContainerViewController(studentViewModel: studentViewModel, loginScreenViewModel: loginScreenViewModel, coordinator: self)
        navigationController.setViewControllers([containerVC], animated: true)
    }
    
    func showForgotPasswordScreen() {
        let forgotPasswordVC = ForgotPasswordViewController()
        navigationController.present(forgotPasswordVC, animated: true)
    }
    
    func showLoginScreen() {
        let newStudentViewModel = StudentViewModel()
        let loginScreenViewModel = LoginScreenViewModel(studentViewModel: newStudentViewModel)
        
        let loginVC = LoginViewController(studentViewModel: newStudentViewModel, loginScreenViewModel: loginScreenViewModel)
        loginVC.coordinator = self
        
        navigationController.setViewControllers([loginVC], animated: true)
    }
    
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        studentViewModel?.resetData()
        
        LoginManager.shared.isLoggedIn = false
        showLoginScreen()
    }
}
