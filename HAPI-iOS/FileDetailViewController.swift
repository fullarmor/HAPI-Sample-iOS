//
//  FileDetailViewController.swift
//  HAPI
//
//  Created by NSJ on 5/19/15.
//  Copyright (c) 2015 MGO. All rights reserved.
//

import QuickLook
import UIKit

class FileDetailViewController: UIViewController, NSURLSessionDownloadDelegate, QLPreviewControllerDataSource {

    @IBAction func CtrlShareButton(sender: AnyObject) {
        let content = fileSharePath
        let vc : UIActivityViewController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    /*@IBOutlet weak var CtrlPreview: UIButton!
    
    @IBAction func CtrlPreview(sender: AnyObject) {
        let previewQL = QLPreviewController()
        previewQL.dataSource = self
        previewQL.currentPreviewItemIndex = 1
        presentViewController(previewQL, animated: true, completion: nil)
    }*/
    
    @IBOutlet weak var CtrlFilename: UILabel!
    
    @IBOutlet weak var CtrlSize: UILabel!
    
    @IBOutlet weak var CtrlModifiedDate: UILabel!
    
    @IBOutlet weak var CtrlDownload: UIButton!
    
    var fileName :String!
    var fileSize :NSNumber!
    var lastModified:NSDate!
    var fileUrl : String!
    var fileSharePath : NSURL!
    
    private var progress: KDCircularProgress!
    private var isdownload: Bool = true
    
    @IBAction func HandleDownloadClick(sender: UIButton) {
        if isdownload == true {
            let realurl = NSURL(string: fileUrl)!
            self.CtrlDownload.enabled = false
            downloadFileWithProgress(realurl)
        }
        else
        {
            let previewQL = QLPreviewController()
            previewQL.dataSource = self
            previewQL.currentPreviewItemIndex = 1
            presentViewController(previewQL, animated: true, completion: nil)
        }
    }
    
    func completed(path:String, error:NSError!)->Void
    {
        if error == nil
        {
            CtrlDownload.setTitle("Preview/Share", forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        CtrlFilename.text = "Filename: " + fileName
        CtrlSize.text = "File Size: " + fileSize.stringValue + " bytes"
        if lastModified == nil
        {
            CtrlModifiedDate.text = "Last Modifed: N/A"
        }
        else
        {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //format style. Browse online to get a format that fits your needs.
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            var dateString = dateFormatter.stringFromDate(lastModified)
            CtrlModifiedDate.text = "Last Modifed: " + dateString
        }
        
        
        //CtrlDownload.enabled = false
        let b = IsFileExist()
        if b == false
        {
            CtrlDownload.setTitle("Download", forState: UIControlState.Normal)
            isdownload = true
            //CtrlPreview.enabled = false;
        }
        else
        {
            CtrlDownload.setTitle("Preview/Share", forState: UIControlState.Normal)
            isdownload = false
            //CtrlPreview.enabled = true;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func IsFileExist() -> Bool {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(fileName)
        fileSharePath = destinationUrl
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    func loadFileSync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(fileName)
        
        if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
                //CtrlDownload.enabled = false
                completion(path: destinationUrl.path!, error:nil)
            } else {
                
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(path: destinationUrl.path!, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(path: destinationUrl.path!, error:error)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func downloadFileWithProgress(url: NSURL) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        
        let downloadTask = session.downloadTaskWithURL(url)
        
        ShowProgress()
        downloadTask.resume()
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?)
    {
        if error != nil && error?.localizedDescription != nil
        {
            var alert = UIAlertController(title: "Alert Title", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!) in
                self.RemoveProgress()
                //println("User click Ok button")
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(fileName)
        
        if let data = NSData(contentsOfURL: location) {
            data.writeToURL(destinationUrl, atomically: true)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.RemoveProgress()
                self.CtrlDownload.enabled = true
                self.CtrlDownload.setTitle("Preview/Share", forState: UIControlState.Normal)
                self.isdownload = false
            }
        }
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController!) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController!, previewItemAtIndex index: Int) -> QLPreviewItem! {
        return fileSharePath
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.SetProgress(Int(progress * 360.0))
        }
    }

    func ShowProgress()
    {
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.7
        progress.clockwise = true
        progress.center = view.center
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .Forward
        progress.setColors(UIColor.cyanColor() ,UIColor.whiteColor(), UIColor.magentaColor())
        progress.tag = 12345
        view.addSubview(progress)
    }
    
    func RemoveProgress()
    {
        if let viewWithTag = self.view.viewWithTag(12345) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func SetProgress(percentage: Int)
    {
        if percentage > 100 || percentage < 0
        {
            progress.angle = 360
        } else {
            progress.angle = percentage
        }
    }
    
}
