//
//  SEFilesAndFolderTableViewController.swift
//  HAPI
//
//  Created by Shaojun Ni on 6/18/15.
//  Copyright (c) 2015 MGO. All rights reserved.
//

import UIKit
import HAPIKit

class SEFilesAndFolderTableViewController: UITableViewController {
    var parent : ShareViewController!
    
    private var items = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if( HAPIClient.sharedInstance.ContextObject != nil )
        {
            var fileIdentifier = HAPIClient.sharedInstance.ContextObject!["FileIdentifier"] as! String;
            LoadADShare(fileIdentifier);
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func CtrlUpload(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
        parent.didSelectPost()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // Selected item is context for the next view
        HAPIClient.sharedInstance.ContextObject = self.items[indexPath.row];
        
        // Show next view based on item type
        var itemType = HAPIClient.sharedInstance.ContextObject!["Type"] as! Int;
        
        if( itemType == 2) // Folder
        {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("SEFilesAndFolderTableViewController") as! SEFilesAndFolderTableViewController;
            
            navigationController?.pushViewController(vc, animated: true);
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("FolderCell") as! UITableViewCell
        
        if( self.items.count > 0)
        {
            var adShare : AnyObject?;
            
            adShare = self.items[indexPath.row];
            
            
            if( adShare != nil)
            {
                // Configure the cell
                cell.textLabel!.text = adShare?["Name"] as! String?;
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
        }
        else
        {
            cell.textLabel!.text = "Loading...";
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func LoadADShare(fileIdentifier : String)
    {
        for item in HAPIClient.sharedInstance.GetShare(fileIdentifier)
        {
            var itemType = item["Type"] as! Int;
            if itemType == 2
            {
                self.items.append(item)
            }
        }
        
        // Reload the table
        self.tableView.reloadData()
    }
}
