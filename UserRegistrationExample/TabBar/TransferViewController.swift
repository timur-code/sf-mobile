//
//  TransferViewController.swift
//  RANT
//
//  Created by Aligazy Kismetov on 27.04.2022.
//  Copyright © 2022 Ali. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class TransferViewController: UIViewController {

    @IBOutlet weak var amount: TextField!
    @IBOutlet weak var email: TextField!
    @IBOutlet weak var balance: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshBalance()
        refreshBalance()
        // Do any additional setup after loading the view.
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
                                self.balance.text = stringBalance
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
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView){
          DispatchQueue.main.async
           {
                  activityIndicator.stopAnimating()
                  activityIndicator.removeFromSuperview()
          }
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
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let id: Int? = KeychainWrapper.standard.integer(forKey: "id")
        print("Sign up button tapped")
        
        // Validate required fields are not empty
        if ((amount.text?.isEmpty)! || (email.text?.isEmpty)!)
        {
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
        let myUrl = URL(string: "https://sf-rant-backend.herokuapp.com/user/\(id!)/transfer")
                var request = URLRequest(url:myUrl!)
                request.httpMethod = "POST"// Compose a query string
                request.addValue("application/json", forHTTPHeaderField: "content-type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        
        let postString = ["userTo": email.text!,"amount": amount.text!] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. Try again.")
            return
        }
        
     let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        self.removeActivityIndicator(activityIndicator: myActivityIndicator)
         
         if let httpResponse = response as? HTTPURLResponse {
             print("error \(httpResponse.statusCode)")
             if httpResponse.statusCode == 400{
                 self.displayMessage(userMessage: "Not enough funds")
             }
         }
        
        if error != nil
        {
            self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
            print("error=\(String(describing: error))")
            return
        }
       
         self.displayMessage(userMessage: "Transfer done")
        }
        
        task.resume()
        refreshBalance()
        refreshBalance()
    }
    
    
    @IBAction func back(_ sender: Any) {
        let vs = storyboard?.instantiateViewController(withIdentifier: "myTabBar") as! UITabBarController
        vs.modalPresentationStyle = .overFullScreen
        vs.selectedIndex = 1
        present(vs, animated: true)
        
    }
    

}
