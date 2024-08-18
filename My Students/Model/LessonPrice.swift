//
//  LessonPrice.swift
//  My Students
//
//  Created by Марк Кулик on 15.08.2024.
//

import Foundation

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
