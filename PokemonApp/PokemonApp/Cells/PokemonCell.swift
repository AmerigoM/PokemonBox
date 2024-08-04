//
//  PokemonCell.swift
//  PokemonApp
//
//  Created by Amerigo Mancino on 02/08/24.
//

import UIKit

class PokemonCell: UITableViewCell {
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var type2: UILabel!
    @IBOutlet weak var type1: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        view1.layer.cornerRadius = 8.0
        view2.layer.cornerRadius = 8.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
