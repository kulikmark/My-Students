//
//  Student.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import Foundation
import FirebaseFirestore

enum StudentType: String, Codable {
    case schoolchild = "Schoolchild"
    case adult = "Adult"
}

struct Student:  Decodable {
    @DocumentID var id: String?
    var order: Int?
    var studentImageURL: String? = nil
    var type: StudentType = .schoolchild
    var name: String = ""
    var parentName: String = ""
    var phoneNumber: String = ""
    var lessonPrice: LessonPrice
    var schedule: [Schedule] = []
    
    var months: [Month] = []
    
    init(
        order: Int = .zero,
        studentImageURL: String? = nil,
        type: StudentType = .schoolchild,
        name: String = "",
        parentName: String = "",
        phoneNumber: String = "",
        lessonPrice: LessonPrice,
        schedule: [Schedule] = [],
        months: [Month] = []
    ) {
        self.order = order
        self.studentImageURL = studentImageURL
        self.type = type
        self.name = name
        self.parentName = parentName
        self.phoneNumber = phoneNumber
        self.lessonPrice = lessonPrice
        self.schedule = schedule
        self.months = months
    }
    
    // Преобразование данных для Firestore
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "order": order ?? 0,
            "type": type.rawValue,
            "name": name,
            "parentName": parentName,
            "phoneNumber": phoneNumber,
            "lessonPrice": lessonPrice.toFirestoreData(),
            "schedule": schedule.map { $0.toFirestoreData() },
            "months": months.map { $0.toFirestoreData() }
        ]
        
        if let imageUrl = studentImageURL {
            data["studentImageURL"] = imageUrl
        }
        
        return data
    }
}
