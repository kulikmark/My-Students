//
//  StudentCardPhotoChoosingPermission.swift
//  My Students
//
//  Created by Марк Кулик on 26.06.2024.
//

import UIKit
import Photos

// MARK: - UIImagePickerControllerDelegate

//extension StudentCardViewController {
//    
//    @objc func selectImage() {
//        imagePicker.delegate = self
//        
//        // Check if photo library is available
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            let status = PHPhotoLibrary.authorizationStatus()
//            switch status {
//            case .authorized:
//                // Access to photo library is authorized, open it
//                openPhotoLibrary()
//            case .notDetermined, .denied, .restricted:
//                // User hasn't decided yet, request access
//                requestPhotoLibraryAccess()
//            case .limited:
//                // User has limited access
//                showLimitedAccessAlert()
//            @unknown default:
//                break
//            }
//        } else {
//            // Photo library is not available, show error message
//            showGalleryUnavailableAlert()
//        }
//    }
//    
//    func openPhotoLibrary() {
//        // Open the photo library
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true, completion: nil)
//    }
//    
//    func requestPhotoLibraryAccess() {
//        // Request access to the photo library
//        PHPhotoLibrary.requestAuthorization { [weak self] status in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                if status == .authorized {
//                    // User granted access, open the photo library
//                    self.openPhotoLibrary()
//                } else {
//                    // User denied access or access is restricted
//                    self.showPermissionDeniedAlert()
//                }
//            }
//        }
//    }
//    
//    func showPermissionDeniedAlert() {
//        // Show alert when access to photo library is denied
//        let alert = UIAlertController(title: "Access to Photo Library Denied", message: "You can enable access to the photo library in your device settings", preferredStyle: .alert)
//        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
//            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(settingsAction)
//        alert.addAction(cancelAction)
//        present(alert, animated: true, completion: nil)
//    }
//    
//    func showLimitedAccessAlert() {
//        // Show alert when access to photo library is limited
//        let alert = UIAlertController(title: "Limited Access to Photo Library", message: "You can request additional permissions or grant access to specific resources in your device settings", preferredStyle: .alert)
//        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
//            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(settingsAction)
//        alert.addAction(cancelAction)
//        present(alert, animated: true, completion: nil)
//    }
//    
//    func showGalleryUnavailableAlert() {
//        // Show alert when photo library is unavailable
//        let alert = UIAlertController(title: "Error", message: "Photo Library is unavailable", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alert.addAction(okAction)
//        present(alert, animated: true, completion: nil)
//    }
//}
