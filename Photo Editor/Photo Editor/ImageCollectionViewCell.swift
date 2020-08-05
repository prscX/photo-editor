//
//  ImageCollectionViewCell.swift
//  Photo Editor
//
//  Created by Adam Podsiadlo on 17/07/2020.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil;
    }
}
