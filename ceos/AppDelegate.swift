//
//  AppDelegate.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/3/8.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let parse = Parser();
    var viewController:ViewController?;
    var myNavi:UINavigationController?;
    var findNavi:UINavigationController?;
    var settingNavi:UINavigationController?;
    var db:DBHelper = DBHelper();
    let httpRequest:HttpRequestTools = HttpRequestTools();
    var languageChoose = "zn";
    var backColor = UIColor.white;
    var textColor = UIColor.black;
    var textSize:CGFloat = 17;
    var lineSpace:CGFloat = 2;
    var inContent = false;
    var readDirection = "vertical"
    var serverFrom = 0 ;

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent;
    
        parse.appdelegate = self;
        
        if let _ = UserDefaults.standard.value(forKey: "language") as? String {
            languageChoose = UserDefaults.standard.value(forKey: "language") as! String;
            
            if UserDefaults.standard.value(forKey: "backColor") as! String == "black" {
                backColor = UIColor.black;
            }
            else if UserDefaults.standard.value(forKey: "backColor") as! String == "darkGray" {
                backColor = UIColor.darkGray;
            }
            else if UserDefaults.standard.value(forKey: "backColor") as! String == "lightGray" {
                backColor = UIColor.lightGray;
            }
            else if UserDefaults.standard.value(forKey: "backColor") as! String == "white" {
                backColor = UIColor.white;
            }
            
            if UserDefaults.standard.value(forKey: "textColor") as! String == "black" {
                textColor = UIColor.black;
            }
            else if UserDefaults.standard.value(forKey: "textColor") as! String == "darkGray" {
                textColor = UIColor.darkGray;
            }
            else if UserDefaults.standard.value(forKey: "textColor") as! String == "lightGray" {
                textColor = UIColor.lightGray;
            }
            else if UserDefaults.standard.value(forKey: "textColor") as! String == "white" {
                textColor = UIColor.white;
            }

            textSize = CGFloat( UserDefaults.standard.value(forKey: "textSize") as! Float);

        }
        else {
            UserDefaults.standard.setValue("zn", forKey: "language");
            UserDefaults.standard.setValue("white", forKey: "backColor");
            UserDefaults.standard.setValue("black", forKey: "textColor");
            UserDefaults.standard.setValue(17, forKey: "textSize");
        }
        
        if let _ = UserDefaults.standard.value(forKey: "read") as? String{
            readDirection = UserDefaults.standard.value(forKey: "read") as! String;
        }
        else {
            UserDefaults.standard.setValue("vertical", forKey: "read");
        }
        
        if let _ = UserDefaults.standard.value(forKey: "lineSpace") as? String{
            lineSpace = UserDefaults.standard.value(forKey: "lineSpace") as! CGFloat;
        }
        else {
            UserDefaults.standard.setValue(lineSpace, forKey: "lineSpace");
        }

        db.db_EXT = ".sqlite";
        db.db_NAME = "ceos";
        return true
    }
    
    func updateSQL(){
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

