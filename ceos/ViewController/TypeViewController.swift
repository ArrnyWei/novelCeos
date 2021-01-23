//
//  TypeViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/7/17.
//
//

import UIKit
import SDWebImage
import FBAudienceNetwork

class TypeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FBAdViewDelegate {

    @IBOutlet weak var listTableView: UITableView!
    var listArray = NSMutableArray();
    var pageIndex = 1;
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    let typeUrlDic = ["玄幻奇幻":"xuanhuan",
                      "都市言情":"yanqing",
                      "武俠仙俠":"xianxia",
                      "軍事歷史":"lishi",
                      "網遊競技":"wangyou",
                      "科幻靈異":"lingyi",
                      "女生同人":"tongren",
                      "二次元":"erciyuan",
                      "全本小說":"quanben"];
    
    let typePeopleUrlDic = ["玄幻魔法":"1",
                      "武俠修真":"2",
                      "歷史軍事":"4",
                      "推理":"5",
                      "網遊動漫":"6",
                      "科幻":"7",
                      "恐怖靈異":"8",
                      "穿越重生":"9",
                      "同人":"10",
                      "全本":"11"];
    
    var typeString = "";
    var selectDic = NSMutableDictionary();
    var adView:FBAdView?;
    var adView2:FBAdView?;
    var adView3:FBAdView?;
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = typeString;
        pageIndex = 1;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
//        appdelegate.viewController?.navigationItem.leftBarButtonItem = appdelegate.viewController?.backItem;
//        appdelegate.viewController?.navigationItem.setHidesBackButton(false, animated: true);
        
        getList();
        
        if appdelegate.fbAdCanOpen == true {
            adView = FBAdView(placementID: "156413368451300_156439721781998", adSize: kFBAdSizeHeight250Rectangle, rootViewController: self)
            
            adView!.frame = CGRect(x: 0, y: 0, width: (listTableView.frame.size.width), height: 250);
            adView!.delegate = self;
            adView!.loadAd();
            
            adView2 = FBAdView(placementID: "156413368451300_178250299600940", adSize: kFBAdSizeHeight250Rectangle, rootViewController: self)
            
            adView2!.frame = CGRect(x: 0, y: 0, width: (listTableView.frame.size.width), height: 250);
            adView2!.delegate = self;
            adView2!.loadAd();
            
            adView3 = FBAdView(placementID: "156413368451300_178250962934207", adSize: kFBAdSizeHeight250Rectangle, rootViewController: self)
            
            adView3!.frame = CGRect(x: 0, y: 0, width: (listTableView.frame.size.width), height: 250);
            adView3!.delegate = self;
            adView3!.loadAd();
        }
    }
    
    func getList() {
        
        if appdelegate.serverFrom == 0 {
            let tempDic = appdelegate.parse.getList(typeUrlDic[typeString]!, pageIndex: pageIndex);
            if tempDic.count > 0 {
                let tempArray = tempDic["List"] as! NSArray
                listArray.addObjects(from: tempArray as! [Any]);
            }
        }
        else {
            let tempDic = appdelegate.parse.getPeopleList(typePeopleUrlDic[typeString]!, pageIndex: pageIndex);
            
            if tempDic.count > 0 {
                let tempArray = tempDic["List"] as! NSArray
                listArray.addObjects(from: tempArray as! [Any]);
            }
        }
        listTableView.reloadData();
        
        pageIndex += 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if appdelegate.fbAdCanOpen == true {
            if indexPath.row < 11 {
                if indexPath.row % 5 != 0 && indexPath.row != 0 {
                    return 150;
                }
                else {
                    return 250;
                }
            }
            else {
                return 150;
            }
            
        }
        else {
            return 150
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if appdelegate.fbAdCanOpen == true {
            if indexPath.row < 11 {
                if indexPath.row % 5 != 0 && indexPath.row != 0 {
                    let index = indexPath.row - (indexPath.row / 5) - 1
                    selectDic = listArray[index] as! NSMutableDictionary;
                    performSegue(withIdentifier: "typeToNovel", sender: nil);
                }
            }
            else {
                let index = indexPath.row - 3
                selectDic = listArray[index] as! NSMutableDictionary;
                performSegue(withIdentifier: "typeToNovel", sender: nil);
            }
            
        }
        else{
            selectDic = listArray[indexPath.row] as! NSMutableDictionary;
            performSegue(withIdentifier: "typeToNovel", sender: nil);
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if appdelegate.fbAdCanOpen == true {
            if indexPath.row < 11 {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FbAdTableVIewCell")
                    
                    
                    cell?.contentView.addSubview(adView!)
                    
                    return cell!;
                }
                else if indexPath.row == 5{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FbAdTableVIewCell")
                    
                    
                    cell?.contentView.addSubview(adView2!)
                    
                    return cell!;
                }
                else if indexPath.row == 10{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FbAdTableVIewCell")
                    
                    
                    cell?.contentView.addSubview(adView3!)
                    
                    return cell!;
                }
                else {
                    
                    //            let index = (indexPath.row / 8 ) * 8 + indexPath.row % 8
                    let index = indexPath.row - (indexPath.row / 5) - 1
                    
                    
                    let tempDic = listArray[index] as! NSDictionary;
                    let cell = tableView.dequeueReusableCell(withIdentifier: "HotTableViewCell")
                    let imageView = cell?.viewWithTag(101) as! UIImageView;
                    //            imageView.sd_setImage(with: URL(string: tempDic["image"] as! String)!);
                    //        imageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
                    if (tempDic["image"] as! String).contains("http")  {
                        imageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
                    }
                    else {
                        imageView.sd_setImage(with: URL(string: "https:\(tempDic["image"] as! String)"), placeholderImage: UIImage(named: "fengmian")!)
                    }
                    
                    let titleLabel = cell?.viewWithTag(102) as! UILabel;
                    titleLabel.text = tempDic["title"] as? String;
                    
                    let authorLabel = cell?.viewWithTag(103) as! UILabel;
                    authorLabel.text = tempDic["author"] as? String
                    
                    let descLabel = cell?.viewWithTag(104) as! UILabel;
                    descLabel.text = tempDic["desc"] as? String
                    return cell!;
                }
            }
            else {
                let index = indexPath.row - 3
                
                
                let tempDic = listArray[index] as! NSDictionary;
                let cell = tableView.dequeueReusableCell(withIdentifier: "HotTableViewCell")
                let imageView = cell?.viewWithTag(101) as! UIImageView;
                //            imageView.sd_setImage(with: URL(string: tempDic["image"] as! String)!);
                //        imageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
                if (tempDic["image"] as! String).contains("http") {
                    imageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
                }
                else {
                    imageView.sd_setImage(with: URL(string: "https:\(tempDic["image"] as! String)"), placeholderImage: UIImage(named: "fengmian")!)
                }
                
                let titleLabel = cell?.viewWithTag(102) as! UILabel;
                titleLabel.text = tempDic["title"] as? String;
                
                let authorLabel = cell?.viewWithTag(103) as! UILabel;
                authorLabel.text = tempDic["author"] as? String
                
                let descLabel = cell?.viewWithTag(104) as! UILabel;
                descLabel.text = tempDic["desc"] as? String
                return cell!;
            }
            
        }
        else{
            let index = indexPath.row
            
            
            let tempDic = listArray[index] as! NSDictionary;
            let cell = tableView.dequeueReusableCell(withIdentifier: "HotTableViewCell")
            let imageView = cell?.viewWithTag(101) as! UIImageView;
            //            imageView.sd_setImage(with: URL(string: tempDic["image"] as! String)!);
            //        imageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
            if (tempDic["image"] as! String).contains("http") {
                imageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
            }
            else {
                imageView.sd_setImage(with: URL(string: "https:\(tempDic["image"] as! String)"), placeholderImage: UIImage(named: "fengmian")!)
            }
            
            let titleLabel = cell?.viewWithTag(102) as! UILabel;
            titleLabel.text = tempDic["title"] as? String;
            
            let authorLabel = cell?.viewWithTag(103) as! UILabel;
            authorLabel.text = tempDic["author"] as? String
            
            let descLabel = cell?.viewWithTag(104) as! UILabel;
            descLabel.text = tempDic["desc"] as? String
            return cell!;
        }
        
        
        
        
    }
    func adViewDidFinishHandlingClick(_ adView: FBAdView) {
        print("fibnish")
    }
    func adViewDidClick(_ adView: FBAdView) {
        print("add did click")
    }
    
    func adViewDidLoad(_ adView: FBAdView) {
        print ("adview Load")
    }
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        print("load error: \(error)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listArray.count > 0 {
            return listArray.count + 3;
        }
        else {
            return 0 ;
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom <= height {
            getList();
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "typeToNovel" {
            let destination = segue.destination as! NovelViewController;
            destination.novelUrl = selectDic["url"] as! String;
//            let backItem = UIBarButtonItem()
//            backItem.title = ""
//            navigationItem.backBarButtonItem = backItem
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
