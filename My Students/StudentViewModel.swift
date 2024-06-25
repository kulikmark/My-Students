//
//  StudentStore.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import Combine
import SwiftUI

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    
    func addStudent(_ student: Student) {
        students.append(student)
    }
    
    func updateStudent(_ updatedStudent: Student) {
        if let index = students.firstIndex(where: { $0.id == updatedStudent.id }) {
            students[index] = updatedStudent
        }
    }
    
    func removeStudent(at index: Int) {
        students.remove(at: index)
    }
}
