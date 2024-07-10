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
    private let imagesCache = NSCache<AnyObject, UIImage>()
    
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
    
    func loadImageFromURL(_ imageUrl: String, completion: @escaping (UIImage?) -> Void) {
        // Проверка кэша перед загрузкой изображения
              if let cachedImage = imagesCache.object(forKey: imageUrl as AnyObject) {
                  completion(cachedImage)
                  return
              }
        
           // Создаем ссылку на Firebase Storage по заданному URL изображения
           let storageRef = storage.reference(forURL: imageUrl)
           
           // Загружаем данные изображения
           storageRef.getData(maxSize: 1024 * 1024) { data, error in
               
               if let error = error {
                   print("Error loading image from Firebase Storage: \(error.localizedDescription)")
                   completion(nil)
               } else {
                   // Если данные получены успешно, преобразуем их в UIImage
                   if let data = data, let image = UIImage(data: data) {
                       completion(image)
                       // Кэшируем изображение
                        self.imagesCache.setObject(image, forKey: imageUrl as AnyObject)
                        completion(image)
                   } else {
                       // Если не удалось преобразовать данные в изображение
                       completion(nil)
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
    
//    func fetchStudents(completion: @escaping ([Student]?, Error?) -> Void) {
//        db.collection("students").getDocuments { snapshot, error in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//            
//            guard let snapshot = snapshot else {
//                completion([], nil)
//                return
//            }
//            
//            let students = snapshot.documents.compactMap { document -> Student? in
//                var data = document.data()
//                data["id"] = document.documentID
//                do {
//                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//                    let student = try JSONDecoder().decode(Student.self, from: jsonData)
//                    return student
//                } catch {
//                    print("Error decoding student: \(error)")
//                    return nil
//                }
//            }
//            
//            completion(students, nil)
//        }
//    }
}
