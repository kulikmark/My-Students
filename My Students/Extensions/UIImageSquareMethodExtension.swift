//
//  UIImageSquareMethodExtension.swift
//  My Students
//
//  Created by Марк Кулик on 01.07.2024.
//


//TODO: - Name extensions as UIImage+squareImage.swift
/*
 No need to write in file name Extension word
 that work for all files 
 */

import UIKit

// MARK: - UIImage Extension

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
