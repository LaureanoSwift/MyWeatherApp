//
//  WeatherCollectionViewCell.swift
//  MyWeatherApp
//
//  Created by Laureano Velasco on 26/04/2023.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var HourLabel: UILabel!
    
    func configure(with model: DataHour){
        
        var time = model.time
        
        time.removeFirst(11)
        
        self.HourLabel.text = "\(time)"
        self.tempLabel.text = "\(model.temp_c)"
        self.iconImageView.contentMode = .scaleAspectFit
        
        let icon = model.condition.icon.lowercased()
        
        if icon.contains("sunny") {
            self.iconImageView.image = UIImage(named: "sun")
            }else if icon.contains("rain") {
                self.iconImageView.image = UIImage(named: "rain")
            } else {    //cloud icon
                self.iconImageView.image = UIImage(named: "clouds")
            }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
