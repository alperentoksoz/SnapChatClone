//
//  ViewController.swift
//  SnapChatFinal
//
//  Created by Alperen Toksöz on 17.02.2020.
//  Copyright © 2020 Alperen Toksöz. All rights reserved.
//

import UIKit
import Firebase

class SignInVC: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpClicked(_ sender: Any) {
        if usernameField.text != "" && emailField.text != "" && passwordField.text != "" {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (auth, error) in
                if error != nil {
                    self.makeAlert(message: error?.localizedDescription ?? "error")
                }
                else {
                    let fireStore = Firestore.firestore()
                    let dictionary = ["email" : self.emailField.text!, "username" : self.usernameField.text] as [String : Any]
                    fireStore.collection("userInfo").addDocument(data: dictionary) { (error) in
                        if error != nil {
                            //Error
                        }
                    }
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }
        else {
            self.makeAlert(message: "Please fill all fields!ios")
        }
    }
    @IBAction func SignInClicked(_ sender: Any) {
        if emailField.text != "" && passwordField.text != "" {
            Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (result, error) in
                if error != nil {
                    self.makeAlert(message: error?.localizedDescription ?? "Error")
                }
                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                
            }
        }
    }
    
    func makeAlert(message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
        
    }
}

