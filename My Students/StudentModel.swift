//
//  StudentModel.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import RealmSwift

enum StudentType: String, Codable {
    case schoolchild = "Schoolchild"
    case adult = "Adult"
}

class Student: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var parentName: String = ""
    @objc dynamic var imageForCellData: Data? = nil
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var lessonPrice: LessonPrice? = nil
    @objc dynamic var type: String = StudentType.schoolchild.rawValue
    let months = List<Month>()
    let lessons = List<Lesson>()
    let schedule = List<Schedule>()
    let photoUrls = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: UUID = UUID(),
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
        self.init()
        self.id = id.uuidString
        self.name = name
        self.parentName = parentName
        if let image = image {
            self.imageForCellData = image.pngData()
        }
        self.phoneNumber = phoneNumber
        self.months.append(objectsIn: months)
        self.lessons.append(objectsIn: lessons)
        self.lessonPrice = lessonPrice
        self.schedule.append(objectsIn: schedule)
        self.type = type.rawValue
        self.photoUrls.append(objectsIn: photoUrls.map { $0.absoluteString })
    }
}

class Schedule: Object {
    @objc dynamic var weekday: String = ""
    @objc dynamic var time: String = ""
}

class Month: Object {
    @objc dynamic var monthName: String = ""
    @objc dynamic var monthYear: String = ""
    @objc dynamic var isPaid: Bool = false
    @objc dynamic var lessonPrice: LessonPrice? = nil
    let lessons = List<Lesson>()
}

class LessonPrice: Object {
    @objc dynamic var price: Double = 0.0
    @objc dynamic var currency: String = ""
}

class Lesson: Object {
    @objc dynamic var date: String = ""
    @objc dynamic var attended: Bool = false
    @objc dynamic var homework: String? = nil
    let photoUrls = List<String>()
}
