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
    var coordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Инициализируйте Firebase
        FirebaseApp.configure()
        
        // Check dark mode setting from UserDefaults
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        
        // Создайте окно
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        coordinator = AppCoordinator(navigationController: navigationController)
        
        if LoginManager.shared.isLoggedIn {
            coordinator?.showContainerScreen()
        } else {
            coordinator?.start()
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Конфигурация уведомлений
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
        
        center.delegate = self
        
        return true
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive called")
        // Дополнительный код
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive called")
        // Дополнительный код
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground called")
        // Дополнительный код
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate called")
        // Дополнительный код
    }
    
    
    // This method will be called when the app receives a notification in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // This method will be called when the user taps on the notification (foreground and background)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
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
