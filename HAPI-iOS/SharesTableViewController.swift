//
//  SharesTableViewController.swift
//  HAPI_iOS
//
//  Copyright (c) 2015 FullArmor. All rights reserved.
//

import UIKit
import HAPIKit

class SharesTableViewController : UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate
{
    var serverUrl : String!
    //var sharedData : NSData! = nil
    //var sharedFileName: String!
    
    private var adShares = [AnyObject]();
    private var adSharesFiltered = [AnyObject]();
 
    @IBAction func CtrlLogout(sender: AnyObject) {
        KeychainHelper.delete("serverUrl")
        KeychainHelper.delete("userName")
        KeychainHelper.delete("password")
        
        PromptForCreds()
    }
    
    override func viewDidLoad() {
        var imageView = UIImageView(image: UIImage(named: "Hapi-Logo-128b.png"));
        imageView.contentMode = UIViewContentMode.ScaleAspectFit;
        imageView.frame = CGRectMake(0, 0, 128, 30);
        /*
        //Sets Banner Bar background to dark color
        //self.navigationController?.navigationBar.translucent = false;
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0);
        self.navigationController!.navigationBar .setBackgroundImage(UIImage .new(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage .new();
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.navigationBar.backgroundColor = UIColor(red: 0.135, green: 0.135, blue: 0.135, alpha: 1);
        */
        
        var subTitleLabel: UILabel = UILabel(frame: CGRectMake(0, 22, 0, 0))
        subTitleLabel.backgroundColor = UIColor.clearColor()
        //subTitleLabel.textColor = UIColor.whiteColor()
        subTitleLabel.font = UIFont.systemFontOfSize(12)
        subTitleLabel.text = "";//"Shares";
        subTitleLabel.sizeToFit()
        var twoLineTitleView: UIView = UIView(frame: CGRectMake(0, 0, max(subTitleLabel.frame.size.width, imageView.frame.size.width), 30))
        twoLineTitleView.addSubview(imageView);
        twoLineTitleView.addSubview(subTitleLabel)
        var widthDiff: Float = Float(subTitleLabel.frame.size.width - imageView.frame.size.width);
        self.navigationItem.titleView = twoLineTitleView
        
        subTitleLabel.frame = CGRectMake((twoLineTitleView.frame.width - subTitleLabel.frame.width) / 2, 18, 100, 22);
        
        PromptForCreds();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView
        {
            return self.adSharesFiltered.count;
        }
        else
        {
            return self.adShares.count;
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        if( self.adShares.count > 0)
        {
            var adShare : AnyObject?;
            // Check to see whether the normal table or search results table is being displayed and set the object from the appropriate array
            
            if tableView == self.searchDisplayController!.searchResultsTableView {
                adShare = self.adSharesFiltered[indexPath.row];
            } else {
                adShare = self.adShares[indexPath.row];
            }
            
            if( adShare != nil)
            {
                // Configure the cell
                cell.textLabel!.text = adShare?["Name"] as! String?;
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

                // Icon for Row
                cell.imageView?.image = UIImage(named: "iconFolder-96p.png"); // Folder Icon

            }
        }
        else
        {
            cell.textLabel!.text = "Loading...";
        }
        
        return cell
        
    }

    func filterContentForSearchText(searchText: String, scope: String = "All")
    {
        self.adSharesFiltered = self.adShares.filter({( adShare : AnyObject) -> Bool in
            //var categoryMatch = (scope == "All") || (adShare["Category"] == scope)
            var adShareName : String = adShare["Name"] as! String;
            var stringMatch = adShareName.lowercaseString.rangeOfString(searchText.lowercaseString);
            //return categoryMatch && (stringMatch != nil)
            return stringMatch != nil;
        })
        
    }

    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        let scopes = self.searchDisplayController!.searchBar.scopeButtonTitles as! [String]
        let selectedScope = scopes[self.searchDisplayController!.searchBar.selectedScopeButtonIndex] as String
        self.filterContentForSearchText(searchString, scope: selectedScope)
        return true
    }

    func searchDisplayController(controller: UISearchDisplayController!,
        shouldReloadTableForSearchScope searchOption: Int) -> Bool {
            let scope = self.searchDisplayController!.searchBar.scopeButtonTitles as! [String]
            self.filterContentForSearchText(self.searchDisplayController!.searchBar.text, scope: scope[searchOption])
            return true
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // Selected item is context for the next view
        if tableView == self.searchDisplayController!.searchResultsTableView {
            HAPIClient.sharedInstance.ContextObject = self.adSharesFiltered[indexPath.row];
        } else {
            HAPIClient.sharedInstance.ContextObject = self.adShares[indexPath.row];
        }
        
        // Switch to the next view
        self.performSegueWithIdentifier("filesAndFoldersSegue", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "filesAndFoldersSegue" {
            let nextController = segue.destinationViewController as! FilesAndFoldersTableViewController;
            nextController.serverUrl = self.serverUrl
            //nextController.sharedData = self.sharedData
            //nextController.sharedFileName = self.sharedFileName
            
            if sender as! UITableView == self.searchDisplayController!.searchResultsTableView {
                let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
                let destinationTitle = self.adSharesFiltered[indexPath.row]["Name"] as! String;
                nextController.title = destinationTitle
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                let destinationTitle = self.adShares[indexPath.row]["Name"] as! String
                nextController.title = destinationTitle
            }
            
        }
    }
    
    func LoadADShares()
    {   
        self.adShares = HAPIClient.sharedInstance.GetShares();
        
        // Reload the table
        self.tableView.reloadData()
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
                        
                        self.LoadADShares()
                        
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
                    
                    self.LoadADShares()
                    
                    return
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
