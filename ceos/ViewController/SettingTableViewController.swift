//
//  SettingTableViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/8/1.
//
//

import UIKit

class SettingTableViewController: UITableViewController {

    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    @IBOutlet var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        settingTableView.tableFooterView = UIView(frame: CGRect.zero);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return 60
        }
        else {
            return 120;
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "directionTableViewCell", for: indexPath)
            let languageSegmenControl =  cell.viewWithTag(101) as! UISegmentedControl;
            languageSegmenControl.addTarget(self, action: #selector(SettingTableViewController.directionValueChange(_:)), for: UIControl.Event.valueChanged);
            if appdelegate.readDirection == "horizon" {
                languageSegmenControl.selectedSegmentIndex = 1;
            }
            else {
                languageSegmenControl.selectedSegmentIndex = 0;
            }
            
            languageSegmenControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: UIControl.State.normal);
            languageSegmenControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: UIControl.State.selected);
            
            
            return cell;
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "languageTableViewCell", for: indexPath)
            let languageSegmenControl =  cell.viewWithTag(101) as! UISegmentedControl;
            languageSegmenControl.addTarget(self, action: #selector(SettingTableViewController.languageValueChange(_:)), for: UIControl.Event.valueChanged);
            if appdelegate.languageChoose == "zn" {
                languageSegmenControl.selectedSegmentIndex = 1;
            }
            else {
                languageSegmenControl.selectedSegmentIndex = 0;
            }
            languageSegmenControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: UIControl.State.normal);
            languageSegmenControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: UIControl.State.selected);
            
            return cell;
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "backgroundTableViewCell", for: indexPath)
            
            let backLabel = cell.viewWithTag(101) as! UILabel;
            backLabel.textColor = appdelegate.textColor;
            backLabel.backgroundColor = appdelegate.backColor;
            
            (cell.viewWithTag(102) as! UIButton).addTarget(self, action: #selector(SettingTableViewController.backgroundChange(_:)), for: UIControl.Event.touchUpInside);
            (cell.viewWithTag(103) as! UIButton).addTarget(self, action: #selector(SettingTableViewController.backgroundChange(_:)), for: UIControl.Event.touchUpInside);
            (cell.viewWithTag(104) as! UIButton).addTarget(self, action: #selector(SettingTableViewController.backgroundChange(_:)), for: UIControl.Event.touchUpInside);
            (cell.viewWithTag(105) as! UIButton).addTarget(self, action: #selector(SettingTableViewController.backgroundChange(_:)), for: UIControl.Event.touchUpInside);
            
            (cell.viewWithTag(102) as! UIButton).layer.borderWidth = 1;
            (cell.viewWithTag(103) as! UIButton).layer.borderWidth = 1;
            (cell.viewWithTag(104) as! UIButton).layer.borderWidth = 1;
            (cell.viewWithTag(105) as! UIButton).layer.borderWidth = 1;
            
            (cell.viewWithTag(102) as! UIButton).layer.borderColor = UIColor.black.cgColor;
            (cell.viewWithTag(103) as! UIButton).layer.borderColor = UIColor.black.cgColor;
            (cell.viewWithTag(104) as! UIButton).layer.borderColor = UIColor.black.cgColor;
            (cell.viewWithTag(105) as! UIButton).layer.borderColor = UIColor.black.cgColor;
            
            return cell;
        }
        else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath)
            
            let textLabel = cell.viewWithTag(101) as! UILabel;
            textLabel.textColor = appdelegate.textColor;
            textLabel.backgroundColor = appdelegate.backColor;
            
            (cell.viewWithTag(102) as! UIButton).addTarget(self, action: #selector(SettingTableViewController.textChange(_:)), for: UIControl.Event.touchUpInside);
            (cell.viewWithTag(103) as! UIButton).addTarget(self, action: #selector(SettingTableViewController.textChange(_:)), for: UIControl.Event.touchUpInside);
            (cell.viewWithTag(104) as! UIButton).addTarget(self, action: #selector(SettingTableViewController.textChange(_:)), for: UIControl.Event.touchUpInside);
            (cell.viewWithTag(105) as! UIButton).addTarget(self, action: #selector(SettingTableViewController.textChange(_:)), for: UIControl.Event.touchUpInside);

            (cell.viewWithTag(102) as! UIButton).layer.borderWidth = 1;
            (cell.viewWithTag(103) as! UIButton).layer.borderWidth = 1;
            (cell.viewWithTag(104) as! UIButton).layer.borderWidth = 1;
            (cell.viewWithTag(105) as! UIButton).layer.borderWidth = 1;
            
            (cell.viewWithTag(102) as! UIButton).layer.borderColor = UIColor.black.cgColor;
            (cell.viewWithTag(103) as! UIButton).layer.borderColor = UIColor.black.cgColor;
            (cell.viewWithTag(104) as! UIButton).layer.borderColor = UIColor.black.cgColor;
            (cell.viewWithTag(105) as! UIButton).layer.borderColor = UIColor.black.cgColor;
            
            return cell;
        }
        else if indexPath.row == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sizeTableViewCell", for: indexPath)
            
            let sizeLabel = cell.viewWithTag(101) as! UILabel;
            sizeLabel.font = UIFont.systemFont(ofSize: CGFloat(Int(appdelegate.textSize)));
            
            let sizeSlider = cell.viewWithTag(102) as! UISlider;
            sizeSlider.addTarget(self, action: #selector(SettingTableViewController.sizeChange(_:)), for: UIControl.Event.valueChanged);
            
            let sizeFontLabel = cell.viewWithTag(103) as! UILabel;
            sizeFontLabel.text = "\(Int(appdelegate.textSize))"
            
            sizeSlider.value = Float(Int(appdelegate.textSize));
            return cell;
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "lineSpaceTableViewCell", for: indexPath)
            
//            let sizeLabel = cell.viewWithTag(101) as! UILabel;
//            sizeLabel.font = UIFont.systemFont(ofSize: CGFloat(Int(appdelegate.lineSpace)));
            
            let sizeSlider = cell.viewWithTag(102) as! UISlider;
            sizeSlider.addTarget(self, action: #selector(SettingTableViewController.lineSpaceChange(_:)), for: UIControl.Event.valueChanged);
            
            let sizeFontLabel = cell.viewWithTag(103) as! UILabel;
            sizeFontLabel.text = "\(Int(appdelegate.lineSpace))"
            
            sizeSlider.value = Float(Int(appdelegate.lineSpace));
            return cell;
        }
        
    }
    
    @objc func directionValueChange(_ sender:UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            appdelegate.readDirection = "vertical"
            UserDefaults.standard.setValue("vertical", forKey: "read");
        }
        else {
            appdelegate.readDirection = "horizon"
            UserDefaults.standard.setValue("horizon", forKey: "read");
        }
        settingTableView.reloadData()
    }
    
    @objc func languageValueChange(_ sender:UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            appdelegate.languageChoose = "cn"
            UserDefaults.standard.setValue("cn", forKey: "language");
        }
        else {
            appdelegate.languageChoose = "zn"
            UserDefaults.standard.setValue("zn", forKey: "language");
        }
        settingTableView.reloadData()
    }
    
    @objc func backgroundChange(_ sender:UIButton) {
        if sender.tag == 102 {
            appdelegate.backColor = UIColor.black;
            UserDefaults.standard.setValue("black", forKey: "backColor");
        }
        else if sender.tag == 103 {
            appdelegate.backColor = UIColor.darkGray;
            UserDefaults.standard.setValue("darkGray", forKey: "backColor");
        }
        else if sender.tag == 104 {
            appdelegate.backColor = UIColor.lightGray;
            UserDefaults.standard.setValue("lightGray", forKey: "backColor");
        }
        else if sender.tag == 105 {
            appdelegate.backColor = UIColor.white;
            UserDefaults.standard.setValue("white", forKey: "backColor");
        }
        settingTableView.reloadData()
    }
    
    @objc func textChange(_ sender:UIButton) {
        if sender.tag == 102 {
            appdelegate.textColor = UIColor.black;
            UserDefaults.standard.setValue("black", forKey: "textColor");
        }
        else if sender.tag == 103 {
            appdelegate.textColor = UIColor.darkGray;
            UserDefaults.standard.setValue("darkGray", forKey: "textColor");
        }
        else if sender.tag == 104 {
            appdelegate.textColor = UIColor.lightGray;
            UserDefaults.standard.setValue("lightGray", forKey: "textColor");
        }
        else if sender.tag == 105 {
            appdelegate.textColor = UIColor.white;
            UserDefaults.standard.setValue("white", forKey: "textColor");
        }
        settingTableView.reloadData()
    }
    
    @objc func sizeChange(_ sender:UISlider) {
        appdelegate.textSize = CGFloat(Int(sender.value));
        UserDefaults.standard.setValue(appdelegate.textSize, forKey: "textSize");
        settingTableView.reloadData()
    }
    
    @objc func lineSpaceChange(_ sender:UISlider) {
        appdelegate.lineSpace = CGFloat(Int(sender.value));
        UserDefaults.standard.setValue(appdelegate.lineSpace, forKey: "lineSpace");
        settingTableView.reloadData()
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
