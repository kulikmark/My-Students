//
//  StudentModel.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import Foundation
import FirebaseFirestore

// TODO: 1 File = 1 Enitity
// В одном файле может быть описан только один тип. Максимум тип и протокол и или тип и экстеншен к нему

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
    var lessonPrice: LessonPrice
    var schedule: [Schedule] = []
    
    var months: [Month] = []
//    var lessons: [Lesson] = []
//    var HWPhotos: [String] = []
    
    init(
        order: Int? = 0, // why optional if u initialize with default 0
                         // use '.zero' over '0'
                         //
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
    var timestamp: TimeInterval
    var monthName: String = ""
    var monthYear: String = ""
    var isPaid: Bool = false
    var paymentDate: String = ""
    var lessonPrice: LessonPrice? = nil
    var lessons: [Lesson] = []
    var moneySum: Int? = nil
    
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "timestamp": timestamp,
            "monthName": monthName,
            "monthYear": monthYear,
            "isPaid": isPaid,
            "paymentDate": paymentDate,
            "lessonPrice": lessonPrice?.toFirestoreData() ?? NSNull(),
            "lessons": lessons.map { $0.toFirestoreData() },
            "moneySum": moneySum ?? NSNull()
        ]
    }
    mutating func updateMoneySum(with lessons: [Lesson], lessonPrice: Int) {
           self.moneySum = lessons.count * lessonPrice
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
    var id: String
    var date: String
    var attended: Bool
    var homework: String?
    var HWPhotos: [String]
    var monthId: String
    
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "date": date,
            "attended": attended,
            "homework": homework ?? "",
            "HWPhotos": HWPhotos,
            "monthId": monthId
        ]
    }

    init(id: String, date: String, attended: Bool, homework: String?, HWPhotos: [String], monthId: String) {
        self.id = id
        self.date = date
        self.attended = attended
        self.homework = homework
        self.HWPhotos = HWPhotos
        self.monthId = monthId
    }
    
    init(fromFirestoreData data: [String: Any]) throws {
        guard
            let id = data["id"] as? String,
            let date = data["date"] as? String,
            let attended = data["attended"] as? Bool,
            let HWPhotos = data["HWPhotos"] as? [String],
            let monthId = data["monthId"] as? String
        else {
            throw NSError(domain: "com.mystudents", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])
        }
        
        self.id = id
        self.date = date
        self.attended = attended
        self.homework = data["homework"] as? String
        self.HWPhotos = HWPhotos
        self.monthId = monthId
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
