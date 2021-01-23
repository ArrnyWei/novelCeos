//
//  ViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/3/8.
//
//

import UIKit

class ViewController: UIViewController{

    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    var homeDic = NSDictionary();
    var homeBooksArray = NSMutableArray();
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var pageSegmentedControl: UISegmentedControl!
//    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var centerViewHeight: NSLayoutConstraint!
    var backItem:UIBarButtonItem?;
    var sortItem:UIBarButtonItem?;
    
    var contentUrl = "";
    var initial = false;
    var typeTitle = "";
    var novelUrl = "";
    var searchUrl = "";
    var mainContentDic = NSMutableDictionary();
    var loadingAlertController:UIAlertController?;
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
//        homeDic = appdelegate.parse.getHome();
        pageSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: UIControl.State.normal);
        pageSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: UIControl.State.selected);
        title = "小說瀏覽器"
        appdelegate.viewController = self;
        
//        backItem = UIBarButtonItem(image: UIImage(named: "head_icon_back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.backClick(_:)));
        backItem = UIBarButtonItem();
        backItem?.tintColor = UIColor.white;
        navigationController?.navigationItem.backBarButtonItem = backItem;
        
        sortItem = UIBarButtonItem(title: "正序", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NovelViewController.sortClick(_:)));
        sortItem?.tintColor = UIColor.white;
        
        loadingAlertController = UIAlertController(title: nil, message: "載入中...\n", preferredStyle: UIAlertController.Style.alert);
        
        //        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 40, width: 50, height: 50));
        let indicator = UIActivityIndicatorView(frame: (loadingAlertController?.view.bounds)!);
        indicator.frame = CGRect(x: indicator.frame.origin.x, y: indicator.frame.origin.y + 15, width: indicator.frame.size.width, height: indicator.frame.size.height)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        indicator.style = UIActivityIndicatorView.Style.gray;
        //        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge;
        
        loadingAlertController?.view.addSubview(indicator);
        
        indicator.isUserInteractionEnabled = false;
        indicator.startAnimating();

        appdelegate.fbAdCanOpen = UIApplication.shared.canOpenURL(URL(string: "fb://")!)
        
    }
    
    func contnetBackClick(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        if initial == false {
            if appdelegate.findNavi == nil {
                appdelegate.findNavi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FindNavi") as? UINavigationController;
            }
            self.addChild(appdelegate.findNavi!);
            appdelegate.findNavi?.view.frame = CGRect(x: 0, y: 0, width: (appdelegate.findNavi?.view.frame.size.width)!, height: self.centerView.frame.size.height);
            self.centerView.addSubview((appdelegate.findNavi?.view)!);
            initial = true;
        }
        
    }
    
    @IBAction func pageSegmentedController(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            for tempView in self.centerView.subviews {
                tempView.removeFromSuperview();
            }
            
           
            
            if appdelegate.findNavi == nil {
                appdelegate.findNavi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FindNavi") as? UINavigationController;
            }
            self.addChild(appdelegate.findNavi!);
            appdelegate.findNavi?.view.frame = CGRect(x: 0, y: 0, width: (appdelegate.findNavi?.view.frame.size.width)!, height: self.centerView.frame.size.height);
            self.centerView.addSubview((appdelegate.findNavi?.view)!);
        }
        else if sender.selectedSegmentIndex == 1 {
            for tempView in self.centerView.subviews {
                tempView.removeFromSuperview();
            }
            
            if appdelegate.myNavi == nil {
                appdelegate.myNavi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyNavi") as? UINavigationController;
            }
            self.addChild(appdelegate.myNavi!);
            appdelegate.myNavi?.view.frame = CGRect(x: 0, y: 0, width: (appdelegate.myNavi?.view.frame.size.width)!, height: self.centerView.frame.size.height);
            self.centerView.addSubview((appdelegate.myNavi?.view)!);
        }
        else {
            for tempView in self.centerView.subviews {
                tempView.removeFromSuperview();
            }
            
            if appdelegate.settingNavi == nil {
                appdelegate.settingNavi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingNavi") as? UINavigationController;
            }
            self.addChild(appdelegate.settingNavi!);
            appdelegate.settingNavi?.view.frame = CGRect(x: 0, y: 0, width: (appdelegate.settingNavi?.view.frame.size.width)!, height: self.centerView.frame.size.height);
            self.centerView.addSubview((appdelegate.settingNavi?.view)!);
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toList" {
            let typeViewController = segue.destination as! TypeViewController;
            typeViewController.typeString = typeTitle;
            
        }
        else if segue.identifier == "toNovel" {
            let destination = segue.destination as! NovelViewController;
            destination.novelUrl = novelUrl
//            let backItem = UIBarButtonItem()
//            backItem.title = ""
//            navigationItem.rightBarButtonItem = sortItem;
           
            
        }
        else if segue.identifier == "showSearch" {
            let destination = segue.destination as! SearchViewController;
            destination.searchText = searchUrl;
//            let backItem = UIBarButtonItem()
//            backItem.title = ""
//            navigationItem.backBarButtonItem = backItem
        }
        else if segue.identifier == "mainToContent" {
            let destination = segue.destination as! ContentViewController;
            //            let contentViewController = destination.viewControllers[0] as! ContentViewController
            destination.contentUrl = appdelegate.viewController?.mainContentDic["listUrl"] as! String;
            destination.listId = appdelegate.viewController?.mainContentDic["listId"] as! String;
            destination.faveId = appdelegate.viewController?.mainContentDic["id"] as! String;
            destination.novelId = appdelegate.viewController?.mainContentDic["novelId"] as! String;
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


}

