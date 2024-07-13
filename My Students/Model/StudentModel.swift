//
//  StudentModel.swift
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

struct Student: Codable {
    @DocumentID var id: String?
    var order: Int?
    var studentImageURL: String? = nil
    var type: StudentType = .schoolchild
    var name: String = ""
    var parentName: String = ""
    var phoneNumber: String = ""
    var lessonPrice: LessonPrice? = nil
    var schedule: [Schedule] = []
    
    var months: [Month] = []
    var lessons: [Lesson] = []
    var photoUrls: [String] = []
    
     // Новое свойство для хранения порядка
    
    init(
        order: Int? = 0,
        studentImageURL: String? = nil,
        type: StudentType = .schoolchild,
        name: String = "",
        parentName: String = "",
        phoneNumber: String = "",
        lessonPrice: LessonPrice? = nil,
        schedule: [Schedule] = [],
        months: [Month] = [],
        lessons: [Lesson] = [],
        photoUrls: [URL] = []
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
        self.lessons = lessons
        self.photoUrls = photoUrls.map { $0.absoluteString }
    }
    
    // Преобразование данных для Firestore
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "order": order ?? 0,
            "type": type.rawValue,
            "name": name,
            "parentName": parentName,
            "phoneNumber": phoneNumber,
            "lessonPrice": lessonPrice?.toFirestoreData() ?? NSNull(),
            "schedule": schedule.map { $0.toFirestoreData() },
            "months": months.map { $0.toFirestoreData() },
            "lessons": lessons.map { $0.toFirestoreData() },
            "photoUrls": photoUrls
        ]
        
        // Добавление URL изображения, если он доступен
        if let imageUrl = studentImageURL {
            data["studentImageURL"] = imageUrl
        }
        
        return data
    }
}


struct Schedule: Codable {
    var id: String = UUID().uuidString
    var weekday: String = ""
    var time: String = ""
    
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "weekday": weekday,
            "time": time
        ]
    }
}

struct Month: Codable {
    var id: String = UUID().uuidString
    var monthName: String = ""
    var monthYear: String = ""
    var isPaid: Bool = false
    var lessonPrice: LessonPrice? = nil
    var lessons: [Lesson] = []
    
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "monthName": monthName,
            "monthYear": monthYear,
            "isPaid": isPaid,
            "lessonPrice": lessonPrice?.toFirestoreData() ?? NSNull(),
            "lessons": lessons.map { $0.toFirestoreData() }
        ]
    }
}

struct LessonPrice: Codable {
    var id: String = UUID().uuidString
    var price: Int = 0
    var currency: String = ""
    
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "price": price,
            "currency": currency
        ]
    }
}

struct Lesson: Codable {
    var id: String = UUID().uuidString
    var date: String = ""
    var attended: Bool = false
    var homework: String? = nil
    var photoUrls: [String] = []
    
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "date": date,
            "attended": attended,
            "homework": homework ?? NSNull(),
            "photoUrls": photoUrls
        ]
    }
}

struct SearchHistoryItem: Codable {
    var id: String = UUID().uuidString
    var studentId: String = ""
    var timestamp: Date = Date()
    
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "studentId": studentId,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}
