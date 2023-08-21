//
//  CurrencyTableViewCell.swift
//  Currency-API-RxSwift
//
//  Created by Mohamed Salah on 20/08/2023.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyPriceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
