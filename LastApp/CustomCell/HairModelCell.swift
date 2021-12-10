//
//  HairModelCell.swift
//  LastApp
//
//  Created by cmStudent on 2021/11/10.
//

import UIKit

class HairModelCell: UICollectionViewCell {
    
    // MARK: - @IBOutlets
    /// HairModelの画像を表示するImageView
    @IBOutlet weak var hairModelImageView: UIImageView!    

    // MARK: - Mrthods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// ShopCellを初期化する
    /// - Parameters:
    ///   - hairImage: HairModelの画像を表示する文字列
    func setUpHairModelCell(hairImage: String) {
        hairModelImageView.image = UIImage(named: hairImage)
    }
    
}
