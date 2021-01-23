//
//  ContentViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/7/19.
//
//

import UIKit
import GoogleMobileAds


extension NSAttributedString {
    
    public convenience init?(HTMLString html: String, font: UIFont? = nil ,backcolor:UIColor,textColor:UIColor) throws {
        
//        let options = [
//            NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html,
//            NSAttributedString.DocumentAttributeKey.characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)
//        ]
        
        guard let data = html.data(using: .utf8, allowLossyConversion: true) else {
            throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
        }
        
        
        if let font = font {
            guard let attr = try? NSMutableAttributedString(data: data, options: [.documentType:NSAttributedString.DocumentType.html,.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil) else {
                throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
            }
            var attrs = attr.attributes(at: 0, effectiveRange: nil)
            attrs[NSAttributedString.Key.font] = font
            attrs[NSAttributedString.Key.foregroundColor] = textColor;
            attrs[NSAttributedString.Key.backgroundColor] = backcolor;
            attr.setAttributes(attrs, range: NSRange(location: 0, length: attr.length))
            
            self.init(attributedString: attr)
        } else {
            try? self.init(data: data, options: [.documentType:NSAttributedString.DocumentType.html,.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
        }
        
    }
    
}
extension String {
    
    //Range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!),
                       length: utf16.distance(from: from!, to: to!))
    }
    
    //Range转换为NSRange
    func toRange(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location,
                                     limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length,
                                   limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}
class ContentViewController: UIViewController , UITextViewDelegate{

    @IBOutlet weak var contentTextView: UITextView!
    var contentUrl = "";
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    var listId = "";
    var contentString = "";
    var faveId = "";
    var faveDic = NSMutableDictionary();
    @IBOutlet weak var bannerView: GADBannerView!
    var listArray = NSMutableArray();
    var novelId = "";
    var listIndex = 0;
    var contentRangeArray:[NSRange] = [];
    @IBOutlet weak var testView: UIView!
    var readReadViewControllers = NSMutableArray();
    var contentPageController : ReadPageViewController?;
    var sort = 0;
    var listTitle = "";
//    var cfiBannerView:MFBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.contentTextView.backgroundColor = appdelegate.backColor;
        appdelegate.inContent = true;
        
        
        bannerView.adUnitID = "ca-app-pub-6753518483501394/5840127384"
        bannerView.rootViewController = self;
        bannerView.load(GADRequest());
        self.title = listTitle;
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    func requestAdSuccess() {
//        cfiBannerView?.show();
        print("Success")
    }
    
    func requestAdFail() {
        print("fail")
    }
    
    func reloadContent() {
        
        if faveId.count != 0 {
            appdelegate.db.openDatabase();
            
            
            contentString = "";
            let queryString = "select content from content Where listId = \(listId)";
            let statement = self.appdelegate.db.executeQuery(queryString);
//            print("UPDATEWrong \(sqlite3_step(statement))")
            while (sqlite3_step(statement) == SQLITE_ROW){
                
                
                contentString = String(cString: sqlite3_column_text(statement, 0))
            }
            appdelegate.db.closeDatabase();
            
            if contentString == "" {
                if contentUrl.contains("mytxt.cc") || contentUrl.contains("read") {
                    let tempDic = appdelegate.parse.getPeopleContent(contentUrl);
                    if tempDic.count > 0 {
                        contentString = tempDic["newContent"] as! String
                    }
                    
                }
                else {
                    let tempDic = appdelegate.parse.getContent(contentUrl);
                    if tempDic.count > 0 {
                        contentString = tempDic["newContent"] as! String
                    }
                    
                }
            }
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyyMMddhhmmss";
            
            let nowstring = dateFormatter.string(from: Date());
            
            if appdelegate.readDirection == "vertical" {
                appdelegate.db.openDatabase();
                let sqlwaterDoor = "UPDATE favNovel SET frame = '\(contentTextView.contentOffset.y)',date = \(nowstring),listId = \(listId) Where id = \(faveId)";
                let statementwaterDoor = appdelegate.db.executeQuery(sqlwaterDoor);
                if (SQLITE_DONE != sqlite3_step(statementwaterDoor))
                {
                    print("UPDATEWrong \(sqlite3_step(statementwaterDoor))")
                }
                appdelegate.db.closeDatabase();
            }
            else {
                if contentPageController != nil {
                    if contentPageController?.pageNumber != readReadViewControllers.count - 1 {
                        appdelegate.db.openDatabase();
                        let sqlwaterDoor = "UPDATE favNovel SET frame = '\(Int(contentTextView.frame.size.height) * (contentPageController?.pageNumber)!)',date = \(nowstring),listId = \(listId) Where id = \(faveId)";
                        let statementwaterDoor = appdelegate.db.executeQuery(sqlwaterDoor);
                        if (SQLITE_DONE != sqlite3_step(statementwaterDoor))
                        {
                            print("UPDATEWrong \(sqlite3_step(statementwaterDoor))")
                        }
                        appdelegate.db.closeDatabase();
                    }
                    else{
                        appdelegate.db.openDatabase();
                        let sqlwaterDoor = "UPDATE favNovel SET frame = '\(Int(contentTextView.frame.size.height) * ((contentPageController?.pageNumber)! - 1))',date = \(nowstring),listId = \(listId) Where id = \(faveId)";
                        let statementwaterDoor = appdelegate.db.executeQuery(sqlwaterDoor);
                        if (SQLITE_DONE != sqlite3_step(statementwaterDoor))
                        {
                            print("UPDATEWrong \(sqlite3_step(statementwaterDoor))")
                        }
                        appdelegate.db.closeDatabase();
                    }
                }
                
            }
        }
        else {
            
            if contentUrl.contains("mytxt.cc") || contentUrl.contains("read") {
                let tempDic = appdelegate.parse.getPeopleContent(contentUrl);
                contentString = tempDic["newContent"] as! String
            }
            else {
                let tempDic = appdelegate.parse.getContent(contentUrl);
                contentString = tempDic["newContent"] as! String
            }
            
        }
        
        
        
        if appdelegate.readDirection == "vertical" {
            testView.isHidden = true;
            contentTextView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false);
            contentTextView.attributedText = NSMutableAttributedString(string: contentString, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: appdelegate.textSize),NSAttributedString.Key.foregroundColor:appdelegate.textColor,NSAttributedString.Key.backgroundColor:appdelegate.backColor])
            
        }
        else {  
            
            contentRangeArray = ParserPageRange(string: contentString);
            readReadViewControllers.removeAllObjects();
            var pageCount = 0;
            for range in contentRangeArray {
                
                let newContent = contentString.substring(with: Range.init(range, in: contentString)!)
                
                
                let readViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReadViewController") as! ReadViewController;
                readViewController.content = newContent;
                readViewController.pageNumber = pageCount;
                readViewController.setFrame(CGRect(x: 0, y: 0, width: testView.frame.size.width, height: testView.frame.size.height))
                
                readReadViewControllers.add(readViewController);
                pageCount += 1;
            }
            
            if appdelegate.fbAdCanOpen == true {
                let fbAdViewController = self.storyboard?.instantiateViewController(withIdentifier: "FBAdViewController") as! FBAdViewController;
                fbAdViewController.view.frame = CGRect(x: 0, y: 0, width: testView.frame.size.width, height: testView.frame.size.height);
                fbAdViewController.pageNumber = pageCount;
                
                readReadViewControllers.add(fbAdViewController);
            }
            
            
            
            let options = [UIPageViewController.OptionsKey.spineLocation:NSNumber(value: UIPageViewController.SpineLocation.min.rawValue as Int)]
            if contentPageController != nil {
                contentPageController?.view.removeFromSuperview();
                contentPageController?.removeFromParent();
                contentPageController = nil;
            }
            contentPageController = ReadPageViewController(transitionStyle: UIPageViewController.TransitionStyle.pageCurl, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: options);
            
            
            contentPageController?.view.frame = CGRect(x: 0, y: 0, width: testView.frame.size.width, height: testView.frame.size.height)
            
            testView.insertSubview(contentPageController!.view, at: 0);
        
            
            addChild(contentPageController!);
            
            contentPageController?.readViewControllerArray = readReadViewControllers;
            
            
            contentPageController?.setViewControllers([(readReadViewControllers as! [ReadViewController])[0]] , direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil);
        }
        
//        let item = self.navigationItem.backBarButtonItem;
//        let buttom = item!.customView as! UIButton;
//        buttom.setTitle(listTitle, for: UIControlState.normal);
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: listTitle, style: UIBarButtonItemStyle.plain, target: nil, action: nil);
        
    }
    func ParserPageRange(string:String) -> [NSRange]  {
        
        // 记录
        var rangeArray:[NSRange] = [];
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        // 行间距
        paragraphStyle.lineSpacing = appdelegate.lineSpace
        
        // 段间距
        paragraphStyle.paragraphSpacing = 2
        
        // 当前行间距(lineSpacing)的倍数(可根据字体大小变化修改倍数)
        paragraphStyle.lineHeightMultiple = 1.0
        
        // 对其
        paragraphStyle.alignment = NSTextAlignment.justified
        
        let attributedString = NSMutableAttributedString(string: string,attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: appdelegate.textSize),NSAttributedString.Key.foregroundColor:appdelegate.textColor,NSAttributedString.Key.backgroundColor:appdelegate.backColor,NSAttributedString.Key.paragraphStyle:paragraphStyle])
        // 拼接字符串
//        let attrString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: appdelegate.textSize),NSForegroundColorAttributeName:appdelegate.textColor,NSBackgroundColorAttributeName:appdelegate.backColor])
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: testView.frame.size.width, height: testView.frame.size.height), transform: nil)
        
        var range = CFRangeMake(0, 0)
        
        var rangeOffset:NSInteger = 0
        
        repeat{
            
            let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(rangeOffset, 0), path, nil)
            
            range = CTFrameGetVisibleStringRange(frame)
            
            rangeArray.append(NSMakeRange(rangeOffset, range.length))
//            let newRange:Range = rangeOffset..<(range.length + 1 + rangeOffset);
//            rangeArray.add(newRange)
            
            
            rangeOffset += range.length
            
        }while(range.location + range.length < attributedString.length)
        
        
        return rangeArray
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        reloadContent();
        
        
        if faveId.count != 0 {
            
            appdelegate.db.openDatabase();
            
            var hasContent = false;
            
            var queryString = "select * from content Where listId = \(listId)";
            var statement = self.appdelegate.db.executeQuery(queryString);
            while (sqlite3_step(statement) == SQLITE_ROW){
                
                hasContent = true;
                
            }
            
            
            if hasContent == false {
                let insertString = "INSERT INTO content (\"listId\" , \"content\" ) VALUES('\(listId)','\(contentString)')";
                let insertstatement = appdelegate.db.executeQuery(insertString);
                
                if SQLITE_DONE != sqlite3_step(insertstatement) {
                    print(sqlite3_step(insertstatement))
                }
                
                
            }
            
            
            queryString = "select * from favNovel where id = \(faveId)";
            statement = self.appdelegate.db.executeQuery(queryString);
            while (sqlite3_step(statement) == SQLITE_ROW){
                faveDic.setValue("\(sqlite3_column_int(statement, 0))", forKey: "id");
                faveDic.setValue("\(sqlite3_column_int(statement, 1))", forKey: "novelId");
                faveDic.setValue("\(sqlite3_column_int(statement, 2))", forKey: "listId");
                faveDic.setValue(String(cString: sqlite3_column_text(statement, 3)), forKey: "frame");
                faveDic.setValue("\(sqlite3_column_int(statement, 4))", forKey: "date");
            }
            
            let y = Float(faveDic["frame"] as! String)!
            
            if faveDic["listId"] as! String == listId {
                if appdelegate.readDirection == "vertical" {
                    contentTextView.setContentOffset(CGPoint(x: 0, y: CGFloat(y)), animated: true);
                }
                else {
                    let pagenumber = Int(CGFloat(y) / contentTextView.frame.size.height);
                    contentPageController?.setViewControllers([(readReadViewControllers as! [ReadViewController])[pagenumber]] , direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil);
                }
                
            }
            appdelegate.db.closeDatabase();
        }
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
//        appdelegate.viewController?.navigationItem.leftBarButtonItem = appdelegate.viewController?.backItem;
        
//        if faveId.count != 0 {
//            let dateFormatter = DateFormatter();
//            dateFormatter.dateFormat = "yyyyMMddhhmmss";
//            
//            let nowstring = dateFormatter.string(from: Date());
//            
//            if appdelegate.readDirection == "vertical" {
//                appdelegate.db.openDatabase();
//                let sqlwaterDoor = "UPDATE favNovel SET frame = '\(contentTextView.contentOffset.y)',date = \(nowstring),listId = \(listId) Where id = \(faveId)";
//                let statementwaterDoor = appdelegate.db.executeQuery(sqlwaterDoor);
//                if (SQLITE_DONE != sqlite3_step(statementwaterDoor))
//                {
//                    print("UPDATEWrong \(sqlite3_step(statementwaterDoor))")
//                }
//                appdelegate.db.closeDatabase();
//            }
//            else {
//                if contentPageController?.pageNumber != readReadViewControllers.count - 1 {
//                    appdelegate.db.openDatabase();
//                    let sqlwaterDoor = "UPDATE favNovel SET frame = '\(Int(contentTextView.frame.size.height) * (contentPageController?.pageNumber)!)',date = \(nowstring),listId = \(listId) Where id = \(faveId)";
//                    let statementwaterDoor = appdelegate.db.executeQuery(sqlwaterDoor);
//                    if (SQLITE_DONE != sqlite3_step(statementwaterDoor))
//                    {
//                        print("UPDATEWrong \(sqlite3_step(statementwaterDoor))")
//                    }
//                    appdelegate.db.closeDatabase();
//                }
//                else{
//                    appdelegate.db.openDatabase();
//                    let sqlwaterDoor = "UPDATE favNovel SET frame = '\(Int(contentTextView.frame.size.height) * ((contentPageController?.pageNumber)! - 1))',date = \(nowstring),listId = \(listId) Where id = \(faveId)";
//                    let statementwaterDoor = appdelegate.db.executeQuery(sqlwaterDoor);
//                    if (SQLITE_DONE != sqlite3_step(statementwaterDoor))
//                    {
//                        print("UPDATEWrong \(sqlite3_step(statementwaterDoor))")
//                    }
//                    appdelegate.db.closeDatabase();
//                }
//            }
//        }
        appdelegate.inContent = false;

    }
    @IBAction func upClick(_ sender: UIButton) {
        
        if sort == 1 {
            if listIndex < listArray.count - 1 {
                listIndex += 1;
                if faveId.count != 0 {
                    listId = (listArray[listIndex] as! NSMutableDictionary)["listId"] as! String;
                }
                contentUrl = (listArray[listIndex] as! NSMutableDictionary)["url"] as! String;
                self.title = (listArray[listIndex] as! NSMutableDictionary)["title"] as? String;
                reloadContent();
            }
            else {
                let alertController = UIAlertController(title: "錯誤", message: "已經是最前一章", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: nil));
                
                present(alertController, animated: true, completion: nil);
            }
        }
        else {
            if listIndex != 0 {
                
                listIndex -= 1;
                if faveId.count != 0 {
                    listId = (listArray[listIndex] as! NSMutableDictionary)["listId"] as! String;
                }
                contentUrl = (listArray[listIndex] as! NSMutableDictionary)["url"] as! String;
                self.title = (listArray[listIndex] as! NSMutableDictionary)["title"] as? String;
                reloadContent();
            }
            else {
                let alertController = UIAlertController(title: "錯誤", message: "已經是最前一章", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: nil));
                
                present(alertController, animated: true, completion: nil);
            }
            
        }
    }
    func pageReloadUp(){
        self.upClick(UIButton());
    }
    
    func pageReloadDown(){
        self.downClick(UIButton());
    }
    
    @IBAction func downClick(_ sender: UIButton) {
        if sort == 1 {
            if listIndex != 0 {
                
                listIndex -= 1;
                if faveId.count != 0 {
                    listId = (listArray[listIndex] as! NSMutableDictionary)["listId"] as! String;
                }
                contentUrl = (listArray[listIndex] as! NSMutableDictionary)["url"] as! String;
                self.title = (listArray[listIndex] as! NSMutableDictionary)["title"] as? String;
                reloadContent();
            }
            else {
                let alertController = UIAlertController(title: "錯誤", message: "已經是最後一章", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: nil));
                
                present(alertController, animated: true, completion: nil);
            }
        }
        else {
            if listIndex < listArray.count - 1 {
                listIndex += 1;
                if faveId.count != 0 {
                    listId = (listArray[listIndex] as! NSMutableDictionary)["listId"] as! String;
                }
                contentUrl = (listArray[listIndex] as! NSMutableDictionary)["url"] as! String;
                self.title = (listArray[listIndex] as! NSMutableDictionary)["title"] as? String;
                reloadContent();
            }
            else {
                let alertController = UIAlertController(title: "錯誤", message: "已經是最後一章", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: nil));
                
                present(alertController, animated: true, completion: nil);
            }
           
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

