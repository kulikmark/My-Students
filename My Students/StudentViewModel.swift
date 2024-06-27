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

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []

     var realm: Realm

    init() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 2, // Увеличьте версию схемы
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 2 {
                        // Миграционные изменения, если они необходимы
                    }
                }
            )
            Realm.Configuration.defaultConfiguration = config

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
    
    func updateStudentImage(student: Student, image: UIImage) -> String? {
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            
            let filename = UUID().uuidString + ".jpg"
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            do {
                try data.write(to: fileURL)
                
                do {
                    try realm.write {
                        student.studentImage = fileURL.path
                    }
                    fetchStudents()
                } catch {
                    print("Failed to update student image path in Realm: \(error.localizedDescription)")
                    return nil
                }
                
                return fileURL.path
            } catch {
                print("Unable to save image to documents directory: \(error)")
                return nil
            }
        }
    }
