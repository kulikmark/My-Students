//
//  StudentModel.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit

enum StudentType: String, Codable {
    case schoolchild = "Schoolchild"
    case adult = "Adult"
}

class Student {
    var id: UUID
    var name: String
    var parentName: String
    var imageForCell: UIImage?
    var phoneNumber: String
    var months: [Month]
    var lessons: [Lesson]
    var lessonPrice: LessonPrice
    var schedule: [Schedule]
    var type: StudentType
    var photoUrls: [URL]

    init(id: UUID = UUID(),
         name: String,
         parentName: String,
         phoneNumber: String,
         months: [Month],
         lessons: [Lesson],
         lessonPrice: LessonPrice,
         schedule: [Schedule],
         type: StudentType,
         image: UIImage? = nil,
         photoUrls: [URL] = []) {

        self.id = id
        self.name = name
        self.parentName = parentName
        self.imageForCell = image
        self.phoneNumber = phoneNumber
        self.months = months
        self.lessons = lessons
        self.lessonPrice = lessonPrice
        self.schedule = schedule
        self.type = type
        self.photoUrls = photoUrls
    }
}

struct Schedule {
    var weekday: String
    var time: String
}

struct Month: Equatable {
    static func == (lhs: Month, rhs: Month) -> Bool {
        return lhs.monthName == rhs.monthName && lhs.monthYear == rhs.monthYear && lhs.isPaid == rhs.isPaid
    }
    
    var monthName: String
    var monthYear: String
    var isPaid: Bool
    var lessonPrice: LessonPrice
    var lessons: [Lesson]
}

struct LessonPrice {
    var price: Double
    var currency: String
}

struct Lesson: Codable {
    var date: String
    var attended: Bool
    var homework: String?
    var photoUrls: [URL]
}
