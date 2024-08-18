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
    
    // Subjects for Combine
    let studentsSubject = PassthroughSubject<[Student], Never>()
    let searchHistorySubject = PassthroughSubject<[SearchHistoryItem], Never>()
    
    // Properties for storing data
    var students: [Student] = []
    var searchHistory: [SearchHistoryItem] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func start() {
        fetchStudents()
        fetchSearchHistory()
    }
    
    func resetData() {
        print("Resetting data in StudentViewModel")
        students.removeAll()
        studentsSubject.send([])
    }
    
    
    // MARK: - Managing Student FireBase methods
    
    func getStudentById(_ id: String) -> Student? {
        return students.first { $0.id == id }
    }
    
    func fetchStudents() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener = db.collection("users").document(userId).collection("students").order(by: "order").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            let students = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: Student.self)
            }
            
            self?.students = students
            self?.studentsSubject.send(students)
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
                self?.fetchStudents()
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
                    self?.fetchStudents()
                case .failure(let error):
                    print("Error deleting month: \(error)")
                }
            }
        }
    }
    
    func updatePaidStatus(for studentId: String, month: Month, isPaid: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard var student = getStudentById(studentId) else {
            completion(.failure(NSError(domain: "Student not found", code: 404, userInfo: nil)))
            return
        }
        
        if let index = student.months.firstIndex(where: { $0.id == month.id }) {
            student.months[index].isPaid = isPaid
            student.months[index].paymentDate = month.paymentDate
            
            FirebaseManager.shared.addOrUpdateStudent(student) { result in
                switch result {
                case .success:
                    self.fetchStudents()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(NSError(domain: "Month not found", code: 404, userInfo: nil)))
        }
    }
    
    
    func updateMonthSum(for studentId: String, month: Month, totalAmount: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        FirebaseManager.shared.updateMonthSum(for: studentId, month: month, totalAmount: totalAmount, completion: completion)
    }
    
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
            case .success:
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
    
    func fetchSearchHistory() {
           FirebaseManager.shared.fetchSearchHistory { [weak self] result in
               switch result {
               case .success(let searchHistory):
                   self?.searchHistory = searchHistory
                   self?.searchHistorySubject.send(searchHistory)
               case .failure(let error):
                   print("Error fetching search history: \(error)")
               }
           }
       }
       
       func addSearchHistoryItem(for student: Student) {
           FirebaseManager.shared.addSearchHistoryItem(for: student) { [weak self] result in
               switch result {
               case .success:
                   self?.fetchSearchHistory()
               case .failure(let error):
                   print("Error adding search history item: \(error)")
               }
           }
       }
       
       func clearSearchHistory() {
           FirebaseManager.shared.clearSearchHistory { [weak self] result in
               switch result {
               case .success:
                   self?.searchHistory.removeAll()
                   self?.searchHistorySubject.send(self?.searchHistory ?? [])
               case .failure(let error):
                   print("Error clearing search history: \(error)")
               }
           }
       }
}
