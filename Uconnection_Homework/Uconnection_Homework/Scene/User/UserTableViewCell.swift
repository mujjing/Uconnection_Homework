//
//  UserTableViewCell.swift
//  Uconnection_Homework
//
//  Created by 전지훈 on 2021/10/31.
//

import UIKit
import Kingfisher

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func userSetting(_ imageUrl: String, _ loginName: String) {
        //image
        let url = URL(string: imageUrl)
        userImage.kf.setImage(with: url)
        userImage.layer.cornerRadius = userImage.frame.height / 2
        
        //name
        userLabel.text = loginName
    }
}
