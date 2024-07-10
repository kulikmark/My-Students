//
//  LoginManager.swift
//  My Students
//
//  Created by Марк Кулик on 06.07.2024.
//

import UIKit

class LoginManager {
    static let shared = LoginManager()
    
    private let userDefaults = UserDefaults.standard
    
    private let isLoggedInKey = "isLoggedIn"
    
    var isLoggedIn: Bool {
        get {
            return userDefaults.bool(forKey: isLoggedInKey)
        }
        set {
            userDefaults.set(newValue, forKey: isLoggedInKey)
        }
    }
}
