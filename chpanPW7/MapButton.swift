//
//  MapButton.swift
//  chpanPW7
//
//  Created by ZhengWu Pan on 26.01.2022.
//

import Foundation
import UIKit

class MapButton: UIButton{
    init(backColor: CGColor, text:String, frame:CGRect){
        super.init(frame: frame)
        self.layer.backgroundColor = backColor
        self.setTitle(text, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 5
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
