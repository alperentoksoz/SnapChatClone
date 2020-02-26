//
//  FeedVC.swift
//  SnapChatFinal
//
//  Created by Alperen Toksöz on 17.02.2020.
//  Copyright © 2020 Alperen Toksöz. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let fireStoreDatabase = Firestore.firestore()
    var snapArray = [Snap]()
    var choosenSnap : Snap?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        getUserInfo()
        getSnapsFromFirebase()
     }
    
    func getUserInfo() {
        
        fireStoreDatabase.collection("userInfo").whereField("email", isEqualTo: Auth.auth().currentUser?.email!).getDocuments { (snapshot, error) in
            if error != nil {
                self.makeAlert(message: error?.localizedDescription ?? "error 2")
            }
            else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    for document in snapshot!.documents {
                        if let username = document.get("username") as? String {
                            UserSingleton.sharedUserInfo.email = (Auth.auth().currentUser?.email!)!
                            UserSingleton.sharedUserInfo.username = username
                        }
                    }
                }
            }
        }
    }
    
    func getSnapsFromFirebase() {
        fireStoreDatabase.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                self.makeAlert(message: error?.localizedDescription ?? "Error!")
            } else {
                if snapshot?.isEmpty == false && snapshot != nil {
                    self.snapArray.removeAll(keepingCapacity: false) // MARK: ARRAY HER SEFERİNDE VERİ ÇEKİLMEDEN ÖNCE TEMİZLENİYOR.
                    for document in snapshot!.documents {
                        
                        let documentId = document.documentID
                        
                        if let username = document.get("snapOwner") as? String {
                            if let imageUrlArray = document.get("imageUrlArray") as? [String] {
                                if let date = document.get("date") as? Timestamp {
                                    
                                    if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour {
                                        if difference >= 24 {
                                            self.fireStoreDatabase.collection("Snaps").document(documentId).delete { (error) in
                                            
                                            }
                                        } else {
                                            let snap = Snap(userName: username, imageUrlArray: imageUrlArray, date: date.dateValue(), timeDifference: (24-difference) )
                                            self.snapArray.append(snap)
                                        }
                                    }

                                }
                            }
                        }
                        
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func makeAlert(message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.userNameLabel.text = snapArray[indexPath.row].userName
        cell.feedImageView.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0])) { (image, error, cachle, url) in
            if error != nil {
                print("Fonksiyonda hata var")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenSnap = self.snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC" {
            let destination = segue.destination as? SnapVC
            destination?.selectedSnap = choosenSnap
            
        }
    }

}
