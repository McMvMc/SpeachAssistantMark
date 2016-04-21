//
//  ViewController.swift
//  twitter
//
//  Created by McTavish Wang on 15/9/27.
//  Copyright (c) 2015年 McTavish Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var LastName: UITextField!
    @IBOutlet weak var FirstName: UITextField!
    @IBOutlet weak var Role: UITextField!
    @IBOutlet weak var DateOfBirth: UITextField!
    @IBOutlet weak var Family: UITextField!
    
    
    var ref = Firebase(url: "https://testrealtime.firebaseio.com/")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {

        if ref.authData != nil {
            print("there is a user already signed in")
            self.performSegueWithIdentifier("loginAndSignUpComplete", sender: self)
        }
        else{print("you need to login or signup")}
        
    }
    
    @IBAction func login(sender: AnyObject) {
        
        if emailTextField.text == "" || passwordTextField.text == ""{
                showFillInFieldsAlert()
                print("make sure to enter all fields")
            
        }else{
        
            ref.authUser(emailTextField.text, password: passwordTextField.text, withCompletionBlock: {
                (error, authData) -> Void in
                if error != nil {
                    print(error)
                    print("there is an error")
            UIAlertView(title: "Error", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
                }else{
                    print("login success")
                    self.performSegueWithIdentifier("loginAndSignUpComplete", sender: self)
                }
            })
            
        }
        
    }

    @IBAction func signup(sender: AnyObject) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            showFillInFieldsAlert()
            print("make sure to enter in each textfield")
        
        }else{
        
            ref.createUser(emailTextField.text, password: passwordTextField.text, withValueCompletionBlock: {
                (error, result) -> Void in
                if error != nil{
                
                    print(error)
                    
                }else{
                
                    UIAlertView(title: "Thank You", message: "Sign up success", delegate: nil, cancelButtonTitle: "OK").show()
                    
                    self.ref.authUser(self.emailTextField.text, password: self.passwordTextField.text, withCompletionBlock: {
                    (error, authData) -> Void in
                        
                        if(error != nil)
                        {
                            UIAlertView(title: "Error", message: "\(error)", delegate: nil, cancelButtonTitle: "OK").show()
                        }
                        else{
                            var userId = authData.uid // use id is unique for every user accross all devices
                            
                            // set family
                            self.setUserFamily(authData)
                            
                            
                            // set user
                            self.setUser(authData)

                            //finish signing up, segue
                            self.performSegueWithIdentifier("loginAndSignUpComplete", sender: self)
                        }
                    
                    })
                    
                    
                }
            
            })
        
        }
    }

    @IBAction func showFillInFieldsAlert() {
        let alertController = UIAlertController(title: "Sorry", message: "Please fill in all the fields?", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func setUser(authData: FAuthData){
        let newUser = [
            "LastName": self.LastName.text!,
            "FirstName": self.FirstName.text!,
            "Role": self.Role.text!,
            "DateOfBirth": self.DateOfBirth.text!,
            "Email": (authData.providerData["email"] as? String)!,
            "Family": self.Family.text!,
            "CurrentLongitude":"",
            "CurrentLatitude":""
        ] as NSDictionary
        
        self.ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
        self.ref.childByAppendingPath("Images").childByAppendingPath(authData.uid).setValue(" ")
        //self.ref.childByAppendingPath("Families").childByAppendingPath(self.Family.text).childByAppendingPath(authData.uid).setValue(newUser)
        
    }
    
    func setUserFamily( authData: FAuthData){
        //let newFamily = ["FamilyName": self.Family.text]
        
        self.ref.childByAppendingPath("Families").childByAppendingPath(self.Family.text).childByAutoId().setValue(self.ref.authData.uid)
    }
    
    
    
}

