//
//  AppDelegate.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import Combine
import SwiftUI
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        FirebaseApp.configure()
        
//        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            print("Documents Directory: \(documentsDirectory)")
//        }
        
    
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


//        // Create instances of Schedule
//        let schedule = Schedule()
//        schedule.weekday = "MON"
//        schedule.time = "15:00"
//        let testSchedule = [schedule]
//
//        let testLessonPrice = LessonPrice()
//        testLessonPrice.currency = "GBP"
//        testLessonPrice.price = 500
//
//        let month = Month()
//        let monthName = "June"
//        let monthYear = "2024"
//        let testMonth = [month]
//
//        // Create test students
//        let testStudent1 = Student(
//            id: UUID(),
//            name: "Harry Potter",
//            parentName: "Lilly Potter",
//            phoneNumber: "+44-7871256566",
//            months: testMonth,
//            lessons: [],
//            lessonPrice: testLessonPrice,
//            schedule: testSchedule,
//            type: .schoolchild,
//            studentImage: "harry", // имя файла в Assets без расширения
//            photoUrls: []
//        )
//
//        let testStudent2 = Student(
//            id: UUID(),
//            name: "Ron Weasley",
//            parentName: "Molly Weasley",
//            phoneNumber: "+44-7871234567",
//            months: [],
//            lessons: [],
//            lessonPrice: testLessonPrice,
//            schedule: testSchedule,
//            type: .schoolchild,
//            studentImage: "ron", // имя файла в Assets без расширения
//            photoUrls: []
//        )
//
//        let testStudent3 = Student(
//            id: UUID(),
//            name: "Hermione Granger",
//            parentName: "Monica Wilkins",
//            phoneNumber: "+44-7871234231",
//            months: [],
//            lessons: [],
//            lessonPrice: testLessonPrice,
//            schedule: testSchedule,
//            type: .schoolchild,
//            studentImage: "hermione", // имя файла в Assets без расширения
//            photoUrls: []
//        )
//
//        let testStudent4 = Student(
//            id: UUID(),
//            name: "Neville Longbottom",
//            parentName: "Alice Longbottom",
//            phoneNumber: "+44-7871234533",
//            months: [],
//            lessons: [],
//            lessonPrice: testLessonPrice,
//            schedule: testSchedule,
//            type: .schoolchild,
//            studentImage: "neville", // имя файла в Assets без расширения
//            photoUrls: []
//        )
//
//        let testStudent5 = Student(
//            id: UUID(),
//            name: "Albus Percival Wulfric Brian Dumbledore",
//            parentName: "No data",
//            phoneNumber: "+44-111",
//            months: [],
//            lessons: [],
//            lessonPrice: testLessonPrice,
//            schedule: [],
//            type: .schoolchild,
//            studentImage: "unknown_logo", // имя файла в Assets без расширения
//            photoUrls: []
//        )
//        let testStudent6 = Student(
//            id: UUID(),
//            name: "Minerva McGonagall",
//            parentName: "Alice Longbottom",
//            phoneNumber: "+44-123456789",
//            months: [],
//            lessons: [],
//            lessonPrice: testLessonPrice,
//            schedule: [],
//            type: .schoolchild,
//            studentImage: "unknown_logo", // имя файла в Assets без расширения
//            photoUrls: []
//        )
//        let testStudent7 = Student(
//            id: UUID(),
//            name: "Myrtle Warren",
//            parentName: "Alice Longbottom",
//            phoneNumber: "+44-7871232122",
//            months: [],
//            lessons: [],
//            lessonPrice: testLessonPrice,
//            schedule: [],
//            type: .schoolchild,
//            studentImage: "unknown_logo", // имя файла в Assets без расширения
//            photoUrls: []
//        )
//
//        // Add test students to ViewModel
//        studentViewModel.addStudent(testStudent1)
//        studentViewModel.addStudent(testStudent2)
//        studentViewModel.addStudent(testStudent3)
//        studentViewModel.addStudent(testStudent4)
//        studentViewModel.addStudent(testStudent5)
//        studentViewModel.addStudent(testStudent6)
//        studentViewModel.addStudent(testStudent7)
