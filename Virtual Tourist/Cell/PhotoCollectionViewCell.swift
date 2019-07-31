//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class PhotoCollectionViewCell : UICollectionViewCell{

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var image: Images! {
        didSet {
            if let image = image.fetchImage() {
                imageView.image = image
            } else if let url = URL(string: image.imageURL!){
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(with: url, options: [.transition(.fade(0.5))])
            }
        }
    }
}
    

extension Images {
    
    func fetchImage() -> UIImage? {
        guard let data = image else { return nil }
        return UIImage(data: data)
}
}
