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
    let storage = Storage.storage()
    
    private init() {}
    
    // MARK: - Managing Student FireBase methods
    
    func addOrUpdateStudent(_ student: Student, completion: @escaping (Result<Void, Error>) -> Void) {
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
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
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
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
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
    
    // MARK: - Managing MonthsTableVC saving methods
    
    func updateMonthSum(for studentId: String, month: Month, totalAmount: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("students").document(studentId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard var studentData = document?.data() else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Student not found"])))
                return
            }
            
            var months = studentData["months"] as? [[String: Any]] ?? []
            if let monthIndex = months.firstIndex(where: { ($0["id"] as? String) == month.id }) {
                months[monthIndex]["moneySum"] = totalAmount
                studentData["months"] = months
                
                self.db.collection("students").document(studentId).setData(studentData, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Month not found"])))
            }
        }
    }

    // MARK: - Managing LessonsTableVC saving methods
    
    func saveLessons(for studentId: String, lessons: [Lesson], month: Month, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("students").document(studentId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard var studentData = document?.data() else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Student not found"])))
                return
            }
            
            var months = studentData["months"] as? [[String: Any]] ?? []
            if let monthIndex = months.firstIndex(where: { ($0["id"] as? String) == month.id }) {
                months[monthIndex]["lessons"] = lessons.map { $0.toFirestoreData() }
            } else {
                var newMonth = month.toFirestoreData()
                newMonth["lessons"] = lessons.map { $0.toFirestoreData() }
                months.append(newMonth)
            }
            
            studentData["months"] = months
            
            self.db.collection("students").document(studentId).setData(studentData, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func loadLessons(for studentId: String, month: Month, completion: @escaping (Result<[Lesson], Error>) -> Void) {
        db.collection("students").document(studentId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = document?.data(),
                  let monthsData = data["months"] as? [[String: Any]],
                  let monthData = monthsData.first(where: { ($0["id"] as? String) == month.id }),
                  let lessonsData = monthData["lessons"] as? [[String: Any]] else {
                completion(.success([]))
                return
            }
            
            let lessons = lessonsData.compactMap { try? Lesson(fromFirestoreData: $0) }
            completion(.success(lessons))
        }
    }
    
    // Удаление одного урока
       func deleteLesson(for studentId: String, month: Month, lessonId: String, completion: @escaping (Result<Void, Error>) -> Void) {
           db.collection("students").document(studentId).getDocument { (document, error) in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               guard var studentData = document?.data() else {
                   completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Student not found"])))
                   return
               }
               
               var months = studentData["months"] as? [[String: Any]] ?? []
               if let monthIndex = months.firstIndex(where: { ($0["id"] as? String) == month.id }) {
                   var monthData = months[monthIndex]
                   var lessons = monthData["lessons"] as? [[String: Any]] ?? []
                   lessons.removeAll { ($0["id"] as? String) == lessonId }
                   monthData["lessons"] = lessons
                   months[monthIndex] = monthData
                   studentData["months"] = months
                   
                   self.db.collection("students").document(studentId).setData(studentData, merge: true) { error in
                       if let error = error {
                           completion(.failure(error))
                       } else {
                           completion(.success(()))
                       }
                   }
               } else {
                   completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Month not found"])))
               }
           }
       }
    
    // Удаление всех уроков для месяца
       func deleteAllLessons(for studentId: String, month: Month, completion: @escaping (Result<Void, Error>) -> Void) {
           db.collection("students").document(studentId).getDocument { (document, error) in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               guard var studentData = document?.data() else {
                   completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Student not found"])))
                   return
               }
               
               var months = studentData["months"] as? [[String: Any]] ?? []
               if let monthIndex = months.firstIndex(where: { ($0["id"] as? String) == month.id }) {
                   var monthData = months[monthIndex]
                   monthData["lessons"] = [] // Очистка всех уроков
                   months[monthIndex] = monthData
                   studentData["months"] = months
                   
                   self.db.collection("students").document(studentId).setData(studentData, merge: true) { error in
                       if let error = error {
                           completion(.failure(error))
                       } else {
                           completion(.success(()))
                       }
                   }
               } else {
                   completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Month not found"])))
               }
           }
       }
    
    // MARK: - Managing LessonDetailsVC saving methods
    
    func saveLessonDetails(studentId: String, monthId: String, lesson: Lesson, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("students").document(studentId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard var studentData = document?.data() else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Студент не найден"])))
                return
            }
            
            var months = studentData["months"] as? [[String: Any]] ?? []
            if let monthIndex = months.firstIndex(where: { ($0["id"] as? String) == monthId }) {
                var monthData = months[monthIndex]
                var lessons = monthData["lessons"] as? [[String: Any]] ?? []
                if let lessonIndex = lessons.firstIndex(where: { ($0["id"] as? String) == lesson.id }) {
                    lessons[lessonIndex] = lesson.toFirestoreData()
                } else {
                    lessons.append(lesson.toFirestoreData())
                }
                monthData["lessons"] = lessons
                months[monthIndex] = monthData
                studentData["months"] = months
                
                self.db.collection("students").document(studentId).setData(studentData, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Месяц не найден"])))
            }
        }
    }

    // Загрузка деталей урока из указанного месяца
    func loadLessonDetails(studentId: String, monthId: String, lessonId: String, completion: @escaping (Result<Lesson, Error>) -> Void) {
        db.collection("students").document(studentId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = document?.data(),
                  let monthsData = data["months"] as? [[String: Any]],
                  let monthData = monthsData.first(where: { ($0["id"] as? String) == monthId }),
                  let lessonsData = monthData["lessons"] as? [[String: Any]] else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Lesson not found"])))
                return
            }
            
            if let lessonData = lessonsData.first(where: { ($0["id"] as? String) == lessonId }) {
                do {
                    let lesson = try Lesson(fromFirestoreData: lessonData)
                    completion(.success(lesson))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Lesson not found"])))
            }
        }
    }
    
    // MARK: - Managing SearchHistoryVC saving methods
    
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
