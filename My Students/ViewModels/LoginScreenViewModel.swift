//
//  LoginScreenViewModel.swift
//  My Students
//
//  Created by Марк Кулик on 14.08.2024.
//

import FirebaseAuth
import Combine

import Foundation

enum LoginViewModelState {
    case idle
    case loading
    case success
    case failed(error: String)
}


class LoginScreenViewModel {
    // State to which the VC will subscribe
    private(set) var state = CurrentValueSubject<LoginViewModelState, Never>(.idle)
    
    // Dependency injection for StudentViewModel
    private var studentViewModel: StudentViewModel

    init(studentViewModel: StudentViewModel) {
        self.studentViewModel = studentViewModel
    }

    func start() {
        // Initial setup if needed, setting state to idle
        state.send(.idle)
    }

    func login(email: String, password: String) {
        state.send(.loading)
        
        // Example of async work, like network request
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                let errorMessage = self.handleAuthError(error)
                self.state.send(.failed(error: errorMessage))
                return
            }
            self.state.send(.success)
        }
    }

    func register(email: String, password: String) {
        state.send(.loading)
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                let errorMessage = self.handleAuthError(error)
                self.state.send(.failed(error: errorMessage))
                return
            }
            self.state.send(.success)
        }
    }

    private func handleAuthError(_ error: Error) -> String {
        guard let errorCode = AuthErrorCode.Code(rawValue: error._code) else {
            return error.localizedDescription
        }

        switch errorCode {
        case .invalidEmail:
            return "The email address is badly formatted."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .weakPassword:
            return "The password must be 6 characters long or more."
        case .wrongPassword:
            return "The password is invalid or the user does not have a password."
        default:
            return "Login failed. Please check your email and password."
        }
    }
}
