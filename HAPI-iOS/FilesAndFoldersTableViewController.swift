//
//  FilesAndFoldersViewController.swift
//  HAPI_iOS
//
//  Created by Scott Jackson on 3/30/15.
//  Copyright (c) 2015 FullArmor. All rights reserved.
//

import Foundation
import UIKit
import HAPIKit

class FilesAndFoldersTableViewController : UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate
{
    var serverUrl : String!
    //var sharedData : NSData!
    //var sharedFileName : String!
    private var items = [AnyObject]();
    private var itemsFiltered = [AnyObject]();
    
    override func viewDidLoad() {

        var imageView = UIImageView(image: UIImage(named: "Hapi-Logo-128b.png"));
        imageView.contentMode = UIViewContentMode.ScaleAspectFit;
        imageView.frame = CGRectMake(0, 0, 128, 20);
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
        subTitleLabel.text = HAPIClient.sharedInstance.ContextObject?["Name"] as! String?;
        //self.navigationItem.backBarButtonItem.title = @"Back";
        subTitleLabel.sizeToFit()
        var twoLineTitleView: UIView = UIView(frame: CGRectMake(0, 0, max(subTitleLabel.frame.size.width, imageView.frame.size.width), 30))
        twoLineTitleView.addSubview(imageView);
        twoLineTitleView.addSubview(subTitleLabel)
        var widthDiff: Float = Float(subTitleLabel.frame.size.width - imageView.frame.size.width);
        self.navigationItem.titleView = twoLineTitleView
        
        subTitleLabel.frame = CGRectMake((twoLineTitleView.frame.width - subTitleLabel.frame.width) / 2, 18, 100, 22);
        
     if( HAPIClient.sharedInstance.ContextObject != nil )
        {
            var fileIdentifier = HAPIClient.sharedInstance.ContextObject!["FileIdentifier"] as! String;
            LoadADShare(fileIdentifier);
        }
        
    }
    
    /*@IBAction func CtrlUpload(sender: AnyObject) {
        
        if self.sharedData == nil
        {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("UploadFileSelectorTableViewController") as! UploadFileSelectorTableViewController
            
            vc.serverUrl = self.serverUrl
            vc.uploadPath = HAPIClient.sharedInstance.ContextObject!["FileIdentifier"] as! String
            navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            let fullserverURL = NSURL(string: serverUrl + "/route/hapi/shares/UploadFile")
            let uploadFolder = HAPIClient.sharedInstance.ContextObject!["FileIdentifier"] as! String
            
            HAPIClient.sharedInstance.UploadNSData(fullserverURL!, nsdata: sharedData, uploadFolder: uploadFolder, fileName: sharedFileName)
        }
            
    }*/
    
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
            return self.itemsFiltered.count;
        }
        else
        {
            return self.items.count;
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("fileAndFolderCell") as! UITableViewCell
        
        if( self.items.count > 0)
        {
            var adShare : AnyObject?;
            // Check to see whether the normal table or search results table is being displayed and set the object from the appropriate array
            
            if tableView == self.searchDisplayController!.searchResultsTableView {
                adShare = self.itemsFiltered[indexPath.row];
            } else {
                adShare = self.items[indexPath.row];
            }
            
            if( adShare != nil)
            {
                // Configure the cell
                cell.textLabel!.text = adShare?["Name"] as! String?;
                //var imageName = UIImage(named: "imageA.png");
                //cell.imageView?.image = imageName
                if ((adShare?["ThumbnailImages"]is NSNull) == false)
                {
                    var rawImages = adShare?["ThumbnailImages"] as! NSMutableArray;
                    var rawDic = rawImages[0] as! Dictionary<String, AnyObject>;
                    var base64Image = rawDic["Base64ImageString"] as! String;
                    let decodedData = NSData(base64EncodedString: base64Image, options: NSDataBase64DecodingOptions(rawValue: 0))
                    var decodedimage = UIImage(data: decodedData!)
                    //var realimage = decodedimage!.resize(0.2);
                    cell.imageView?.image = decodedimage;
                }
                else
                {
                    var itemType = adShare?["Type"] as! Int;
                    //var imageName = UIImage(named: "file27.png"); // File
                    var imageName = "iconFolder-96p.png";
                    if( itemType == 1)
                    {
                        imageName = GetFileTypeIcon( adShare?["FileIdentifier"] as! String );
                    }
                    cell.imageView?.image = UIImage(named: imageName);
                }
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
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
        self.itemsFiltered = self.items.filter({( adShare : AnyObject) -> Bool in
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // Selected item is context for the next view
        if tableView == self.searchDisplayController!.searchResultsTableView {
            HAPIClient.sharedInstance.ContextObject = self.itemsFiltered[indexPath.row];
        } else {
            HAPIClient.sharedInstance.ContextObject = self.items[indexPath.row];
        }
        
        // Show next view based on item type
        var itemType = HAPIClient.sharedInstance.ContextObject!["Type"] as! Int;
        
        if( itemType == 1) // File
        {
            //self.performSegueWithIdentifier("detailSegue", sender: tableView)
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("FileDetailView") as! FileDetailViewController;
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            
            let tempO = self.items[indexPath.row]
            vc.fileName = self.items[indexPath.row]["Name"] as! String
            vc.title = vc.fileName
            vc.fileSize = self.items[indexPath.row]["Size"] as! NSNumber
            
            let baseUrl = serverUrl + "/route/hapi/Shares/Download?fileIdentifier="
            let fileIdentity = self.items[indexPath.row]["FileIdentifier"] as! String!
            let encodedfile = fileIdentity.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            vc.fileUrl = baseUrl + fileIdentity.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            var lastModified = self.items[indexPath.row]["LastModifiedDate"] as! String!
            let dateFormatter = NSDateFormatter()
            let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
            dateFormatter.locale = enUSPosixLocale
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
            
            vc.lastModified = dateFormatter.dateFromString(lastModified)
            
            navigationController?.pushViewController(vc, animated: true);
        }
        else if( itemType == 2) // Folder
        {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("FilesAndFoldersView") as! FilesAndFoldersTableViewController;
            
            vc.serverUrl = self.serverUrl
            //vc.sharedData = self.sharedData
            navigationController?.pushViewController(vc, animated: true);
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    }
    
    func LoadADShare(fileIdentifier : String)
    {
        self.items = HAPIClient.sharedInstance.GetShare(fileIdentifier);// as [AnyObject];
        
        // Reload the table
        self.tableView.reloadData()
    }
    
    func GetFileTypeIcon(fileName: String) -> String
    {
        var splitResult = splitFilename( fileName );
        if( splitResult!.ext.isEmpty )
        {
            return "folder66.png";
        }
        
        switch( (splitResult!.ext).lowercaseString)
        {
        case "avi":
            return "iconAVI-168p.png";
        case "css":
            return "iconCSS-168p.png";
        case "dll":
            return "iconDLL-168p.png";
        case "doc":
            return "iconDOC-168p.png";
        case "docx":
            return "iconDOCX-168p.png";
        case "eps":
            return "iconEPS-168p.png";
        case "htm":
            return "iconHTM-168p.png";
        case "html":
            return "iconHTML-168p.png";
        case "jpg":
            return "iconJPG-168p.png";
        case "jpeg":
            return "iconJPEG-168p.png";
        case "mp3":
            return "iconMP3-168p.png";
        case "pdf":
            return "iconPDF-168p.png";
        case "png":
            return "iconPNG-168p.png";
        case "ppt":
            return "iconPPT-168p.png";
        case "pptx":
            return "iconPPTX-168p.png";
        case "psd":
            return "iconPSD-168p.png";
        case "txt":
            return "iconTXT-168p.png";
        case "wav":
            return "iconWAV-168p.png";
        case "xls":
            return "iconXLS-168p.png";
        case "xlsx":
            return "iconXLSX-168p.png";
        case "wav":
            return "iconWAV-168p.png";
        case "zip":
            return "iconZIP-168p.png";
        default:
            return "iconFile-168p.png";
        }
        
        return "iconFile-168p.png";
    }
    
    func splitFilename(str: String) -> (name: String, ext: String)? {
        if let rDotIdx = find(reverse(str), ".") {
            let dotIdx = advance(str.endIndex, -rDotIdx)
            let fname = str[str.startIndex..<advance(dotIdx, -1)]
            let ext = str[dotIdx..<str.endIndex]
            return (fname, ext)
        }
        return nil
    }
}

extension UIImage {
    func resize(scale:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    func resizeToWidth(width:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}