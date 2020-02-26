//
//  settingsVC.swift
//  SnapChatFinal
//
//  Created by Alperen Toksöz on 17.02.2020.
//  Copyright © 2020 Alperen Toksöz. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try         Auth.auth().signOut()
        } catch {
            
        }
        self.performSegue(withIdentifier: "toSignInVC", sender: nil)
    }
}
