//
//  UIImagePickerControllerDelegate.swift
//  My Students
//
//  Created by Марк Кулик on 26.06.2024.
//

import UIKit

//// MARK: - UIImagePickerControllerDelegate
//
//extension StudentCardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let pickedImage = info[.originalImage] as? UIImage {
//            selectedImage = pickedImage
//            selectedImage = pickedImage.squareImage() // Обрезаем изображение до квадратного формата
//            
//            imageButton.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
//        }
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//// MARK: - UIImage Extension
//
//extension UIImage {
//    func squareImage() -> UIImage? {
//        let originalWidth = self.size.width
//        let originalHeight = self.size.height
//        
//        let smallerSide = min(originalWidth, originalHeight)
//        let cropRect = CGRect(x: (originalWidth - smallerSide) / 2, y: (originalHeight - smallerSide) / 2, width: smallerSide, height: smallerSide)
//        
//        if let croppedImage = self.cgImage?.cropping(to: cropRect) {
//            return UIImage(cgImage: croppedImage, scale: self.scale, orientation: self.imageOrientation)
//        }
//        
//        return nil
//    }
//}
