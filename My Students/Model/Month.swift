//
//  Month.swift
//  My Students
//
//  Created by Марк Кулик on 15.08.2024.
//

import Foundation

struct Month: Codable {
    var id: String = UUID().uuidString
    var timestamp: TimeInterval
    var monthName: String = ""
    var monthYear: String = ""
    var isPaid: Bool = false
    var paymentDate: String = ""
    var lessonPrice: LessonPrice? = nil
    var lessons: [Lesson] = []
    var moneySum: Int = .zero
    
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
            "moneySum": moneySum
        ]
    }
    mutating func updateMoneySum(with lessons: [Lesson], lessonPrice: Int) {
           self.moneySum = lessons.count * lessonPrice
       }
}
