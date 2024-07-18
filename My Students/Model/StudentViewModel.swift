//  StudentStore.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine

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
    
    func getStudentById(_ id: String) -> Student? {
            return students.first { $0.id == id }
        }
    
    func addMonth(to student: Student, monthName: String, monthYear: String) {
            var updatedStudent = student
            let newMonth = Month(monthName: monthName, monthYear: monthYear)
            updatedStudent.months.append(newMonth)

            guard let studentId = student.id else { return }

            db.collection("students").document(studentId).setData(updatedStudent.toFirestoreData()) { error in
                if let error = error {
                    print("Error adding month: \(error)")
                } else {
                    self.fetchStudents() // Fetch the updated list of students
                }
            }
        }
    
    // Пример метода для удаления месяца
        func deleteMonth(for studentId: String, at index: Int) {
            guard let studentIndex = students.firstIndex(where: { $0.id == studentId }) else { return }
            students[studentIndex].months.remove(at: index)
        }
        
        // Пример метода для изменения статуса оплаты месяца
        func updatePaidStatus(for studentId: String, at index: Int, isPaid: Bool) {
            guard let studentIndex = students.firstIndex(where: { $0.id == studentId }) else { return }
            students[studentIndex].months[index].isPaid = isPaid
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
