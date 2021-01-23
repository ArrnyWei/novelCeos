
//
//  HttpRequestTools.swift
//  river
//
//  Created by shih-yenWei on 24/7/16.
//  Copyright © 2016年 Rytass. All rights reserved.
//

import UIKit
import Security

class HttpRequestTools: NSObject {
    let hostUrl = "https://www.beauty88.com.tw/";
    
    var getHeaders = [
        "cache-control": "no-cache"
    ]
    var postJSONUrlEncodedHeaders = [
        "cache-control": "no-cache",
        "content-type": "application/json"
    ]
    
    let postUrlEncodedHeaders = [
        "content-type": "application/x-www-form-urlencoded",
        "cache-control": "no-cache",
        "postman-token": "2d6ee619-f80d-6d43-99c7-0ae99aa58cec"
    ]

    
    var account = "";
    var pwd = "";
    
    var tempData:Data?;
    var tempError = "";
    var tempJSONError = "";
    var tempCode = "";
    
    func search(_ text:String, start:String, count:String, completion:@escaping (_ result:NSMutableDictionary?,_ error:String?) ->Void) {
       
        let request = NSMutableURLRequest(url: URL(string: "https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&rsz=filtered_cse&hl=zh_TW&prettyPrint=false&source=gcsc&gss=.com&sig=5392cbaa0b641a2ba70e25095e18ee0f&cx=008945028460834109019:kn_kwux2xms&googlehost=www.google.com&callback=google.search.Search.apiary2001&nocache=1439910452601&start=\(start)&num=\(count)&q=\(text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = getHeaders
        
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(nil,(error?.localizedDescription)!);
//                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse)
                
                if httpResponse?.statusCode == 200 {
                    
                    let resultString = String(data: data!, encoding: String.Encoding.utf8)!;
                    let resultData = (resultString.replacingOccurrences(of: "// API callback\ngoogle.search.Search.apiary2001(", with: "").replacingOccurrences(of: ");", with: "")).data(using: String.Encoding.utf8);
                    do {
                        let json = try JSONSerialization.jsonObject(with: resultData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSMutableDictionary
                        
                        completion(json,nil);
                    }
                    catch{
                        completion(nil,"JSON Error");
                        print(error);
                    }
                }
                else {
                    completion(["error":"YES"],nil);
                }
                
                
            }
        }).resume()
    }
    
    
}
