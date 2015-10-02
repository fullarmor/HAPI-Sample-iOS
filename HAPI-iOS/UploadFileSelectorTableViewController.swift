//
//  UploadFileSelectorTableViewController.swift
//  HAPI
//
//  Created by Shaojun Ni on 6/10/15.
//  Copyright (c) 2015 MGO. All rights reserved.
//

import UIKit
import HAPIKit

class UploadFileSelectorTableViewController: UITableViewController {
    private var files = [AnyObject]()
    var uploadPath : String!
    var serverUrl : String!
    
    @IBAction func CtrlUpload(sender: AnyObject) {
        let sourceUrl = GetContainerUrl()
        let destUrl = NSURL(string: serverUrl + "/route/hapi/shares/UploadFile")
        HAPIClient.sharedInstance.UploadFile(destUrl!, filePath: sourceUrl, uploadFolder: uploadPath)
    }
    
    func GetContainerUrl() -> NSURL
    {
        let indexPath = self.tableView.indexPathForSelectedRow()!
        let fileName = files[indexPath.row] as! String
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let sourceUrl = documentsUrl.URLByAppendingPathComponent(fileName)
        
        return sourceUrl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadFiles()
        tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }*/

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return files.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UploadFileSelector", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.minimumScaleFactor = 0.1

        cell.textLabel!.font = UIFont.systemFontOfSize(10.0)
        if( self.files.count > 0)
        {
            var link : AnyObject?;
            // Check to see whether the normal table or search results table is being displayed and set the object from the appropriate array
            
            /*if tableView == self.searchDisplayController!.searchResultsTableView {
            adShare = self.adSharesFiltered[indexPath.row];
            } else {
            adShare = self.adShares[indexPath.row];
            }*/
            link = self.files[indexPath.row]
            
            if( link != nil)
            {
                // Configure the cell
                cell.textLabel!.text = link as! String!;
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
    
    func loadFiles()
    {
        let fm = NSFileManager.defaultManager()
        let srcPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)[0] as! String

        let tempfiles = fm.enumeratorAtPath(srcPath)
        while let file: AnyObject = tempfiles?.nextObject() {
            println(file)
            files.append(file)
        }
    }

    /*func UploadResult(obj:AnyObject?, success: Bool?) -> Void {
        if success?.boolValue == false
        {
            let alert = UIAlertController(title: "Errir", message: "Upload Failed", preferredStyle: <#UIAlertControllerStyle#>.Alert)
        }
    }*/
}
