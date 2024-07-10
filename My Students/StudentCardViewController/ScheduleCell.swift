//
//  ScheduleCell.swift
//  My Students
//
//  Created by Марк Кулик on 28.06.2024.
//

import UIKit
import SnapKit

class ScheduleCell: UICollectionViewCell {
    
    // Container view to hold the contents
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 10
        return view
    }()
    
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
        
        // Add containerView to the cell's contentView
        contentView.addSubview(containerView)
        
        // Add scheduleLabel to containerView
        containerView.addSubview(scheduleLabel)
        
        // Configure constraints using SnapKit
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
        }
        
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
