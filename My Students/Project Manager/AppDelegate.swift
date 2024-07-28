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
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            } else if granted {
                print("Notification permission granted.")
                self.scheduleGeneralNotification() // Добавим логирование внутри функции
            } else {
                print("Notification permission denied.")
            }
        }
        
        center.delegate = self
        
        return true
    }
    
    // This method will be called when the app receives a notification in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // This method will be called when the user taps on the notification (foreground and background)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

extension AppDelegate {
    
    func scheduleGeneralNotification() {
        print("scheduleGeneralNotification called")
        
        let calendar = Calendar.current
        let now = Date()
        
        // Получаем последний день текущего месяца
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = calendar.range(of: .day, in: .month, for: now)!.count
        guard let lastDayOfMonth = calendar.date(from: components) else {
            print("Error getting last day of month")
            return
        }
        
        // Получаем дату за 3 дня до конца месяца
        guard let notificationDate = calendar.date(byAdding: .day, value: -3, to: lastDayOfMonth) else {
            print("Error getting notification date")
            return
        }
        
        // Определяем следующий месяц
        guard let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: now) else {
            print("Error getting next month date")
            return
        }
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let nextMonth = monthFormatter.string(from: nextMonthDate)
        
        var notificationComponents = calendar.dateComponents([.year, .month, .day], from: notificationDate)
        notificationComponents.hour = 12
        notificationComponents.minute = 0
        notificationComponents.timeZone = TimeZone.current // Установка текущей временной зоны

        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Hey! Don't forget to send payment-letters for \(nextMonth)! Just tap share button in Lessons List."
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "monthly_payment_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка добавления уведомления: \(error.localizedDescription)")
            } else {
                print("Уведомление успешно запланировано для \(notificationDate)")
            }
        }
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
