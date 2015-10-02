//
//  ShareViewController.swift
//  HAPIShareExtension
//
//  Created by Shaojun Ni on 6/16/15.
//  Copyright (c) 2015 MGO. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import HAPIKit

class ShareViewController: SLComposeServiceViewController {
    private var serverUrl : String!
    private var fileData : NSData?
    private var fileName : String?
    
    override func viewDidLoad() {
        
        let content = extensionContext!.inputItems[0] as! NSExtensionItem
        
        for attachment in content.attachments as! [NSItemProvider] {
            if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                LoadFile(attachment, contentType: kUTTypeImage as String)
            }
            else if attachment.hasItemConformingToTypeIdentifier(kUTTypeItem as String) {
                LoadFile(attachment, contentType: kUTTypeItem as String)
            }
            else if attachment.hasItemConformingToTypeIdentifier(kUTTypePDF as String) {
                LoadFile(attachment, contentType: kUTTypePDF as String)
            }
            else if attachment.hasItemConformingToTypeIdentifier(kUTTypeAudiovisualContent as String) {
                LoadFile(attachment, contentType: kUTTypeAudiovisualContent as String)
            }
        }
        PromptForCreds()
    }
    
    func LoadFile(attachment: NSItemProvider, contentType: String)
    {
        attachment.loadItemForTypeIdentifier(contentType, options: nil) { data, error in
            if error == nil {
                let url = data as! NSURL
                self.fileData = NSData(contentsOfURL: url)!
                self.fileName = url.lastPathComponent!
            } else {
                
                let alert = UIAlertController(title: "Error", message: "Error loading File", preferredStyle: .Alert)
                
                let action = UIAlertAction(title: "Error", style: .Cancel) { _ in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func switchView() -> Void
    {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("SEShareTableViewController") as! SEShareTableViewController
    
        vc.serverUrl = self.serverUrl
        vc.parent = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        let fileIdentifier = HAPIClient.sharedInstance.ContextObject!["FileIdentifier"] as! String
        let destUrl = NSURL(string: serverUrl + "/route/hapi/shares/UploadFile")
        HAPIClient.sharedInstance.UploadNSData(destUrl!, nsdata: fileData, uploadFolder: fileIdentifier, fileName: fileName)
        
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
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
                        self.switchView()
                        return;
                    }
                }
            }
        }
        
        let alertController = UIAlertController(title: "", message: "Login Alert.", preferredStyle: .Alert);
        
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

                    self.switchView()
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
