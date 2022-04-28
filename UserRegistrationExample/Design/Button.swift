//
//  Button.swift
//  UserRegistrationExample
//
//  Created by Aligazy Kismetov on 15.04.2022.
//  Copyright © 2022 Kismetov Aligazy. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.backgroundColor = UIColor(red: 111/255, green: 160/255, blue: 250/255, alpha: 1).cgColor
        layer.cornerRadius = 20
    }

    

}
