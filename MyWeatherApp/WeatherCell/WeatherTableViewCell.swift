//
//  WeatherTableViewCell.swift
//  MyWeatherApp
//
//  Created by Laureano Velasco on 10/04/2023.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - Add Identifier and Nib functions to register the cells
    
    static let identifier = "WeatherTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    func configure(with model: DailyEntry){
        
        self.highTempLabel.textAlignment = .center
        self.lowTempLabel.textAlignment = .center
        
        
        self.lowTempLabel.text = "\(Int(model.day.mintemp_c))°"
        self.highTempLabel.text = "\(Int(model.day.maxtemp_c))°"
        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.date_epoch)))
        self.iconImageView.contentMode = .scaleAspectFit
        
        let icon = model.day.condition.text.lowercased()
        
        if icon.contains("sunny") {
            self.iconImageView.image = UIImage(named: "sun")
        }else if icon.contains("rain") {
            self.iconImageView.image = UIImage(named: "rain")
        } else {    //cloud icon
            self.iconImageView.image = UIImage(named: "clouds")
        }
        
    }
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Monday
        return formatter.string(from: inputDate)
    }
    
}
