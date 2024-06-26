//
//  StartScreenLabel.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//
import UIKit
import RealmSwift

extension UIViewController {
    
    // Метод для установки стартового экрана
    func setupStartScreenLabel(with message: String) {
        guard let collectionView = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView else { return }

        // Проверяем наличие данных в Realm для текущего контроллера
        let realm = try! Realm() // Ваш экземпляр Realm
        var isEmpty = true

        if self is StudentsCollectionViewController {
            isEmpty = realm.objects(Student.self).isEmpty
        }
        // Добавьте аналогичные проверки для других контроллеров, если они есть

        let startScreenLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        startScreenLabel.text = message
        startScreenLabel.font = UIFont.systemFont(ofSize: 17)
        startScreenLabel.textColor = .lightGray
        startScreenLabel.textAlignment = .center
        startScreenLabel.numberOfLines = 0
        collectionView.backgroundView = startScreenLabel
        startScreenLabel.isHidden = !isEmpty
    }

    
    // Метод для обновления видимости стартового экрана
    func updateStartScreenLabelVisibility(for collectionView: UICollectionView) {
        guard let startScreenLabel = collectionView.backgroundView as? UILabel else { return }

        let realm = try! Realm() // Ваш экземпляр Realm
        var isEmpty = true

        if self is StudentsCollectionViewController {
            isEmpty = realm.objects(Student.self).isEmpty
        }
        // Добавьте аналогичные проверки для других контроллеров, если они есть

        startScreenLabel.isHidden = !isEmpty
    }

        
        // Если у вас есть другие контроллеры, можно добавить аналогичные проверки для них:
        // else if let accountingController = self as? AccountingCollectionViewController {
        //     let isEmpty = accountingController.viewModel.students.isEmpty
        //     startScreenLabel.isHidden = !isEmpty
        // } else if let homeworkController = self as? HomeWorkCollectionViewController {
        //     let isEmpty = homeworkController.viewModel.students.isEmpty
        //     startScreenLabel.isHidden = !isEmpty
        // }
    }

