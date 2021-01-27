//
//  SearchViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/7/20.
//
//

import UIKit
import WebKit

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate {

    
    @IBOutlet weak var searchTableView: UITableView!
    var searchText = "";
    var searchArray = NSMutableArray();
    var start = 1;
    let count = 20;
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
//    @IBOutlet weak var searchWebView: WKWebView!
    @IBOutlet weak var searchWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        searchWebView.loadRequest(URLRequest(url: URL(string: "http://cse.google.com/cse?cx=008945028460834109019%3Akn_kwux2xms&q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)#gsc.tab=0&gsc.q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&gsc.page=0")!));

        
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
       
        
        
        
        if (request.url?.absoluteString.contains("www.uukanshu.com/b/"))! {
            let tempArray = request.url!.absoluteString.components(separatedBy: "www.uukanshu.com/b/");
            let tempString = tempArray[1];
            let index = tempString.firstIndex(of: "/");
//            let index = tempString.prefix(upTo: <#T##Int#>)
            
            let substring = tempString.prefix(upTo: index!);
            
            let finalString = "/b/\(substring)/"
            
            appdelegate.viewController?.novelUrl = finalString;
            appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);
            return false
        }
        else if (request.url?.absoluteString.contains("www.uukanshu.net/b/"))! {
            let tempArray = request.url!.absoluteString.components(separatedBy: "www.uukanshu.net/b/");
            let tempString = tempArray[1];
            let index = tempString.firstIndex(of: "/");
            //            let index = tempString.prefix(upTo: <#T##Int#>)
            
            let substring = tempString.prefix(upTo: index!);
            
            let finalString = "/b/\(substring)/"
            
            appdelegate.viewController?.novelUrl = finalString;
            appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);
            return false
        }
       
      
        
        return true
    }
    
    func getSearchList() {
        appdelegate.httpRequest.search(searchText, start: "\(start)", count: "\(count)") { (result, error) in
            if error == nil {
                
                if let _ = (result!)["results"] as? NSArray {
                    self.searchArray.addObjects(from: (result!)["results"] as! [Any]);
                    DispatchQueue.main.sync(execute: {
                        self.searchTableView.reloadData();
                    })
                }
                else {
                    DispatchQueue.main.sync(execute: {
                        let alertViewController = UIAlertController(title: nil, message: "已經沒有資料", preferredStyle: UIAlertController.Style.alert);
                        alertViewController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: { (action) in
                            
                        }))
                        self.present(alertViewController, animated: true, completion: nil);
                        self.searchTableView.reloadData();
                    })
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempDic = searchArray[indexPath.row] as! NSDictionary;
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell")
        let imageView = cell?.viewWithTag(101) as! UIImageView;
//                    imageView.sd_setImage(with: URL(string: tempDic["image"] as! String)!);
//        imageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
        imageView.image = UIImage(named: "fengmian");
//
        let titleLabel = cell?.viewWithTag(102) as! UILabel;
        titleLabel.text = tempDic["titleNoFormatting"] as? String;
//
//        let authorLabel = cell?.viewWithTag(103) as! UILabel;
//        authorLabel.text = tempDic["author"] as? String
//        
        let descLabel = cell?.viewWithTag(104) as! UILabel;
        descLabel.text = tempDic["contentNoFormatting"] as? String
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tempDic = searchArray[indexPath.row] as! NSMutableDictionary;
        
        let urlString = (tempDic["url"] as! String).replacingOccurrences(of: "http://www.uukanshu.net", with: "");
        
        let urlArray = urlString.components(separatedBy: "/");
        
        let finalString = "/\(urlArray[1] )/\(urlArray[2] )"
        
        appdelegate.viewController?.novelUrl = finalString;
        appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom <= height {
            start += count;
            getSearchList();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
