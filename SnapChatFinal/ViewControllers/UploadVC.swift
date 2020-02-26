//
//  UploadVC.swift
//  SnapChatFinal
//
//  Created by Alperen Toksöz on 17.02.2020.
//  Copyright © 2020 Alperen Toksöz. All rights reserved.
//

import UIKit
import Firebase

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView : UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(recognizer)
        // Do any additional setup after loading the view.
    }
    

    
    @objc func chooseImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)

    }
    
        @IBAction func uploadClicked(_ sender: Any) {
            // MARK: STORAGE BEGIN
                    let storage = Storage.storage()
                    let storageReference = storage.reference()
                    let mediaFolder = storageReference.child("media")
                    
                    if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
                        let uuid = UUID().uuidString
                        let imageReference = mediaFolder.child("\(uuid).jpg")
                        
                        imageReference.putData(data, metadata: nil) { (metadata, error) in
                            if error != nil {
                                self.makeAlert(message: error?.localizedDescription ?? "Alert")
                            } else {
                                imageReference.downloadURL { (url, error) in
                                    if error == nil {
                                        let imageURL = url?.absoluteString
                                        
                                        // MARK: STORAGE END
                                        
                                        // MARK: FIRESTORE BEGIN
                                        let fireStore = Firestore.firestore()
                                        
                                fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { (snapshot, error) in
                                            if error != nil {
                                                self.makeAlert(message: error?.localizedDescription ?? "Alert")
                                            } else {
                                                if snapshot?.isEmpty == false && snapshot != nil {
                                                    for document in snapshot!.documents {
                                                        let documentId = document.documentID      // VAR OLAN RESİMİN IDSİ TEKRARDAN UPLOAD EDERKEN KULLANILACAK
                                              
                                                        // MARK: DÖKÜMANDAN RESİM ARRAY'E ÇEKİLİYOR DAHA SONRA YENİ RESİM DE ARRAY'E EKLENİYOR.
                                                        if var imageUrlArray = document.get("imageUrlArray") as?  [String] {
                                                            imageUrlArray.append(imageURL!)
                                                            
                                                            let additionalDictionary = ["imageUrlArray" : imageUrlArray] as? [String : Any]
                                                            // MARK: Dictionary'nin içindeki array tag'a göre set ediliyor(güncelleniyor) !!TEKRARDAN EKLENMİYOR!!
                                                            fireStore.collection("Snaps").document(documentId).setData(additionalDictionary!, merge: true) { (error) in
                                                                if error == nil {
                                                                    // MARK: 1. Controller'a dönüyoruz.
                                                                    self.tabBarController?.selectedIndex = 0
                                                                    self.imageView.image = UIImage(named: "selectImAGE")
                                                                }
                                                            }
                                                        }
                                                    }
                                                   
                                                    
                                                } else {
                                                    let snapDictionary = ["imageUrlArray" : [imageURL!] , "snapOwner" : UserSingleton.sharedUserInfo.username, "date" : FieldValue.serverTimestamp()] as [String : Any]
                                                    
                                                    fireStore.collection("Snaps").addDocument(data: snapDictionary) { (error) in
                                                        if error != nil {
                                                            // error
                                                        } else {
                                                             // MARK: 1. Controller'a dönüyoruz.
                                                            self.tabBarController?.selectedIndex = 0
                                                            self.imageView.image = UIImage(named: "selectImAGE")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        

                                    }
                                }
                            }
                }
            }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    func makeAlert(message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
        
    }

}

