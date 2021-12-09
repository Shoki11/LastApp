//
//  HairModelCell.swift
//  LastApp
//
//  Created by cmStudent on 2021/11/10.
//

import UIKit

class HairModelCell: UICollectionViewCell {
    
    @IBOutlet weak var hairModelImageView: UIImageView!    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpHairModelCell(hairImage: String) {
        hairModelImageView.image = UIImage(named: hairImage)
    }
    
}
