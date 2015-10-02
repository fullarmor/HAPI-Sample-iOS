//
//  LinksTableViewController.swift
//  HAPI
//
//  Created by NSJ on 6/2/15.
//  Copyright (c) 2015 MGO. All rights reserved.
//

import UIKit
import HAPIKit

class LinksTableViewController: UITableViewController {
    var links = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadLinks()
        tableView.reloadData()
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if tableView == self.ƒ!.searchResultsTableViewƒ
        {
            return self.adSharesFiltered.count;
        }
        else*/
        //{
            return self.links.count;
        //}
        
    }
    
    // MARK: - Table view data source

    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }*/

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ReuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.minimumScaleFactor = 0.1
        
        cell.textLabel!.font = UIFont.systemFontOfSize(10.0)
        if( self.links.count > 0)
        {
            var link : AnyObject?;
            // Check to see whether the normal table or search results table is being displayed and set the object from the appropriate array
            
            /*if tableView == self.searchDisplayController!.searchResultsTableView {
                adShare = self.adSharesFiltered[indexPath.row];
            } else {
                adShare = self.adShares[indexPath.row];
            }*/
            link = self.links[indexPath.row]
            
            if( link != nil)
            {
                // Configure the cell
                cell.textLabel!.text = link?["LinkUrl"] as! String?;
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "linkDetail" {
            let nextController = segue.destinationViewController as! LinkViewController;
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let destinationTitle = self.links[indexPath.row]["LinkUrl"] as! String
            nextController.fileIdentifier = self.links[indexPath.row]["FileIdentifier"] as! String
            let expireDate = self.links[indexPath.row]["ExpirationDate"] as! String!
            let dateFormatter = NSDateFormatter()
            let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
            dateFormatter.locale = enUSPosixLocale
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
            
            nextController.expireation = dateFormatter.dateFromString(expireDate)
            let userEntry: AnyObject! = self.links[indexPath.row]["Sharer"] as AnyObject!
            nextController.sharer = userEntry["DisplayName"] as! String!
            
        }
    }
    

    func loadLinks()
    {
        self.links = HAPIClient.sharedInstance.GetLinks();
    }
}
