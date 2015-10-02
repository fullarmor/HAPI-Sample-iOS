//
//  HAPIClient.swift
//  HAPI_iOS
//
//  Created by Scott Jackson on 3/19/15.
//  Copyright (c) 2015 FullArmor. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import CoreData

typealias ServiceResponse = (NSDictionary?, NSError?) -> Void

public class HAPIClient : HAPIClientBase
{
    // Threadsafe Singleton pattern for Swift
    public class var sharedInstance: HAPIClient
    {
        struct Static
        {
            static var instance: HAPIClient?;
            static var token: dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.token)
        {
            Static.instance = HAPIClient();
        }
        
        return Static.instance!;
    }
    
    public var ContextObject : AnyObject? = nil; // temporary variable for holding context

    // Helper Method for calling HAPI REST service
    func CallRestService(urlSuffix:String, fileIdentifier:String, filters:String, maxLevels:String) -> AnyObject
    {
        var postData: NSMutableDictionary = ["FileIdentifier":fileIdentifier, "Filters":filters, "MaxLevels":maxLevels];
        
        var resultData = HAPIClient.sharedInstance.HttpPost(urlSuffix, postDict: postData);
        
        var parseError: NSError?
        let parsedObject: AnyObject = NSJSONSerialization.JSONObjectWithData(resultData,
            options: NSJSONReadingOptions.AllowFragments,
            error:&parseError)!
        
        return parsedObject["Items"] as AnyObject!;
    }
    
    // HAPI Methods
    public func GetShares() -> [AnyObject]
    {
        return CallRestService("route/hapi/Shares/GetFilesAndFolders", fileIdentifier: "", filters: "[]", maxLevels: "0") as! [AnyObject];
    }
    
    public func GetShare(fileIdentifier : String) -> [AnyObject]
    {
        return CallRestService("route/hapi/Share/GetFilesAndFolders", fileIdentifier: fileIdentifier, filters: "[]", maxLevels: "0") as! [AnyObject];
    }
    
    public func GetLinks() -> [AnyObject]
    {
        let urlSuffix = "api/SharedFile/GetSharedFiles"
        var postData: NSMutableDictionary = ["Provider": "None", "IncludeExpired":true, "FileIdentifier_Checksum":0, UserSID: self.UserSID];
        
        var resultData = HAPIClient.sharedInstance.HttpPost(urlSuffix, postDict: postData);
        
        var parseError: NSError?
        let parsedObject: AnyObject = NSJSONSerialization.JSONObjectWithData(resultData,
            options: NSJSONReadingOptions.AllowFragments,
            error:&parseError)!
        
        return parsedObject["Items"] as! [AnyObject];
    }
    
    //typealias CompletionHandler = (obj:AnyObject?, success: Bool?) -> Void
    public func UploadFile(serverUrl: NSURL, filePath: NSURL, uploadFolder: String!)
    {
        let nsdata = NSData(contentsOfFile: filePath.path!)!
        
        UploadNSData(serverUrl, nsdata: nsdata, uploadFolder: uploadFolder, fileName: filePath.lastPathComponent!)
    }
    
    public func UploadNSData(serverUrl: NSURL, nsdata: NSData!, uploadFolder: String!, fileName: String!)
    {
        let bytesPerChunk = 1024*1024
        let numberOfChunk = Int(ceil(Double(nsdata.length) / Double(bytesPerChunk)))
        
        var i : Int
        var length : Int
        var totalLength = nsdata.length
        let mimeType = mimeTypeForPath(fileName)
        for i = 0; i < numberOfChunk; ++i {
            var lastChunk: Bool = false
            if i == (numberOfChunk - 1) {
                lastChunk = true
                length = totalLength
            }
            else
            {
                length = bytesPerChunk
                totalLength -= length
            }
            
            var offset : Int = i * bytesPerChunk
            var dataRange = NSRange(location: offset, length: length)
            
            var chunk: Int
            if numberOfChunk == 1 {
                chunk = 0
            } else {
                chunk = i + 1
            }
            
            var buffer : NSData = nsdata.subdataWithRange(dataRange)
            UploadFileInternal(serverUrl, fileName: fileName, uploadFolder: uploadFolder, chunk: chunk, offset: offset, length: length, lastChunk: lastChunk, mimeType: mimeType, data: buffer);
        }
    }
    
    func UploadFileInternal(serverurl: NSURL, fileName: String, uploadFolder: String!, chunk: Int, offset: Int, length: Int, lastChunk: Bool, mimeType: String!, data: NSData)
    {
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var request = NSMutableURLRequest(URL: serverurl, cachePolicy: cachePolicy, timeoutInterval: 2.0)
        request.HTTPMethod = "POST"
        
        // Set Content-Type in HTTP header.
        let boundaryConstant = generateBoundaryString()
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        //let mimeType = mimeTypeForPath(filePath.path!)
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(self.Token, forHTTPHeaderField: "HAPIToken")
        
        // Set data
        let body = NSMutableData()
        body.appendString("--\(boundaryConstant)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"fileidentifier\"\r\n\r\n\(uploadFolder)")
        body.appendString("\r\n--\(boundaryConstant)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"chunk\"\r\n\r\n\(chunk)")
        body.appendString("\r\n--\(boundaryConstant)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"chunkStart\"\r\n\r\n\(offset)")
        body.appendString("\r\n--\(boundaryConstant)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"collisionBehavior\"\r\n\r\n1")
        body.appendString("\r\n--\(boundaryConstant)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"totalLength\"\r\n\r\n\(length)")
        body.appendString("\r\n--\(boundaryConstant)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"lastChunk\"\r\n\r\n\(lastChunk)")
        body.appendString("\r\n--\(boundaryConstant)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\";filename=\"\(fileName); \"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.appendData(data)
        
        body.appendString("\r\n")
        body.appendString("--\(boundaryConstant)--\r\n")
        
        request.HTTPBody = body
        
        // Make an asynchronous call so as not to hold up other processes.
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response, dataObject, error) in
            if let apiError = error {
                self.UploadResult(error, success: false)
            } else {
                self.UploadResult(dataObject, success: true)
            }
        })
        
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func UploadResult(obj:AnyObject?, success: Bool?) -> Void {
        if success?.boolValue == false
        {
            //let alert = UIAlertController("Error", "Upload Failed", <#UIAlertControllerStyle#>.Alert)
        }
        else
        {
            CleanUpSharedData()
        }
    }
    
    func mimeTypeForPath(path: String) -> String {
        let pathExtension = path.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }
    
    func CleanUpSharedData() -> Void {
        let sharedefault = NSUserDefaults(suiteName: "group.com.fullarmor.hapi")
        if sharedefault != nil
        {
            sharedefault?.removeObjectForKey("fileKey")
            sharedefault?.removeObjectForKey("fileName")
        }
        
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
