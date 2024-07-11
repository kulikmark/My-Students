//
//  SceneDelegate.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    var containerViewController: ContainerViewController?
    var viewModel = StudentViewModel()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
           
           guard let windowScene = (scene as? UIWindowScene) else { return }
           
           window = UIWindow(windowScene: windowScene)
           
           // Check dark mode setting from UserDefaults
           let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
           window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
           
           // Initialize ContainerViewController
        containerViewController = ContainerViewController(viewModel: viewModel)
        
        // Determine initial content based on login state
              if LoginManager.shared.isLoggedIn {
                  let containerVC = ContainerViewController(viewModel: viewModel)
                  navigationController = UINavigationController(rootViewController: containerVC)
              } else {
                  let loginVC = LoginViewController(viewModel: viewModel)
                  navigationController = UINavigationController(rootViewController: loginVC)
              }
           
           window?.rootViewController = navigationController
           window?.makeKeyAndVisible()
       }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

// ьфшт сщву
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//
//        window = UIWindow(windowScene: windowScene)
//
//        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
//                window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
//
//        let initialViewController: UIViewController
//
//        if LoginManager.shared.isLoggedIn {
//            let studentsVC = StudentsCollectionViewController(viewModel: studentViewModel)
//            initialViewController = UINavigationController(rootViewController: studentsVC)
//
//        } else {
//            let loginVC = LoginViewController(viewModel: studentViewModel)
//            initialViewController = UINavigationController(rootViewController: loginVC)
//        }
//
//        window?.rootViewController = initialViewController
//        window?.makeKeyAndVisible()
//    }






//        let studentsCollectionViewController = StudentsCollectionViewController(viewModel: studentsViewModel)
//        let accountingTableViewController = AccountingTableViewController()
//        let homeWorkTableViewController = HomeWorkTableViewController()
        
        
//        let studentsNavController = UINavigationController(rootViewController: studentsCollectionViewController)
//        let accountingNavController = UINavigationController(rootViewController: accountingTableViewController)
//        let homeWorkNavController = UINavigationController(rootViewController: homeWorkTableViewController)
        
        
//        let tabBarController = UITabBarController()
//        tabBarController.viewControllers = [studentsNavController/*, accountingNavController, homeWorkNavController*/]

// Setting colors for the active and inactive state of the tabbar text
//        let appearance = UITabBarItem.appearance()
//        appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
//        appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
//
        
//        if let studentsIcon = UIImage(named: "student_icon")?.withRenderingMode(.alwaysOriginal) {
//            studentsNavController.tabBarItem = UITabBarItem(title: "Students", image: studentsIcon, tag: 0)
//        }
        
//        if let accountingIcon = UIImage(named: "accounting_icon")?.withRenderingMode(.alwaysOriginal) {
//            accountingNavController.tabBarItem = UITabBarItem(title: "Accounting", image: accountingIcon, tag: 1)
//        }
//
//        if let homeworkIcon = UIImage(named: "homework_icon")?.withRenderingMode(.alwaysOriginal) {
//            homeWorkNavController.tabBarItem = UITabBarItem(title: "Homework", image: homeworkIcon, tag: 1)
//        }
