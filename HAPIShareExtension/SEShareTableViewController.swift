//
//  SEShareTableViewController.swift
//  HAPI
//
//  Created by Shaojun Ni on 6/18/15.
//  Copyright (c) 2015 MGO. All rights reserved.
//

import UIKit
import HAPIKit

class SEShareTableViewController: UITableViewController {
    var serverUrl : String!
    var parent : ShareViewController!
    
    private var adShares = [AnyObject]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CtrlUpload.enabled = false
        self.LoadADShares()
    }

    @IBOutlet weak var CtrlUpload: UIBarButtonItem!
    
    @IBAction func CtrlTempClick(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
        //self.performSegueWithIdentifier("showRootView", sender: tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.adShares.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        if( self.adShares.count > 0)
        {
            var adShare : AnyObject?;
        
            adShare = self.adShares[indexPath.row];
            
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Selected item is context for the next view
        HAPIClient.sharedInstance.ContextObject = self.adShares[indexPath.row];
        
        CtrlUpload.enabled = true
        
        // Switch to the next view
        self.performSegueWithIdentifier("filesandfolders", sender: tableView)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "filesandfolders" {
            let nextController = segue.destinationViewController as! SEFilesAndFolderTableViewController;
            nextController.parent = self.parent
        }
    }
    
    func LoadADShares()
    {
        self.adShares = HAPIClient.sharedInstance.GetShares();
        
        // Reload the table
        self.tableView.reloadData()
    }
}
