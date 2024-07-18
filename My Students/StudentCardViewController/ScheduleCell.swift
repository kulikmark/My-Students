//
//  ScheduleCell.swift
//  My Students
//
//  Created by Марк Кулик on 28.06.2024.
//

import UIKit
import SnapKit

class ScheduleCell: UICollectionViewCell {
    
    // Label to display schedule information
    var scheduleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        // Configure contentView
        contentView.backgroundColor = .systemBlue
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        // Add scheduleLabel to contentView
        contentView.addSubview(scheduleLabel)
        
        // Configure constraints using SnapKit
        scheduleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        scheduleLabel.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with scheduleItem: Schedule) {
        scheduleLabel.text = "\(scheduleItem.weekday) \(scheduleItem.time)"
    }
}
