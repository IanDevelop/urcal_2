//
//  CommentCell.swift
//  urcal
//
//  Created by Kilian on 23.04.18.
//  Copyright © 2018 Kilian Hiestermann. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    let commentText: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = true
        return textField
    }()
    
    
     override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        addSubview(commentText)
        commentText.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}