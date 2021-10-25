//
//  PersonCell.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 21/10/2021.
//

import UIKit

class PersonCell: UITableViewCell {

    
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
