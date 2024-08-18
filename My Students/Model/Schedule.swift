//
//  Schedule.swift
//  My Students
//
//  Created by Марк Кулик on 15.08.2024.
//

import Foundation

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
