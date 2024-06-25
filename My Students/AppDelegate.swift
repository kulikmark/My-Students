//
//  AppDelegate.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import Combine
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var studentViewModel = StudentViewModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Создаем тестовое расписание для ученика
        let testSchedule1 = [
            Schedule(weekday: "MON", time: "15:00"),
            Schedule(weekday: "TUE", time: "15:00"),
            Schedule(weekday: "WED", time: "15:00"),
            Schedule(weekday: "THU", time: "15:00"),
            Schedule(weekday: "FRI", time: "15:00"),
            Schedule(weekday: "SAT", time: "15:00"),
            Schedule(weekday: "SUN", time: "17:00")
        ]
        
        // Создаем тестовое расписание для ученика
        let testSchedule2 = [
            Schedule(weekday: "MON", time: "15:00"),
            Schedule(weekday: "TUE", time: "15:00"),
            Schedule(weekday: "WED", time: "15:00"),
            Schedule(weekday: "THU", time: "15:00")
        ]
        
        let lessonPrice = LessonPrice(price: 100.0, currency: "GBP")
        
        let months = [
            Month(monthName: "June", monthYear: "2024", isPaid: false, lessonPrice: lessonPrice, lessons: []),
            Month(monthName: "July", monthYear: "2024", isPaid: false, lessonPrice: lessonPrice, lessons: []),
            Month(monthName: "August", monthYear: "2024", isPaid: false, lessonPrice: lessonPrice, lessons: []),
            Month(monthName: "September", monthYear: "2024", isPaid: false, lessonPrice: lessonPrice, lessons: [])
        ]
        
        // Создаем тестового ученика с этим расписанием
        let testStudent = Student(
            id: UUID(),
            name: "Harry Potter",
            parentName: "Lilly Potter",
            phoneNumber: "+44-7871256566",
            months: months,
            lessons: [],
            lessonPrice: lessonPrice,
            schedule: testSchedule1,
            type: .schoolchild,
            image: UIImage(named: "harry")?.squareImage()
        )
        
        // Создаем тестового ученика с этим расписанием
        let testStudent2 = Student(
            id: UUID(),
            name: "Ron Weasley",
            parentName: "Molly Weasley",
            phoneNumber: "+44-7871234567",
            months: [],
            lessons: [],
            lessonPrice: lessonPrice,
            schedule: testSchedule2,
            type: .schoolchild,
            image: UIImage(named: "ron")?.squareImage()
        )
        
        // Создаем тестового ученика с этим расписанием
        let testStudent3 = Student(
            id: UUID(),
            name: "Hermione Granger",
            parentName: "Monica Wilkins",
            phoneNumber: "+44-7871234231",
            months: [],
            lessons: [],
            lessonPrice: lessonPrice,
            schedule: testSchedule1,
            type: .schoolchild,
            image: UIImage(named: "hermione")?.squareImage()
        )
        
        let testStudent4 = Student(
            id: UUID(),
            name: "Neville Longbottom",
            parentName: "Alice Longbottom",
            phoneNumber: "+44-7871234533",
            months: [],
            lessons: [],
            lessonPrice: lessonPrice,
            schedule: testSchedule2,
            type: .schoolchild,
            image: UIImage(named: "neville")?.squareImage()
        )
        
        let testStudent5 = Student(
            id: UUID(),
            name: "Myrtle Warren",
            parentName: "Alice Longbottom",
            phoneNumber: "+44-7871232122",
            months: [],
            lessons: [],
            lessonPrice: lessonPrice,
            schedule: [],
            type: .schoolchild,
            image: UIImage(named: "unknown_logo")?.squareImage()
        )
        
        // Добавляем тестовых учеников в модель данных через StudentViewModel
        studentViewModel.addStudent(testStudent)
        studentViewModel.addStudent(testStudent2)
        studentViewModel.addStudent(testStudent3)
        studentViewModel.addStudent(testStudent4)
        studentViewModel.addStudent(testStudent5)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension UIImage {
    func squareImage() -> UIImage? {
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        
        let smallerSide = min(originalWidth, originalHeight)
        let cropRect = CGRect(x: (originalWidth - smallerSide) / 2, y: (originalHeight - smallerSide) / 2, width: smallerSide, height: smallerSide)
        
        if let croppedImage = self.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: croppedImage, scale: self.scale, orientation: self.imageOrientation)
        }
        
        return nil
    }
}

