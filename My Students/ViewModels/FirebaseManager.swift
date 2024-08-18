//
//  FirebaseManager.swift
//  My Students
//
//  Created by Марк Кулик on 06.07.2024.
//

import UIKit
import Combine
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
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        var studentRef: DocumentReference
        let userDocRef = db.collection("users").document(userId).collection("students")
        
        if let studentId = student.id {
            studentRef = userDocRef.document(studentId)
        } else {
            studentRef = userDocRef.document(UUID().uuidString)
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
    
    func saveStudentsOrder(_ students: [Student], completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let batch = db.batch()
        let userDocRef = db.collection("users").document(userId).collection("students")
        
        for (index, student) in students.enumerated() {
            guard let studentId = student.id else {
                completion(NSError(domain: "com.mystudents", code: 1, userInfo: [NSLocalizedDescriptionKey: "Student ID is missing"]))
                return
            }
            let studentRef = userDocRef.document(studentId)
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
        guard let userId = Auth.auth().currentUser?.uid,
              let studentId = student.id else {
            completion(NSError(domain: "com.mystudents", code: 1, userInfo: [NSLocalizedDescriptionKey: "Student ID or user ID is missing"]))
            return
        }
        
        let studentRef = db.collection("users").document(userId).collection("students").document(studentId)
        
        studentRef.delete { error in
            completion(error)
        }
    }
    
    // MARK: - Managing MonthsTableVC saving methods
    
    func updateMonthSum(for studentId: String, month: Month, totalAmount: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("students").document(studentId).getDocument { (document, error) in
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
                
                self.db.collection("users").document(userId).collection("students").document(studentId).setData(studentData, merge: true) { error in
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
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("students").document(studentId).getDocument { (document, error) in
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
            
            self.db.collection("users").document(userId).collection("students").document(studentId).setData(studentData, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func loadLessons(for studentId: String, month: Month, completion: @escaping (Result<[Lesson], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("students").document(studentId).getDocument { (document, error) in
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
    
    func deleteLesson(for studentId: String, month: Month, lessonId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("students").document(studentId).getDocument { (document, error) in
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
                
                if let lessonIndex = lessons.firstIndex(where: { ($0["id"] as? String) == lessonId }) {
                    lessons.remove(at: lessonIndex)
                    monthData["lessons"] = lessons
                    months[monthIndex] = monthData
                    studentData["months"] = months
                    
                    self.db.collection("users").document(userId).collection("students").document(studentId).setData(studentData, merge: true) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Lesson not found"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Month not found"])))
            }
        }
    }

    
    func deleteAllLessons(for studentId: String, month: Month, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("students").document(studentId).getDocument { (document, error) in
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
                
                self.db.collection("users").document(userId).collection("students").document(studentId).setData(studentData, merge: true) { error in
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
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("students").document(studentId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard var studentData = document?.data() else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Student not found"])))
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
                
                self.db.collection("users").document(userId).collection("students").document(studentId).setData(studentData, merge: true) { error in
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

    // Загрузка деталей урока из указанного месяца
    func loadLessonDetails(studentId: String, monthId: String, lessonId: String, completion: @escaping (Result<Lesson, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("students").document(studentId).getDocument { document, error in
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
    
    // MARK: - Managing Search History

    func fetchSearchHistory(completion: @escaping (Result<[SearchHistoryItem], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("searchHistory")
            .order(by: "timestamp", descending: true)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                // Convert documents to SearchHistoryItem
                let searchHistory: [SearchHistoryItem] = documents.compactMap { document in
                    let data = document.data()
                    
                    // Convert Firestore Timestamp to Date
                    guard let timestamp = data["timestamp"] as? Timestamp else { return nil }
                    let date = timestamp.dateValue()
                    
                    // Create SearchHistoryItem
                    return SearchHistoryItem(
                        id: data["id"] as? String ?? UUID().uuidString,
                        studentId: data["studentId"] as? String ?? "",
                        timestamp: date
                    )
                }
                
                completion(.success(searchHistory))
            }
    }

        
    func addSearchHistoryItem(for student: Student, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let searchHistoryItem = SearchHistoryItem(studentId: student.id ?? "", timestamp: Date())
        
        // Check for duplicates
        fetchSearchHistory { result in
            switch result {
            case .success(let historyItems):
                if historyItems.contains(where: { $0.studentId == student.id }) {
                    print("Student is already in search history.")
                    completion(.success(())) // or completion(.failure(someError)) if you want to indicate a duplicate
                    return
                }
                
                // Add new item
                self.db.collection("users").document(userId).collection("searchHistory")
                    .addDocument(data: searchHistoryItem.toFirestoreData()) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

        
        func clearSearchHistory(completion: @escaping (Result<Void, Error>) -> Void) {
            guard let userId = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            db.collection("users").document(userId).collection("searchHistory")
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        completion(.success(()))
                        return
                    }
                    
                    let batch = self.db.batch()
                    for document in documents {
                        batch.deleteDocument(document.reference)
                    }
                    batch.commit { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
        }
}
