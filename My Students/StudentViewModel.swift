//
//  StudentStore.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import Combine
import SwiftUI
import RealmSwift

//class StudentViewModel: ObservableObject {
//    @Published var students: [Student] = []
//    
//    func addStudent(_ student: Student) {
//        students.append(student)
//    }
//    
//    func updateStudent(_ updatedStudent: Student) {
//        if let index = students.firstIndex(where: { $0.id == updatedStudent.id }) {
//            students[index] = updatedStudent
//        }
//    }
//    
//    func removeStudent(at index: Int) {
//        students.remove(at: index)
//    }
//}

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []

    private var realm: Realm

    init() {
        do {
            realm = try Realm()
            fetchStudents()
        } catch let error as NSError {
            print("Failed to initialize Realm: \(error.localizedDescription)")
            realm = try! Realm(configuration: .defaultConfiguration)
        }
    }

    func fetchStudents() {
        let studentsResults = realm.objects(Student.self)
        students = Array(studentsResults)
    }

    func addStudent(_ student: Student) {
        do {
            try realm.write {
                realm.add(student)
            }
            fetchStudents()
        } catch {
            print("Failed to add student: \(error.localizedDescription)")
        }
    }

    func updateStudent(_ updatedStudent: Student) {
        do {
            try realm.write {
                realm.add(updatedStudent, update: .modified)
            }
            fetchStudents()
        } catch {
            print("Failed to update student: \(error.localizedDescription)")
        }
    }

    func removeStudent(at index: Int) {
        do {
            try realm.write {
                realm.delete(students[index])
            }
            fetchStudents()
        } catch {
            print("Failed to remove student: \(error.localizedDescription)")
        }
    }
}
