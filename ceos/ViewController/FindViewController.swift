//
//  FindViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/3/20.
//
//

import UIKit
import SDWebImage

class FindViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    
    let hotArray = NSMutableArray();
    let newArray = NSMutableArray();
    
    let peopleUpdateArray = NSMutableArray();
    let peopleNewArray = NSMutableArray();
    let peopleTopListArray = NSMutableArray();
    
    @IBOutlet weak var findBookTableView: UITableView!
    @IBOutlet weak var bookSearchBar: UISearchBar!
    
    @IBOutlet weak var serverSegmentedControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findBookTableView.rowHeight = UITableView.automaticDimension;
        
        serverSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: UIControl.State.normal);
        serverSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: UIControl.State.selected);
        
        let textFieldInsideSearchBar = bookSearchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.white
        // Do any additional setup after loading the view.
        self.present((appdelegate.viewController?.loadingAlertController)!, animated: true) {
            self.performSelector(inBackground: #selector(FindViewController.reloadData), with: nil);
        }
        
    }
    @IBAction func serverChange(_ sender: UISegmentedControl) {
        appdelegate.serverFrom = sender.selectedSegmentIndex;
        reloadUI()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text?.count != 0 {
            appdelegate.viewController?.searchUrl = searchBar.text!;
            appdelegate.viewController?.performSegue(withIdentifier: "showSearch", sender: nil);
            searchBar.resignFirstResponder();
        }
        
    }

    @objc func reloadData() {
        let peopleTempDic = appdelegate.parse.getPeopleHome();
        
        if peopleTempDic.count > 0 {
            peopleUpdateArray.addObjects(from: peopleTempDic["Update"] as! [Any]);
            peopleNewArray.addObjects(from: peopleTempDic["New"] as! [Any]);
            peopleTopListArray.addObjects(from: peopleTempDic["TopList"] as! [Any]);
        }
        
        
        
        let tempDic = appdelegate.parse.getHome();
        
        if tempDic.count > 0 {
            hotArray.addObjects(from: tempDic["Hot"] as! [Any]);
            newArray.addObjects(from: tempDic["New"] as! [Any]);
        }
        
        
        
        DispatchQueue.main.sync { 
            self.reloadUI();
        }
    }
    
    func reloadUI(){
        findBookTableView.reloadData();
        self.dismiss(animated: true, completion: nil);
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if serverSegmentedControl.selectedSegmentIndex == 0 {
            if indexPath.section == 1 {
                let tempDic = newArray[indexPath.row] as! NSDictionary;
                appdelegate.viewController?.novelUrl = tempDic["url"] as! String;
                appdelegate.viewController?.mainContentDic = NSMutableDictionary(dictionary: tempDic);
                appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);
            }
            else if indexPath.section == 2 {
                let tempDic = hotArray[indexPath.row] as! NSDictionary;
                appdelegate.viewController?.novelUrl = tempDic["url"] as! String;
                appdelegate.viewController?.mainContentDic = NSMutableDictionary(dictionary: tempDic);
                appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);
            }
        }
        else {
            if indexPath.section == 1 {
                let tempDic = peopleUpdateArray[indexPath.row] as! NSDictionary;
                appdelegate.viewController?.novelUrl = tempDic["url"] as! String;
                appdelegate.viewController?.mainContentDic = NSMutableDictionary(dictionary: tempDic);
                appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);
            }
            else if indexPath.section == 2 {
                let tempDic = peopleTopListArray[indexPath.row] as! NSDictionary;
                appdelegate.viewController?.novelUrl = tempDic["url"] as! String;
                appdelegate.viewController?.mainContentDic = NSMutableDictionary(dictionary: tempDic);
                appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);
            }
            else if indexPath.section == 3{
                let tempDic = peopleNewArray[indexPath.row] as! NSDictionary;
                appdelegate.viewController?.novelUrl = tempDic["url"] as! String;
                appdelegate.viewController?.mainContentDic = NSMutableDictionary(dictionary: tempDic);
                appdelegate.viewController?.performSegue(withIdentifier: "toNovel", sender: nil);
            }
        }
        
    }
    
    @objc func typeClick(sender: UIButton){
        
        appdelegate.viewController?.typeTitle = sender.title(for: UIControl.State.normal)!
        appdelegate.viewController?.performSegue(withIdentifier: "toList", sender: nil);
//        performSegue(withIdentifier: "toList", sender: nil);
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        if serverSegmentedControl.selectedSegmentIndex == 0 {
            return 3;
        }
        else {
            return 4;
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if serverSegmentedControl.selectedSegmentIndex == 0 {
            if indexPath.section == 1 {
                return 105;
            }
            else if indexPath.section == 2 {
                return 150;
            }
            else {
                return 44;
            }
        }
        else {
            if indexPath.section == 1 {
                return 105;
            }
            else {
                return 44;
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if serverSegmentedControl.selectedSegmentIndex == 0 {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TypeTableViewCell") as! TypeTableViewCell;
                cell.backgroundColor = UIColor.clear;
                cell.contentView.backgroundColor = UIColor.clear;
                cell.selectionStyle = UITableViewCell.SelectionStyle.none;
                cell.firstBtn.tag = indexPath.row * 3 + 0;
                cell.firstBtn.addTarget(self, action: #selector(FindViewController.typeClick(sender:)), for: UIControl.Event.touchUpInside);
                cell.secondBtn.tag = indexPath.row * 3 + 1;
                cell.secondBtn.addTarget(self, action: #selector(FindViewController.typeClick(sender:)), for: UIControl.Event.touchUpInside);
                cell.thirdBtn.tag = indexPath.row * 3 + 2;
                cell.thirdBtn.addTarget(self, action: #selector(FindViewController.typeClick(sender:)), for: UIControl.Event.touchUpInside);
                
                if indexPath.row == 0 {
                    cell.firstBtn.setTitle("玄幻奇幻", for: UIControl.State.normal);
                    cell.secondBtn.setTitle("都市言情", for: UIControl.State.normal);
                    cell.thirdBtn.setTitle("武俠仙俠", for: UIControl.State.normal);
                }
                else if indexPath.row == 1 {
                    cell.firstBtn.setTitle("軍事歷史", for: UIControl.State.normal);
                    cell.secondBtn.setTitle("網遊競技", for: UIControl.State.normal);
                    cell.thirdBtn.setTitle("科幻靈異", for: UIControl.State.normal);
                }
                else {
                    cell.firstBtn.setTitle("女生同人", for: UIControl.State.normal);
                    cell.secondBtn.setTitle("二次元", for: UIControl.State.normal);
                    cell.thirdBtn.setTitle("全本小說", for: UIControl.State.normal);
                }
                
                
                return cell;
            }
            else if indexPath.section == 1 {
                let tempDic = newArray[indexPath.row] as! NSDictionary;
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewTableViewCell");
                
                let titleLabel = cell?.viewWithTag(101) as! UILabel;
                titleLabel.text = tempDic["title"] as? String;
                
                let authorLabel = cell?.viewWithTag(104) as! UILabel;
                authorLabel.text = "-  \(tempDic["author"] as! String)";
                
                let indexLabel = cell?.viewWithTag(102) as! UILabel;
                indexLabel.text = "最新章節:\(tempDic["indexTitle"] as! String)";
                
                let dateLabel = cell?.viewWithTag(103) as! UILabel;
                dateLabel.text = "更新時間:\(tempDic["date"] as! String)";
                
                return cell!;
            }
            else  {
                let tempDic = hotArray[indexPath.row] as! NSDictionary;
                let cell = tableView.dequeueReusableCell(withIdentifier: "HotTableViewCell");
                
                let imageView = cell?.viewWithTag(101) as! UIImageView;
                //            imageView.sd_setImage(with: URL(string: tempDic["image"] as! String)!);
                if (tempDic["image"] as! String).contains("https") {
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
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TypeTableViewCell") as! TypeTableViewCell;
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none;
                cell.firstBtn.tag = indexPath.row * 3 + 0;
                cell.firstBtn.addTarget(self, action: #selector(FindViewController.typeClick(sender:)), for: UIControl.Event.touchUpInside);
                cell.secondBtn.tag = indexPath.row * 3 + 1;
                cell.secondBtn.addTarget(self, action: #selector(FindViewController.typeClick(sender:)), for: UIControl.Event.touchUpInside);
                cell.thirdBtn.tag = indexPath.row * 3 + 2;
                cell.thirdBtn.addTarget(self, action: #selector(FindViewController.typeClick(sender:)), for: UIControl.Event.touchUpInside);
            
                if indexPath.row == 0 {
                    cell.firstBtn.setTitle("玄幻魔法", for: UIControl.State.normal);
                    cell.secondBtn.setTitle("武俠修真", for: UIControl.State.normal);
                    cell.thirdBtn.setTitle("歷史軍事", for: UIControl.State.normal);
                }
                else if indexPath.row == 1 {
                    cell.firstBtn.setTitle("推理", for: UIControl.State.normal);
                    cell.secondBtn.setTitle("網遊動漫", for: UIControl.State.normal);
                    cell.thirdBtn.setTitle("科幻", for: UIControl.State.normal);
                }
                else if indexPath.row == 2{
                    cell.firstBtn.setTitle("恐怖靈異", for: UIControl.State.normal);
                    cell.secondBtn.setTitle("穿越重生", for: UIControl.State.normal);
                    cell.thirdBtn.setTitle("同人", for: UIControl.State.normal);
                }
                else {
                    cell.firstBtn.setTitle("全本", for: UIControl.State.normal);
                    cell.secondBtn.isHidden = true;
                    cell.thirdBtn.isHidden = true;
                }
                
                
                return cell;
            }
            else if indexPath.section == 1 {
                let tempDic = peopleUpdateArray[indexPath.row] as! NSDictionary;
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewTableViewCell");
                
                let titleLabel = cell?.viewWithTag(101) as! UILabel;
                titleLabel.text = tempDic["title"] as? String;
                
                let authorLabel = cell?.viewWithTag(104) as! UILabel;
                authorLabel.text = tempDic["author"] as? String;
                
                let indexLabel = cell?.viewWithTag(102) as! UILabel;
                indexLabel.text = "最新章節:\(tempDic["indexTitle"] as! String)";
                
                let dateLabel = cell?.viewWithTag(103) as! UILabel;
                dateLabel.text = "更新時間:\(tempDic["date"] as! String)";
                
                return cell!;
            }
            else  if indexPath.section == 2{
                let tempDic = peopleTopListArray[indexPath.row] as! NSDictionary;
                let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTypeTableViewCell");
                
                let titleLabel = cell?.viewWithTag(101) as! UILabel;
                titleLabel.text = "\(indexPath.row + 1)."
                
                let authorLabel = cell?.viewWithTag(102) as! UILabel;
                authorLabel.text = tempDic["title"] as? String
                
                let descLabel = cell?.viewWithTag(103) as! UILabel;
                descLabel.isHidden = true;
                
                return cell!;
            }
            else {
                let tempDic = peopleNewArray[indexPath.row] as! NSDictionary;
                let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTypeTableViewCell");
                
                let titleLabel = cell?.viewWithTag(101) as! UILabel;
                titleLabel.text = "\(indexPath.row + 1)."
                
                let authorLabel = cell?.viewWithTag(102) as! UILabel;
                authorLabel.text = tempDic["title"] as? String
                
                let descLabel = cell?.viewWithTag(103) as! UILabel;
                descLabel.text = tempDic["author"] as? String
                descLabel.isHidden = false;
                
                return cell!;
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20));


        headerView.backgroundColor = UIColor.clear;

        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: headerView.frame.size.width, height: headerView.frame.size.height));

        if serverSegmentedControl.selectedSegmentIndex == 0 {
            if section == 0 {
                titleLabel.text = "● 分類小說";
            }
            else if section == 1 {
                titleLabel.text = "● 最新小說更新";
            }
            else {
                titleLabel.text = "● 熱門小說推薦";
            }
        }
        else {
            if section == 0 {
                titleLabel.text = "● 分類小說";
            }
            else if section == 1 {
                titleLabel.text = "● 最新更新";
            }
            else if section == 2 {
                titleLabel.text = "● 熱門小說推薦";
            }
            else {
                titleLabel.text = "● 最新入庫";
            }
        }
        titleLabel.textColor = UIColor.lightGray;
        titleLabel.sizeToFit();
        headerView.addSubview(titleLabel);

        return headerView;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if serverSegmentedControl.selectedSegmentIndex == 0 {
            if section == 0 {
                return 3;
            }
            else if section == 1 {
                return newArray.count;
            }
            else {
                return hotArray.count;
            }
        }
        else {
            if section == 0 {
                return 4;
            }
            else if section == 1 {
                return peopleUpdateArray.count;
            }
            else if section == 2 {
                return peopleTopListArray.count;
            }
            else {
                return peopleNewArray.count;
            }
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
