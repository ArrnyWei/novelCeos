//
//  MyViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/3/20.
//
//

import UIKit

class MyViewController: UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource{
    
    
    
    let myArray = NSMutableArray();
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    @IBOutlet weak var bookTableView: UITableView!
    var viewStyle = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        bookTableView.rowHeight = UITableViewAutomaticDimension;
//        bookTableView.estimatedRowHeight = 130;
//
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
//        appdelegate.viewController?.navigationItem.leftBarButtonItem = nil;
        myArray.removeAllObjects();
        appdelegate.db.openDatabase();
        
        let queryString = "select * from favNovel order By date DESC";
        let statement = self.appdelegate.db.executeQuery(queryString);
        while (sqlite3_step(statement) == SQLITE_ROW){
            
            let tempDic = NSMutableDictionary();
            tempDic.setValue("\(sqlite3_column_int(statement, 0))", forKey: "id");
            tempDic.setValue("\(sqlite3_column_int(statement, 1))", forKey: "novelId");
            tempDic.setValue("\(sqlite3_column_int(statement, 2))", forKey: "listId");
            tempDic.setValue(String(cString: sqlite3_column_text(statement, 3)), forKey: "frame");
            tempDic.setValue("\(sqlite3_column_int64(statement, 4))", forKey: "date");
            
            myArray.add(tempDic);
        }
        
        
        for tempDic in myArray {
            let finalDic = tempDic as! NSMutableDictionary;
            var queryString = "select * from novel Where id = \"\(finalDic["novelId"] as! String)\"";
            var statement = self.appdelegate.db.executeQuery(queryString);
            while (sqlite3_step(statement) == SQLITE_ROW){
                
                finalDic.setValue(String(cString: sqlite3_column_text(statement, 1)), forKey: "title");
                finalDic.setValue(String(cString: sqlite3_column_text(statement, 2)), forKey: "author");
                finalDic.setValue(String(cString: sqlite3_column_text(statement, 3)), forKey: "desc");
                finalDic.setValue(String(cString: sqlite3_column_text(statement, 4)), forKey: "novelUrl");
                finalDic.setValue(String(cString: sqlite3_column_text(statement, 5)), forKey: "image");
            }
            
            queryString = "select * from list Where id = \"\(finalDic["listId"] as! String)\"";
            statement = self.appdelegate.db.executeQuery(queryString);
            while (sqlite3_step(statement) == SQLITE_ROW){
                
                finalDic.setValue(String(cString: sqlite3_column_text(statement, 2)), forKey: "listTitle");
                finalDic.setValue(String(cString: sqlite3_column_text(statement, 3)), forKey: "listUrl");
            }
            
        }
        appdelegate.db.closeDatabase();
        bookTableView.reloadData();
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewStyle == 0 {
            appdelegate.viewController?.mainContentDic = myArray[indexPath.row]  as! NSMutableDictionary;
            appdelegate.viewController?.novelUrl = (myArray[indexPath.row]  as! NSMutableDictionary)["novelUrl"] as! String;
            appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewStyle == 0 {
            return 140;
        }
        else {
            return 200;
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewStyle == 0 {
            return myArray.count;
        }
        else {
            return Int(ceil(Double(myArray.count) / 2));
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewStyle == 0 {
            let tempDic = myArray[indexPath.row] as! NSDictionary;
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookHotTableViewCell");
            
            let imageView = cell?.viewWithTag(101) as! UIImageView;
            //            imageView.sd_setImage(with: URL(string: tempDic["image"] as! String)!);
            if (tempDic["image"] as! String).contains("http") {
                imageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
            }
            else {
                imageView.sd_setImage(with: URL(string: "http:\(tempDic["image"] as! String)"), placeholderImage: UIImage(named: "fengmian")!)
            }
            
            
            
            let titleLabel = cell?.viewWithTag(102) as! UILabel;
            titleLabel.text = tempDic["title"] as? String;
            
            let authorLabel = cell?.viewWithTag(103) as! UILabel;
            authorLabel.text = tempDic["author"] as? String
            
            let descLabel = cell?.viewWithTag(105) as! UILabel;
            descLabel.text = "閱讀進度：\(tempDic["listTitle"] as! String)"
            
            return cell!;
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookNiceTableViewCell") as! NiceTableViewCell;
            
            let tempDic = myArray[indexPath.row * 2] as! NSDictionary;
            
            cell.firstLabel.text = tempDic["title"] as? String;
            //            cell.firstImageView
            cell.firstImageView.sd_setImage(with: URL(string: tempDic["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
            cell.firstBtn.tag = indexPath.row * 2;
            cell.firstBtn.addTarget(self, action: #selector(MyViewController.chooseNovelClick(sender:)), for: UIControl.Event.touchUpInside);
            
            if (indexPath.row * 2) + 1 < myArray.count {
                let tempDic2 = myArray[(indexPath.row * 2) + 1] as! NSDictionary;
                cell.secondLabel.text = tempDic2["title"] as? String;
                cell.secondImageView.sd_setImage(with: URL(string: tempDic2["image"] as! String), placeholderImage: UIImage(named: "fengmian")!)
                
                cell.secondBtn.tag = (indexPath.row * 2) + 1;
                cell.secondBtn.addTarget(self, action: #selector(MyViewController.chooseNovelClick(sender:)), for: UIControl.Event.touchUpInside);
            }
            else {
                cell.secondView.isHidden = true;
            }
            return cell;
        }
    }
    
    
    @objc func chooseNovelClick(sender:UIButton) {
        _ = myArray[sender.tag] as! NSDictionary;
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
