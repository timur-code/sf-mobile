
//
//  HomePageViewController.swift
//  UserRegistrationExample
//
//  Created by Kismetov Aligazy on 2022-03-10.
//  Copyright © 2022 Kismetov Aligazy. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class HomePageViewController: UIViewController {

    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userPhoneLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        var id: Int?
        
        //Send HTTP Request to perform Sign in
        let myUrl = URL(string: "https://sf-rant-backend.herokuapp.com/")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "GET"// Compose a query string
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
       
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
               
                if let parseJSON = json {
                    
                    DispatchQueue.main.async
                        {
                            let fullName: String?  = parseJSON["fullName"] as? String
                            
                            let email: String? = parseJSON["email"] as? String
                            
                            let phone: String? = parseJSON["phone"] as? String
                            
                            id = parseJSON["id"] as? Int
                            
                            if fullName?.isEmpty != true {
                                self.userFullNameLabel.text = fullName
                                print("have")
                            }

                            if email?.isEmpty != true {
                                self.userEmailLabel.text = email
                            }
                            if phone?.isEmpty != true {
                                self.userPhoneLabel.text = phone
                            }
                            let stringId: String = String(id!)
                            if id != nil {
                               
                            }
                            KeychainWrapper.standard.set(fullName!, forKey: "fullName")
                            KeychainWrapper.standard.set(email!, forKey: "email")
                            KeychainWrapper.standard.set(phone!, forKey: "phone")
                            KeychainWrapper.standard.set(id!, forKey: "id")
                           
                        }
                } else {
                    //Display an Alert dialog with a friendly error message
                    self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                }
                
            } catch {
                    // Display an Alert dialog with a friendly error message
                    self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                    print(error)
            }
            
        }
        
        
        task.resume()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        
        
        let signInPage = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = signInPage
        
    }
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    // Code in this block will trigger when OK button tapped.
                    print("Ok button tapped")
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
 

}
