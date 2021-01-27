//
//  NovelViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/7/18.
//
//

import UIKit
import SDWebImage
import MBProgressHUD

class NovelViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    var novelArray = NSMutableArray();
    var novelUrl = "";
    var novelDic = NSMutableDictionary();
    @IBOutlet weak var novelTableView: UITableView!
    var selectDic = NSMutableDictionary();
    var favId = "";
    var hasFav = false;
    var novelId = "";
    var sortItem:UIBarButtonItem?;
    var sort = 0;
    var favListId = "";
    var firstIn = false
    var selectIndex = 0;
    var listIndex = -1;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        novelTableView.rowHeight = UITableView.automaticDimension
        novelTableView.estimatedRowHeight = 150;
        
        sortItem = UIBarButtonItem(title: "正序", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NovelViewController.sortClick(_:)));
        sortItem?.tintColor = UIColor.white;
        navigationItem.rightBarButtonItem = sortItem;
        
    }
    @objc func sortClick(_ sender: UIBarButtonItem) {
        if sort == 0 {
            sort = 1;
            sortItem?.title = "正序"
            
        }
        else {
            sort = 0;
            sortItem?.title = "倒序"
            
        }
        novelArray = NSMutableArray(array: novelArray.reversed())  ;
        
        novelTableView.reloadData();
        novelTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        appdelegate.viewController?.centerViewHeight.constant = 35;
        
        if firstIn == false {
            self.present((appdelegate.viewController?.loadingAlertController)!, animated: true) {
                self.performSelector(inBackground: #selector(NovelViewController.reloadData), with: nil);
            }
        }
        else {
            if favId.count != 0 {
                self.performSelector(inBackground: #selector(NovelViewController.reloadData), with: nil);
            }
        }
        
    }
    
    @objc func reloadData(){
        firstIn = true
        appdelegate.db.openDatabase();
        
        var hasNovel = false;
        var queryString = "select * from novel Where url = \"\(novelUrl)\"";
        var statement = self.appdelegate.db.executeQuery(queryString);
        while (sqlite3_step(statement) == SQLITE_ROW){
            hasNovel = true;
            novelId = "\(sqlite3_column_int(statement, 0))";
        }
        
        if hasNovel == true {
            queryString = "select * from favNovel Where novelId = \"\(novelId)\"";
            statement = self.appdelegate.db.executeQuery(queryString);
            while (sqlite3_step(statement) == SQLITE_ROW){
                
                hasFav = true;
                
                favId = "\(sqlite3_column_int(statement, 0))";
                favListId = "\(sqlite3_column_int(statement, 2))";
                
            }
            
            if hasFav == true {
                novelDic = (appdelegate.viewController?.mainContentDic)!;
                novelArray = NSMutableArray();
                
                var count = 0;
                var queryString = "select count(*) from list Where novelId = \(novelId)";
                var statement = self.appdelegate.db.executeQuery(queryString);
                if (sqlite3_step(statement) == SQLITE_ROW) {

                    count = Int(sqlite3_column_int(statement, 0));

                }
                sqlite3_finalize(statement);
                
                var onlineNovelDic = NSMutableDictionary();
                if novelUrl.contains("mytxt.cc") || novelUrl.contains("read") {
                    onlineNovelDic = appdelegate.parse.getPeopleNovel(novelUrl) as! NSMutableDictionary;
                    if (onlineNovelDic["List"] as! NSMutableArray).count == 0 {
                        onlineNovelDic = appdelegate.parse.getPeopleNovel(novelUrl) as! NSMutableDictionary;
                    }
                }
                else {
                    onlineNovelDic = appdelegate.parse.getNovel(novelUrl) as! NSMutableDictionary;
                }
                
                if onlineNovelDic.count > 0 {
                    if (onlineNovelDic["List"] as! NSMutableArray).count > count {
                        if sort == 0 {
                            for i in stride(from: count , to: (onlineNovelDic["List"] as! NSMutableArray).count  , by: 1) {
                                
                                let finalList = (onlineNovelDic["List"] as! NSMutableArray)[i] as! NSMutableDictionary
                                var hasList = false;
                                //                            appdelegate.db.openDatabase();
                                let queryString = "select * from list Where url = \"\(finalList["url"] as! String)\"";
                                let statement = self.appdelegate.db.executeQuery(queryString);
                                while (sqlite3_step(statement) == SQLITE_ROW){
                                    
                                    hasList = true;
                                    finalList.setValue("\(sqlite3_column_int(statement, 0))", forKey: "listId")
                                    
                                }
                                
                                if hasList == false {
                                    let insertString = "INSERT INTO list (\"novelId\" , \"name\" , \"url\") VALUES(\(novelId),'\(finalList["title"] as! String)','\(finalList["url"] as! String)')";
                                    let insertstatement = appdelegate.db.executeQuery(insertString);
                                    
                                    if SQLITE_DONE == sqlite3_step(insertstatement) {
                                        
                                        let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
                                        
                                        finalList.setValue("\(Int(lastRowId))", forKey: "listId")
                                    }
                                    else {
                                        print("error")
                                    }
                                }
                                //                            appdelegate.db.closeDatabase();
                                
                            }
                        }
                        else {
                            for i in stride(from: (onlineNovelDic["List"] as! NSMutableArray).count - 1 , through: count - 1, by: -1) {
                                //                            appdelegate.db.openDatabase();
                                let finalList = (onlineNovelDic["List"] as! NSMutableArray)[i] as! NSMutableDictionary
                                var hasList = false;
                                
                                let queryString = "select * from list Where url = \"\(finalList["url"] as! String)\"";
                                let statement = self.appdelegate.db.executeQuery(queryString);
                                while (sqlite3_step(statement) == SQLITE_ROW){
                                    
                                    hasList = true;
                                    finalList.setValue("\(sqlite3_column_int(statement, 0))", forKey: "listId")
                                    
                                }
                                
                                if hasList == false {
                                    let insertString = "INSERT INTO list (\"novelId\" , \"name\" , \"url\") VALUES(\(novelId),'\(finalList["title"] as! String)','\(finalList["url"] as! String)')";
                                    let insertstatement = appdelegate.db.executeQuery(insertString);
                                    
                                    if SQLITE_DONE == sqlite3_step(insertstatement) {
                                        
                                        let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
                                        
                                        finalList.setValue("\(Int(lastRowId))", forKey: "listId")
                                    }
                                    else {
                                        print("error")
                                    }
                                }
                                //                            appdelegate.db.closeDatabase();
                                
                            }
                            
                        }
                    }
                }
                
                
                
//                appdelegate.db.openDatabase();
                queryString = "select * from list Where novelId = \(novelId)";
                statement = self.appdelegate.db.executeQuery(queryString);
                while (sqlite3_step(statement) == SQLITE_ROW){
                    
                    let finalList = NSMutableDictionary();
                    finalList.setValue("\(sqlite3_column_int(statement, 0))", forKey: "listId")
                    finalList.setValue(String(cString: sqlite3_column_text(statement, 2)), forKey: "title")
                    finalList.setValue(String(cString: sqlite3_column_text(statement, 3)), forKey: "url")
                    
                    if finalList["listId"] as! String == favListId {
                        listIndex = novelArray.count;
                    }
                    
                    novelArray.add(finalList);
                }
//                appdelegate.db.closeDatabase();
                
//                appdelegate.db.openDatabase()
                for tempDic in novelArray {
                    let finalDic = tempDic as! NSMutableDictionary;
                    
                    var hasContent = false;
                    
                    let queryString = "select * from content Where listId = \(finalDic["listId"] as! String)";
                    let statement = self.appdelegate.db.executeQuery(queryString);
                    while (sqlite3_step(statement) == SQLITE_ROW){
                        hasContent = true;
                    }
                    
                    finalDic.setValue(hasContent, forKey: "offline");
                    
                }
//                appdelegate.db.closeDatabase()
                
                novelDic.setValue(novelArray, forKey: "List");
                
                if (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("第一章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("第1章")  || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("1章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("一章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("楔子"){
                    //順
                    
                    if sort == 0 {
                        novelArray = novelDic["List"] as! NSMutableArray;
                        sortItem?.title = "倒序"
                    }
                    else {
//                        novelArray = (novelDic["List"] as! NSMutableArray).reversed() as! NSMutableArray;
                        novelArray = NSMutableArray(array: (novelDic["List"] as! NSMutableArray).reversed());
                        sortItem?.title = "正序"
                    }
                    
                    
                    
                }
                else {
                    
                    if sort == 0 {
                        novelArray = NSMutableArray(array: (novelDic["List"] as! NSMutableArray).reversed());
                        sortItem?.title = "倒序"
                    }
                    else {
                        novelArray = novelDic["List"] as! NSMutableArray;
                        sortItem?.title = "正序"
                    }
                    
                }
                
                
                
                
                if listIndex != -1 {
                    
                    DispatchQueue.main.sync {
//                        appdelegate.db.closeDatabase();
                        self.reloadUI();
                        novelTableView.scrollToRow(at: IndexPath(row: listIndex, section: 1), at: UITableView.ScrollPosition.top, animated: false);
                    }
                    
                }
                else {
                    DispatchQueue.main.sync {
//                        appdelegate.db.closeDatabase();
                        self.reloadUI();
                    }
                }
                
                
            }
            else {
                
                if novelUrl.contains("mytxt.cc") || novelUrl.contains("read") {
                    novelDic = appdelegate.parse.getPeopleNovel(novelUrl) as! NSMutableDictionary;
                    if (novelDic["List"] as! NSMutableArray).count == 0 {
                        novelDic = appdelegate.parse.getPeopleNovel(novelUrl) as! NSMutableDictionary;
                    }
                }
                else {
                    novelDic = appdelegate.parse.getNovel(novelUrl) as! NSMutableDictionary;
                }
                
                if (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("第一章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("第1章")  || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("1章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("一章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("楔子"){
                    //順
                    if sort == 0 {
                        novelArray = novelDic["List"] as! NSMutableArray;
                        sortItem?.title = "倒序"
                    }
                    else {
                        novelArray = NSMutableArray(array: (novelDic["List"] as! NSMutableArray).reversed());
                        sortItem?.title = "正序"
                    }
                }
                else {
                    if sort == 0 {
                        novelArray = NSMutableArray(array: (novelDic["List"] as! NSMutableArray).reversed());
                        sortItem?.title = "倒序"
                    }
                    else {
                        novelArray = novelDic["List"] as! NSMutableArray;
                        sortItem?.title = "正序"
                    }
                }
                appdelegate.db.closeDatabase();
                DispatchQueue.main.sync {
                    self.reloadUI();
                }
            }
        }
        else {
            if novelUrl.contains("mytxt.cc") || novelUrl.contains("read") {
                novelDic = appdelegate.parse.getPeopleNovel(novelUrl) as! NSMutableDictionary;
                if (novelDic["List"] as! NSMutableArray).count == 0 {
                    novelDic = appdelegate.parse.getPeopleNovel(novelUrl) as! NSMutableDictionary;
                }
            }
            else {
                novelDic = appdelegate.parse.getNovel(novelUrl) as! NSMutableDictionary;
            }
            
            if (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("第一章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("第1章")  || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("1章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("一章") || (((novelDic["List"] as! NSMutableArray)[0] as! NSMutableDictionary)["title"] as! String).contains("楔子"){
                //順
                
                if sort == 0 {
                    novelArray = novelDic["List"] as! NSMutableArray;
                    sortItem?.title = "倒序"
                }
                else {
                    novelArray = NSMutableArray(array: (novelDic["List"] as! NSMutableArray).reversed());
                    sortItem?.title = "正序"
                }
            }
            else {
                if sort == 0 {
                    novelArray = NSMutableArray(array: (novelDic["List"] as! NSMutableArray).reversed());
                    sortItem?.title = "倒序"
                }
                else {
                    novelArray = novelDic["List"] as! NSMutableArray;
                    sortItem?.title = "正序"
                }
            }
            
            appdelegate.db.closeDatabase();
            DispatchQueue.main.sync {
                self.reloadUI();
            }
        }
        
        
    }
    
    func reloadUI(){
        title = novelDic["title"] as? String;
        novelTableView.reloadData();
        self.dismiss(animated: true, completion: nil);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension;
        }
        else {
            return 44;
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if novelDic.count > 0 {
                return 1;
            }
            else {
                return 0;
            }
            
        }
        else {
            return novelArray.count;
        }
        
    }
    
    @objc func downClick(_ sender:UIButton) {
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view!)!, animated: true);
        hud.mode = MBProgressHUDMode.annularDeterminate;
        hud.label.text = "下載中..\n";
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.download();
            DispatchQueue.main.async(execute: {
                self.hasFav = true;
                self.novelTableView.reloadData();
                hud.hide(animated: true);
                let alertAlertController = UIAlertController(title: nil, message: "下載成功", preferredStyle: UIAlertController.Style.alert);
                
                alertAlertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: { (action) in
                    
                }));
                
                self.present(alertAlertController, animated: true, completion: nil);
            })
        }
        
    }
    
    func download() {
        // 已下載
        
        appdelegate.db.openDatabase();
        let dateFormatter = DateFormatter();
        
        var hasNovel = false;
        let queryString = "select * from novel Where url = \"\(novelUrl)\"";
        let statement = self.appdelegate.db.executeQuery(queryString);
        while (sqlite3_step(statement) == SQLITE_ROW){
            hasNovel = true;
            novelId = "\(sqlite3_column_int(statement, 0))";
        }
        
        if hasNovel == false {
            
            let insertString = "INSERT INTO novel (\"title\" , \"author\" , \"desc\", \"url\", \"imageUrl\" ) VALUES('\(novelDic["title"] as! String)','\(novelDic["author"] as! String)','\(novelDic["desc"] as! String)','\(novelUrl)','\(novelDic["image"] as! String)')";
            let insertstatement = appdelegate.db.executeQuery(insertString);
            
            if SQLITE_DONE == sqlite3_step(insertstatement) {
                
                let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
                novelId = "\(Int(lastRowId))"
            }
            else {
                print("error")
            }
        }
        
        var downArray = NSMutableArray();
        
        if sort == 0 {
            downArray = novelArray
        }
        else {
            downArray = NSMutableArray(array: novelArray.reversed());
        }
        
        
        for i in stride(from: 0 , to: downArray.count, by: 1) {
            
            let finalList = (novelDic["List"] as! NSMutableArray)[i] as! NSMutableDictionary
            var hasList = false;
            
            var queryString = "select * from list Where url = \"\(finalList["url"] as! String)\"";
            var statement = self.appdelegate.db.executeQuery(queryString);
            while (sqlite3_step(statement) == SQLITE_ROW){
                
                hasList = true;
                finalList.setValue("\(sqlite3_column_int(statement, 0))", forKey: "listId")
                
            }
            
            if hasList == false {
                let insertString = "INSERT INTO list (\"novelId\" , \"name\" , \"url\") VALUES(\(novelId),'\(finalList["title"] as! String)','\(finalList["url"] as! String)')";
                let insertstatement = appdelegate.db.executeQuery(insertString);
                
                if SQLITE_DONE == sqlite3_step(insertstatement) {
                    
                    let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
                    
                    finalList.setValue("\(Int(lastRowId))", forKey: "listId")
                }
                else {
                    print("error")
                }
            }
            
            let tempDic = appdelegate.parse.getContent(finalList["url"] as! String);
            
            var hasContent = false;
            
            queryString = "select * from content Where listId = \(finalList["listId"] as! String)";
            statement = self.appdelegate.db.executeQuery(queryString);
            while (sqlite3_step(statement) == SQLITE_ROW){
                
                hasContent = true;
                
            }
            
            
            if hasContent == false {
                let insertString = "INSERT INTO content (\"listId\" , \"content\" ) VALUES('\(finalList["listId"] as! String)','\(tempDic["newContent"] as! String)')";
                let insertstatement = appdelegate.db.executeQuery(insertString);
                
                if SQLITE_DONE != sqlite3_step(insertstatement) {
                    print("error")
                }
                
            }
            DispatchQueue.main.async {
                MBProgressHUD(for: (self.navigationController?.view)!)?.progress = Float(i) / Float ((self.novelDic["List"] as! NSMutableArray).count);
                MBProgressHUD(for: (self.navigationController?.view)!)?.label.text = "(\(i) / \((self.novelDic["List"] as! NSMutableArray).count))";
            }
            
        }
        
        dateFormatter.dateFormat = "yyyyMMddhhmmss";
        
        let nowstring = dateFormatter.string(from: Date());
        
        
        let insertString = "INSERT INTO favNovel (\"novelId\" , \"listId\" , \"frame\" ,\"date\") VALUES(\(novelId),\(((novelDic["List"] as! NSArray)[0] as! NSDictionary)["listId"] as! String),'0',\(nowstring))";
        let insertstatement = appdelegate.db.executeQuery(insertString);
        
        if SQLITE_DONE == sqlite3_step(insertstatement) {
            let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
            favId = "\(Int(lastRowId))"
        }
        else {
            print("error")
        }
        appdelegate.db.closeDatabase();
        
        
    }
    
    @objc func favClick(_ sender:UIButton) {
        if hasFav == true {
            appdelegate.db.openDatabase();
            let insertString = "DELETE From favNovel Where id = \(favId)";
            let insertstatement = appdelegate.db.executeQuery(insertString);
            
            if SQLITE_DONE != sqlite3_step(insertstatement) {
                print("error")
            }
            
            appdelegate.db.closeDatabase();
            hasFav = !hasFav;
            novelTableView.reloadData();
        }
        else {
            let addloadingAlertController = UIAlertController(title: nil, message: "加入中...\n", preferredStyle: UIAlertController.Style.alert);
            let indicator = UIActivityIndicatorView(frame: (addloadingAlertController.view.bounds));
            indicator.frame = CGRect(x: indicator.frame.origin.x, y: indicator.frame.origin.y + 15, width: indicator.frame.size.width, height: indicator.frame.size.height)
            indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight];
            indicator.style = UIActivityIndicatorView.Style.gray;
            //        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge;
            
            addloadingAlertController.view.addSubview(indicator);
            
            indicator.isUserInteractionEnabled = false;
            indicator.startAnimating();
            
            self.present(addloadingAlertController, animated: true, completion: { 
                self.performSelector(inBackground: #selector(NovelViewController.addFav), with: nil);
            })
        }
        
    }
    
    @objc func addFav() {
        appdelegate.db.openDatabase();
        let dateFormatter = DateFormatter();
        
        var hasNovel = false;
        let queryString = "select * from novel Where url = \"\(novelUrl)\"";
        let statement = self.appdelegate.db.executeQuery(queryString);
        while (sqlite3_step(statement) == SQLITE_ROW){
            hasNovel = true;
            novelId = "\(sqlite3_column_int(statement, 0))";
        }
        
        if hasNovel == false {
            
            let insertString = "INSERT INTO novel (\"title\" , \"author\" , \"desc\", \"url\", \"imageUrl\" ) VALUES('\(novelDic["title"] as! String)','\(novelDic["author"] as! String)','\(novelDic["desc"] as! String)','\(novelUrl)','\(novelDic["image"] as! String)')";
            let insertstatement = appdelegate.db.executeQuery(insertString);
            
            if SQLITE_DONE == sqlite3_step(insertstatement) {
                
                let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
                novelId = "\(Int(lastRowId))"
            }
            else {
                print("error")
            }
        }
        
        
        if sort == 0 {
            for i in stride(from: 0 , to: (novelDic["List"] as! NSMutableArray).count , by: 1) {
                
                let finalList = (novelDic["List"] as! NSMutableArray)[i] as! NSMutableDictionary
                var hasList = false;
                
                let queryString = "select * from list Where url = \"\(finalList["url"] as! String)\"";
                let statement = self.appdelegate.db.executeQuery(queryString);
                while (sqlite3_step(statement) == SQLITE_ROW){
                    
                    hasList = true;
                    finalList.setValue("\(sqlite3_column_int(statement, 0))", forKey: "listId")
                    
                }
                
                if hasList == false {
                    let insertString = "INSERT INTO list (\"novelId\" , \"name\" , \"url\") VALUES(\(novelId),'\(finalList["title"] as! String)','\(finalList["url"] as! String)')";
                    let insertstatement = appdelegate.db.executeQuery(insertString);
                    
                    if SQLITE_DONE == sqlite3_step(insertstatement) {
                        
                        let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
                        
                        finalList.setValue("\(Int(lastRowId))", forKey: "listId")
                    }
                    else {
                        print("error")
                    }
                }
                
            }
        }
        else {
            for i in stride(from: (novelDic["List"] as! NSMutableArray).count - 1 , through: 0, by: -1) {
                
                let finalList = (novelDic["List"] as! NSMutableArray)[i] as! NSMutableDictionary
                var hasList = false;
                
                let queryString = "select * from list Where url = \"\(finalList["url"] as! String)\"";
                let statement = self.appdelegate.db.executeQuery(queryString);
                while (sqlite3_step(statement) == SQLITE_ROW){
                    
                    hasList = true;
                    finalList.setValue("\(sqlite3_column_int(statement, 0))", forKey: "listId")
                    
                }
                
                if hasList == false {
                    let insertString = "INSERT INTO list (\"novelId\" , \"name\" , \"url\") VALUES(\(novelId),'\(finalList["title"] as! String)','\(finalList["url"] as! String)')";
                    let insertstatement = appdelegate.db.executeQuery(insertString);
                    
                    if SQLITE_DONE == sqlite3_step(insertstatement) {
                        
                        let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
                        
                        finalList.setValue("\(Int(lastRowId))", forKey: "listId")
                    }
                    else {
                        print("error")
                    }
                }
                
            }
        }
        
        
        
        dateFormatter.dateFormat = "yyyyMMddhhmmss";
        
        let nowstring = dateFormatter.string(from: Date());
        
        
        let insertString = "INSERT INTO favNovel (\"novelId\" , \"listId\" , \"frame\" ,\"date\") VALUES(\(novelId),\(((novelDic["List"] as! NSArray)[0] as! NSDictionary)["listId"] as! String),'0',\(nowstring))";
        let insertstatement = appdelegate.db.executeQuery(insertString);
        
        if SQLITE_DONE == sqlite3_step(insertstatement) {
            let lastRowId = sqlite3_last_insert_rowid(appdelegate.db.database)
            favId = "\(Int(lastRowId))"
        }
        else {
            print("error")
        }
        appdelegate.db.closeDatabase();
        
        DispatchQueue.main.sync {
            self.dismiss(animated: true, completion: nil)
            hasFav = !hasFav;
            novelTableView.reloadData();
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NovelTitleTableViewCell") as! NovelTitleTableViewCell;
            
            if (novelDic["image"] as! String).contains("https") || (novelDic["image"] as! String).contains("http") {
                cell.titleImageView.sd_setImage(with: URL(string: novelDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
            }
            else {
                cell.titleImageView.sd_setImage(with: URL(string: "https:\(novelDic["image"] as! String)"), placeholderImage: UIImage(named: "fengmian")!)
            }
            cell.titleLabel.text = novelDic["title"] as? String;
            cell.authorLabel.text = "作者：\(novelDic["author"] as! String)";
            cell.descLabel.text = novelDic["desc"] as? String;
            cell.stateLabel.text = novelDic["state"] as? String;
            cell.favBtn.addTarget(self, action: #selector(NovelViewController.favClick(_:)), for: UIControl.Event.touchUpInside);
            cell.offlineBtn.addTarget(self, action: #selector(NovelViewController.downClick(_:)), for: UIControl.Event.touchUpInside);
            
            cell.favBtn.layer.cornerRadius = 5;
            cell.offlineBtn.layer.cornerRadius = 5;
            
            if hasFav == true {
                cell.favBtn.setTitle("移除書架", for: UIControl.State.normal);
            }
            else {
                
                cell.favBtn.setTitle("收入書架", for: UIControl.State.normal)
            }
            
            return cell;
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NovelListTableView");
            
            let tempDic = novelArray[indexPath.row] as! NSMutableDictionary;
            
            let titleLabel = cell?.viewWithTag(101) as! UILabel;
            titleLabel.text = tempDic["title"] as? String;
            
            if favId.count != 0 {
                if tempDic["listId"] as! String == favListId {
                    titleLabel.textColor = UIColor.red;
                }
                else {
                    titleLabel.textColor = UIColor.white;
                }
            }
            else {
                titleLabel.textColor = UIColor.white;
            }

            let offineImageView = cell?.viewWithTag(102) as! UIImageView;
            
            if let offline = tempDic["offline"] as? Bool {
                offineImageView.isHidden = offline
            }
            
            
           
            
            return cell!;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectDic = novelArray[indexPath.row] as! NSMutableDictionary;
            selectDic.setValue(indexPath.row, forKey: "index");
            selectIndex = indexPath.row
//            appdelegate.viewController?.contentUrl = selectDic["url"] as! String;
//            appdelegate.viewController?.performSegue(withIdentifier: "toMainContent", sender: nil);
            performSegue(withIdentifier: "toContent", sender: nil);
            
        }
    }
//    
//    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContent" {
            let destination = segue.destination as! ContentViewController;
//            let contentViewController = destination.viewControllers[0] as! ContentViewController
            destination.contentUrl = selectDic["url"] as! String;
            
            if favId != "" {
                destination.listId = selectDic["listId"] as! String;
                destination.faveId = favId

            }
            
            destination.novelId = novelId;
            destination.listArray = novelArray;
            
            
//            destination.listIndex = selectDic["index"] as! Int;
            destination.listIndex = selectIndex;
            destination.sort = sort
            destination.listTitle = selectDic["title"] as! String;
            let backItem = UIBarButtonItem()
            backItem.title = "";
            navigationItem.backBarButtonItem = backItem
            
//            destination.view.frame = CGRect(x: 0, y: 0, width: destination.view.frame.size.width, height: (appdelegate.viewController?.centerView.frame.size.height)!);
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
