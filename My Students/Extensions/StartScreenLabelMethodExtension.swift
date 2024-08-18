//
//  StartScreenLabel.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//
import UIKit
import Firebase
import FirebaseFirestore

extension UIViewController {
    func setupStartScreenLabel(with message: String) {
        guard let collectionView = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView else { return }

        let db = Firestore.firestore()
        var isEmpty = true

        if self is StudentsCollectionViewController {
            let studentsRef = db.collection("students")
            studentsRef.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching students: \(error.localizedDescription)")
                    return
                }

                isEmpty = snapshot?.documents.isEmpty ?? true
                DispatchQueue.main.async {
                    self.updateStartScreenLabel(with: message, isEmpty: isEmpty, collectionView: collectionView)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.updateStartScreenLabel(with: message, isEmpty: isEmpty, collectionView: collectionView)
            }
        }
    }

     func updateStartScreenLabel(with message: String, isEmpty: Bool, collectionView: UICollectionView) {
        let startScreenLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        startScreenLabel.text = message
        startScreenLabel.font = UIFont.systemFont(ofSize: 17)
        startScreenLabel.textColor = .lightGray
        startScreenLabel.textAlignment = .center
        startScreenLabel.numberOfLines = 0
        collectionView.backgroundView = startScreenLabel
        startScreenLabel.isHidden = !isEmpty
    }
}
