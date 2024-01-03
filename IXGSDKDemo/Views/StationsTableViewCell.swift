//
//  StationsTableViewCell.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/3/24.
//

import UIKit
import AiphoneIntercomCorePkg

class StationsTableViewCell: UITableViewCell {
    static let cellIdentifier = "stationListCell"
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var unitNumberLabel: UILabel!
    @IBOutlet weak var stationIconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(station: Station){
        stationNameLabel.text = station.name
        unitNumberLabel.text = String(station.unitNumber)
        
        switch station.hasVideo {
        case true:
            print("")
        case false:
            print("")
        }
    }
}
