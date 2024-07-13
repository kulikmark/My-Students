//
//  FirebaseManager.swift
//  My Students
//
//  Created by Марк Кулик on 06.07.2024.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    func addOrUpdateStudent(_ student: Student, completion: @escaping (Error?) -> Void) {
        var studentRef: DocumentReference
        
        if let studentId = student.id {
            studentRef = db.collection("students").document(studentId)
        } else {
            studentRef = db.collection("students").document(UUID().uuidString)
        }
        
        var data = student.toFirestoreData()
        
        if student.id == nil {
            data["id"] = studentRef.documentID
        }
        
        studentRef.setData(data, merge: true) { error in
            if let error = error {
                print("Ошибка при добавлении или обновлении студента: \(error.localizedDescription)")
            } else {
                print("Студент успешно добавлен или обновлен.")
            }
            completion(error)
        }
    }
    
    func fetchStudents(completion: @escaping (Result<[Student], Error>) -> Void) {
        db.collection("students").order(by: "order").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let students = querySnapshot?.documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Student.self)
                } ?? []
                completion(.success(students))
            }
        }
    }
    
    func saveStudentsOrder(_ students: [Student], completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        
        for (index, student) in students.enumerated() {
            guard let studentId = student.id else {
                completion(NSError(domain: "com.mystudents", code: 1, userInfo: [NSLocalizedDescriptionKey: "Student ID is missing"]))
                return
            }
            let studentRef = db.collection("students").document(studentId)
            batch.updateData(["order": index], forDocument: studentRef)
        }
        
        batch.commit { error in
            completion(error)
        }
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
           guard let imageData = image.jpegData(compressionQuality: 0.8) else {
               completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
               return
           }
           
           let imageRef = storage.reference().child("student_images/\(UUID().uuidString).jpg")
           
           let metadata = StorageMetadata()
           metadata.contentType = "image/jpeg"
           
           imageRef.putData(imageData, metadata: metadata) { metadata, error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   imageRef.downloadURL { url, error in
                       if let error = error {
                           completion(.failure(error))
                       } else if let url = url {
                           completion(.success(url.absoluteString))
                       } else {
                           completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                       }
                   }
               }
           }
       }

    func deleteStudent(_ student: Student, completion: @escaping (Error?) -> Void) {
        guard let studentId = student.id else {
            completion(NSError(domain: "com.mystudents", code: 1, userInfo: [NSLocalizedDescriptionKey: "Student ID is missing"]))
            return
        }
        
        let studentRef = db.collection("students").document(studentId)
        
        studentRef.delete { error in
            completion(error)
        }
    }

    func fetchSearchHistory(completion: @escaping (Result<[SearchHistoryItem], Error>) -> Void) {
        db.collection("searchHistory").order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let searchHistory = querySnapshot?.documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: SearchHistoryItem.self)
                } ?? []
                completion(.success(searchHistory))
            }
        }
    }

    func addSearchHistoryItem(_ searchHistoryItem: SearchHistoryItem, completion: @escaping (Error?) -> Void) {
        db.collection("searchHistory").addDocument(data: searchHistoryItem.toFirestoreData()) { error in
            completion(error)
        }
    }

    func clearSearchHistory(completion: @escaping (Error?) -> Void) {
        db.collection("searchHistory").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
            } else {
                let batch = self.db.batch()
                querySnapshot?.documents.forEach { batch.deleteDocument($0.reference) }
                batch.commit(completion: completion)
            }
        }
    }
}
