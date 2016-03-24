//
//  FilterCell.swift
//  exchangeAGram
//
//  Created by Andrew Morrison on 2016-03-21.
//  Copyright © 2016 Andrew Morrison. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {

    var imageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


