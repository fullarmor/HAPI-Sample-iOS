//
//  LinkViewController.swift
//  HAPI
//
//  Created by NSJ on 6/3/15.
//  Copyright (c) 2015 MGO. All rights reserved.
//

import UIKit

class LinkViewController: UIViewController {

    var fileIdentifier :String!
    var sharer : String!
    var expireation:NSDate!
    
    @IBOutlet weak var CtrlFileIdentifier: UILabel!
    
    @IBOutlet weak var CtrlExpiration: UILabel!
    
    @IBOutlet weak var CtrlSharer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CtrlFileIdentifier.text = "File Identifier :" + self.fileIdentifier
        
        if self.expireation != nil
        {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //format style. Browse online to get a format that fits your needs.
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            var dateString = dateFormatter.stringFromDate(self.expireation)
            CtrlExpiration.text = "Expiration Date: " + dateString
        }
        CtrlSharer.text = "Sharer: " + self.sharer
    }

    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
