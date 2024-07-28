//  StudentStore.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine
import UserNotifications

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var searchHistory: [SearchHistoryItem] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchStudents()
        fetchSearchHistory()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Managing Student FireBase methods
    
    func getStudentById(_ id: String) -> Student? {
            return students.first { $0.id == id }
        }
    
    
    func fetchStudents() {
            listener = db.collection("students").order(by: "order").addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                self?.students = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Student.self)
                }
            }
        }

    // MARK: - Managing MonthsTableVC saving methods
    
    func addMonth(to student: Student, monthName: String, monthYear: String, lessonPrice: LessonPrice, moneySum: Int, timestamp: TimeInterval) {
        var updatedStudent = student
        let newMonth = Month(timestamp: timestamp, monthName: monthName, monthYear: monthYear, lessonPrice: lessonPrice, moneySum: moneySum)
        updatedStudent.months.append(newMonth)
        
        // Sort months by timestamp before saving
        updatedStudent.months.sort { $0.timestamp < $1.timestamp }
        
        FirebaseManager.shared.addOrUpdateStudent(updatedStudent) { [weak self] result in
            switch result {
            case .success:
                self?.fetchStudents() // Fetch the updated list of students
            case .failure(let error):
                print("Error adding month: \(error)")
            }
        }
    }
    
    func deleteMonth(for studentId: String, month: Month) {
        guard var student = getStudentById(studentId) else { return }
        
        if let index = student.months.firstIndex(where: { $0.id == month.id }) {
            student.months.remove(at: index)
            
            // Sort months by timestamp after deletion
            student.months.sort { $0.timestamp < $1.timestamp }
            
            FirebaseManager.shared.addOrUpdateStudent(student) { [weak self] result in
                switch result {
                case .success:
                    self?.fetchStudents() // Fetch the updated list of students
                case .failure(let error):
                    print("Error deleting month: \(error)")
                }
            }
        }
    }

    
    func updateMonthSum(for studentId: String, month: Month, totalAmount: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        FirebaseManager.shared.updateMonthSum(for: studentId, month: month, totalAmount: totalAmount, completion: completion)
    }
    
    func updatePaidStatus(for studentId: String, month: Month, isPaid: Bool) {
        guard var selectedStudent = getStudentById(studentId) else { return }
        
        if let index = selectedStudent.months.firstIndex(where: { $0.id == month.id }) {
            selectedStudent.months[index].isPaid = isPaid
            
            // Обновление в Firebase
            FirebaseManager.shared.addOrUpdateStudent(selectedStudent) { [weak self] result in
                switch result {
                case .success:
                    self?.fetchStudents() // Обновление списка студентов
                case .failure(let error):
                    print("Error updating paid status: \(error)")
                }
            }
        }
    }

    
    // trying to load lessons to catch lessonPrice.price
    func loadLessons(for studentId: String, month: Month) async throws -> [Lesson] {
            try await withCheckedThrowingContinuation { continuation in
                FirebaseManager.shared.loadLessons(for: studentId, month: month) { result in
                    continuation.resume(with: result)
                }
            }
        }
    
    func loadAllLessons(for studentId: String) async throws -> [String: [Lesson]] {
           guard let student = getStudentById(studentId) else { return [:] }
           var lessonsByMonth: [String: [Lesson]] = [:]
           
           for month in student.months {
               let lessons = try await loadLessons(for: studentId, month: month)
               lessonsByMonth[month.id] = lessons
           }
           
           return lessonsByMonth
       }
    
    // MARK: - Managing LessonsTablesVC saving methods
    
    func addOrUpdateStudent(_ student: Student, completion: @escaping (Result<Void, Error>) -> Void) {
            FirebaseManager.shared.addOrUpdateStudent(student) { result in
                switch result {
                case .success():
                    // Fetch the updated list of students
                    self.fetchStudents()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
    func saveLessons(for studentId: String, lessons: [Lesson], month: Month, completion: @escaping (Result<Void, Error>) -> Void) {
        FirebaseManager.shared.saveLessons(for: studentId, lessons: lessons, month: month, completion: completion)
        }

        func loadLessons(for studentId: String, month: Month, completion: @escaping (Result<[Lesson], Error>) -> Void) {
            FirebaseManager.shared.loadLessons(for: studentId, month: month, completion: completion)
        }
    
    func deleteAllLessons(for studentId: String, month: Month, completion: @escaping (Result<Void, Error>) -> Void) {
            FirebaseManager.shared.deleteAllLessons(for: studentId, month: month, completion: completion)
        }
        
        func deleteLesson(for studentId: String, month: Month, lessonId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            FirebaseManager.shared.deleteLesson(for: studentId, month: month, lessonId: lessonId, completion: completion)
        }
    
 // MARK: - Managing LessonDetailsVC saving methods
    
// methods for saving all data from LessonDetailsVC
        
    // MARK: - Managing SearchHistoryVC saving methods
    
    func fetchSearchHistory() {
        db.collection("searchHistory").order(by: "timestamp", descending: true).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching search history: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            
            self?.searchHistory = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: SearchHistoryItem.self)
            }
        }
    }
    
    func addSearchHistoryItem(for student: Student) {
        // Проверка на наличие дубликатов
        let existingHistoryItem = searchHistory.first { $0.studentId == student.id }
        guard existingHistoryItem == nil else {
            print("Student is already in search history.")
            return
        }
        
        let searchHistoryItem = SearchHistoryItem(studentId: student.id ?? "")
        db.collection("searchHistory").addDocument(data: searchHistoryItem.toFirestoreData()) { [weak self] error in
            if let error = error {
                print("Error adding search history item: \(error)")
            } else {
                self?.searchHistory.insert(searchHistoryItem, at: 0)
            }
        }
    }

    func clearSearchHistory() {
        db.collection("searchHistory").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching search history for deletion: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            
            let batch = self?.db.batch()
            for document in documents {
                batch?.deleteDocument(document.reference)
            }
            batch?.commit { error in
                if let error = error {
                    print("Error clearing search history: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self?.searchHistory.removeAll()
                    }
                }
            }
        }
    }
}
