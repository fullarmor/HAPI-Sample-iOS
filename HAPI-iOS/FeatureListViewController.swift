//
//  FeatureListViewController.swift
//  HAPI
//
//  Created by NSJ on 6/2/15.
//  Copyright (c) 2015 MGO. All rights reserved.
//

import UIKit
import HAPIKit

class FeatureListViewController: UIViewController {

    var serverUrl : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        PromptForCreds();
    }

    @IBAction func CtrlLogout(sender: AnyObject) {
        KeychainHelper.delete("serverUrl")
        KeychainHelper.delete("userName")
        KeychainHelper.delete("password")

        PromptForCreds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showShares" {
            let nextController = segue.destinationViewController as! SharesTableViewController
            nextController.serverUrl = self.serverUrl
        }
    }
    
    /*func SwithView()
    {
        let sharedefault = NSUserDefaults(suiteName: "group.com.fullarmor.hapi")
        if sharedefault != nil
        {
            if sharedefault?.objectForKey("fileKey") != nil
            {
                let shareddata = sharedefault?.objectForKey("fileKey") as! NSData
                let sharedfileName = sharedefault?.objectForKey("fileName") as! String
            
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("SharesTableViewController") as! SharesTableViewController
            
                vc.serverUrl = self.serverUrl
                vc.sharedData = shareddata
                vc.sharedFileName = sharedfileName
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }*/

    func PromptForCreds()
    {
        let username = KeychainHelper.loadString("userName")
        if username != nil
        {
            let password = KeychainHelper.loadString("password")
            if password != nil
            {
                let requestUrl = KeychainHelper.loadString("serverUrl")
                if requestUrl != nil
                {
                    if (HAPIClient.sharedInstance.Login(requestUrl!, userName: username, password: password))
                    {
                        self.serverUrl = requestUrl
                        //self.SwithView()
                        return;
                    }
                }
            }
        }
        let alertController = UIAlertController(title: "Default Style", message: "A standard alert.", preferredStyle: .Alert);
        
        let loginAction = UIAlertAction(title: "Login", style: .Default)
            {
                (_) in
                let serverTextField = alertController.textFields![0] as! UITextField
                let usernameTextField = alertController.textFields![1] as! UITextField
                let passwordTextField = alertController.textFields![2] as! UITextField
                
                if( HAPIClient.sharedInstance.Login( serverTextField.text, userName: usernameTextField.text, password: passwordTextField.text) )
                {
                    self.serverUrl = serverTextField.text
                    KeychainHelper.saveString("serverUrl", data:serverTextField.text)
                    KeychainHelper.saveString("userName", data: usernameTextField.text)
                    KeychainHelper.saveString("password", data: passwordTextField.text)
                    return;
                }
                else
                {
                    self.PromptForCreds(); // Login failed, prompt again
                }
                
        }
        //loginAction.enabled = false
        
        /*
        let forgotPasswordAction = UIAlertAction(title: "Forgot Password", style: .Destructive) { (_) in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        */
        
        alertController.addTextFieldWithConfigurationHandler
            {
                (textField) in
                textField.placeholder = "Server";
                textField.text = "https://sandbox.fullarmorhapi.com";
        }
        
        alertController.addTextFieldWithConfigurationHandler
            {
                (textField) in
                textField.placeholder = "Domain\\Username";
                textField.text = "";
                
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                    loginAction.enabled = textField.text != "";
                }
        }
        
        alertController.addTextFieldWithConfigurationHandler
            {
                (textField) in
                textField.placeholder = "Password;"
                textField.text = "";
                textField.secureTextEntry = true;
        }
        
        alertController.addAction(loginAction);
        
        /*
        alertController.addAction(forgotPasswordAction);
        alertController.addAction(cancelAction);
        */
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
}

extension String {
    public var dataValue: NSData {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
}

extension NSData {
    public var stringValue: String {
        return NSString(data: self, encoding: NSUTF8StringEncoding)! as String
    }
}
