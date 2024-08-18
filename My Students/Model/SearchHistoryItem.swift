//
//  SearchHistoryItem.swift
//  My Students
//
//  Created by Марк Кулик on 15.08.2024.
//

import Foundation
import FirebaseFirestore

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
