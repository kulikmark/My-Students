//
//  Lesson.swift
//  My Students
//
//  Created by Марк Кулик on 15.08.2024.
//

import Foundation

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
