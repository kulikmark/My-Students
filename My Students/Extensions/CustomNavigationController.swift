//
//  CustomNavigationBar.swift
//  My Students
//
//  Created by Марк Кулик on 12.07.2024.
//

//import UIKit
//import SnapKit
//
//class CustomNavigationController: UINavigationController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Создание объекта UINavigationBarAppearance
//        let appearance = UINavigationBarAppearance()
//        
//        // Конфигурация внешнего вида для всех состояний
//        appearance.configureWithOpaqueBackground() // Или .configureWithTransparentBackground()
//        
//        // Настройка фонового цвета
//        appearance.backgroundColor = .white
//        
//        // Настройка атрибутов текста заголовка
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
//        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray]
//        
//        // Применение настроек к навигационному бару
//        navigationBar.standardAppearance = appearance
//        navigationBar.scrollEdgeAppearance = appearance
//        navigationBar.compactAppearance = appearance
//        
//        // Настройка цвета элементов навигационного бара
//        navigationBar.tintColor = .darkText
//        
//        // Отключение прозрачности
//        navigationBar.isTranslucent = false
//        
//        setupCustomTitleView()
//        
//            }
//            
//            private func setupCustomTitleView() {
//                // Создание контейнера для кнопки и поискового поля
//                let titleView = UIView()
//                
//                // Создание кнопки меню
//                let menuButton = UIButton(type: .system)
//                let config = UIImage.SymbolConfiguration(pointSize: 25)
//                let menuImage = UIImage(systemName: "line.horizontal.3", withConfiguration: config)
//                menuButton.setImage(menuImage, for: .normal)
//                menuButton.tintColor = .darkGray
//                menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
//                
//                // Создание поискового поля
//                let searchBar = UISearchBar()
//                searchBar.placeholder = "Search"
//                searchBar.searchBarStyle = .minimal
//                
//                // Добавление кнопки и поискового поля в контейнер
//                titleView.addSubview(menuButton)
//                titleView.addSubview(searchBar)
//                
//                // Настройка авторазметки с использованием SnapKit
//                menuButton.snp.makeConstraints { make in
//                    make.leading.equalTo(titleView.snp.leading)
//                    make.centerY.equalTo(titleView.snp.centerY)
//                }
//                
//                searchBar.snp.makeConstraints { make in
//                    make.leading.equalTo(menuButton.snp.trailing).offset(8)
//                    make.trailing.equalTo(titleView.snp.trailing)
//                    make.centerY.equalTo(titleView.snp.centerY)
//                }
//                
//                titleView.snp.makeConstraints { make in
//                    make.width.equalTo(UIScreen.main.bounds.width * 0.8)
//                    make.height.equalTo(44)
//                }
//                titleView.backgroundColor = .green
//                
//                navigationItem.titleView = titleView
//            }
//            
//            @objc private func menuButtonTapped() {
//
//            }
//        }
