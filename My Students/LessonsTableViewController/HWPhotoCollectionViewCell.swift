//
//  PhotoCollectionViewCell.swift
//  Accounting
//
//  Created by Марк Кулик on 20.06.2024.
//

import UIKit
import SnapKit

class HWPhotoCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5 // Цвет фона для временного изображения
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .red
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        return button
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(loadingIndicator)
        
        contentView.isUserInteractionEnabled = true
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.isUserInteractionEnabled = true
        
        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(1)
            make.width.height.equalTo(50)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }
}


