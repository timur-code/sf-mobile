//
//  ViewController.swift
//  UserRegistrationExample
//
//  Created by Kismetov Aligazy on 2022-03-10.
//  Copyright © 2022 Kismetov Aligazy. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class DepositViewController: UIViewController {

    @IBOutlet weak var userBalanceLabel: UILabel!
    @IBOutlet weak var textDeposit: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshBalance()
        refreshBalance()
    }
    
    func refreshBalance(){
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let id: Int? = KeychainWrapper.standard.integer(forKey: "id")
        let myUrl = URL(string: "https://sf-rant-backend.herokuapp.com/user/\(id!)/balance")
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
                            let balance: Int? = parseJSON["balance"] as? Int
                            let stringBalance: String = String(balance!)
                            if stringBalance.isEmpty != true {
                                self.userBalanceLabel.text = stringBalance
                            }
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
    }
    @IBAction func DepositButton(_ sender: Any) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let id: Int? = KeychainWrapper.standard.integer(forKey: "id")
        print("Sign up button tapped")
        
        // Validate required fields are not empty
        if (textDeposit.text?.isEmpty)! {
            // Display Alert message and return
            displayMessage(userMessage: "All fields are quired to fill in")
            return
        }
        

        //Create Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        // Position Activity Indicator in the center of the main view
        myActivityIndicator.center = view.center
        
        // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
        myActivityIndicator.hidesWhenStopped = false
        
        // Start Activity Indicator
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
        
        
        // Send HTTP Request to Register user
        let myUrl = URL(string: "https://sf-rant-backend.herokuapp.com/user/\(id!)/deposit")
                var request = URLRequest(url:myUrl!)
                request.httpMethod = "POST"// Compose a query string
                request.addValue("application/json", forHTTPHeaderField: "content-type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        print("amount = \(textDeposit.text!)")
                let postString = ["amount": textDeposit.text!
                                  ] as [String: String]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. Try again.")
            return
        }
        
     let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        self.removeActivityIndicator(activityIndicator: myActivityIndicator)
        
        if error != nil
        {
            self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
            print("error=\(String(describing: error))")
            return
        }
       
         self.displayMessage(userMessage: "Deposit done")
        }
        
        task.resume()
        refreshBalance()
        refreshBalance()
    }
    
    
    @IBAction func ref(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vs = storyboard.instantiateViewController(withIdentifier: "WithdrawViewController")
        vs.modalPresentationStyle = .overFullScreen
        present(vs, animated: true)
        refreshBalance()
        refreshBalance()
    }
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView)
      {
          DispatchQueue.main.async
           {
                  activityIndicator.stopAnimating()
                  activityIndicator.removeFromSuperview()
          }
      }
      
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    @IBAction func transfer(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vs = storyboard.instantiateViewController(withIdentifier: "TransferViewController")
        vs.modalPresentationStyle = .overFullScreen
        present(vs, animated: true)
        refreshBalance()
        refreshBalance()
    }
    
}

