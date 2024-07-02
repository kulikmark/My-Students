//
//  StartScreenLabel.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//
import UIKit
import RealmSwift

extension UIViewController {
    func setupStartScreenLabel(with message: String) {
        guard let collectionView = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView else { return }
        
        let realm = try! Realm()
        var isEmpty = true
        
        if self is StudentsCollectionViewController {
            isEmpty = realm.objects(Student.self).isEmpty
        }
        
        let startScreenLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        startScreenLabel.text = message
        startScreenLabel.font = UIFont.systemFont(ofSize: 17)
        startScreenLabel.textColor = .lightGray
        startScreenLabel.textAlignment = .center
        startScreenLabel.numberOfLines = 0
        collectionView.backgroundView = startScreenLabel
        startScreenLabel.isHidden = !isEmpty
    }
    
    func updateStartScreenLabelVisibility(for collectionView: UICollectionView?) {
        guard let collectionView = collectionView,
              let startScreenLabel = collectionView.backgroundView as? UILabel else { return }
        
        let realm = try! Realm()
        var isEmpty = true
        
        if self is StudentsCollectionViewController {
            isEmpty = realm.objects(Student.self).isEmpty
        }
        
        startScreenLabel.isHidden = !isEmpty
    }
}

//import RealmSwift
//import UIKit
//
//extension UIViewController {
//    func setupStartScreenLabel(with message: String) {
//        guard let collectionView = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView else { return }
//        
//        let startScreenLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
//        startScreenLabel.text = message
//        startScreenLabel.font = UIFont.systemFont(ofSize: 17)
//        startScreenLabel.textColor = .lightGray
//        startScreenLabel.textAlignment = .center
//        startScreenLabel.numberOfLines = 0
//        collectionView.backgroundView = startScreenLabel
//        startScreenLabel.isHidden = true // Initially hidden, visibility is updated later
//    }
//    
//    func updateStartScreenLabelVisibility(for collectionView: UICollectionView?) {
//        guard let collectionView = collectionView,
//              let startScreenLabel = collectionView.backgroundView as? UILabel else { return }
//        
//        let realm = try! Realm()
//        let isEmpty = realm.objects(Student.self).isEmpty
//        startScreenLabel.isHidden = !isEmpty
//        
//        // Show or hide the search bar based on whether there are students
//                if let searchController = (self as? StudentsCollectionViewController)?.searchController {
//                    searchController.searchBar.isHidden = isEmpty
//                }
//            }
//        }
//