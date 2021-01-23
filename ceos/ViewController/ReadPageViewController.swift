//
//  ReadPageViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/12/25.
//

import UIKit

class ReadPageViewController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate {

    var attrs:[String:Any]?;
    var allContent = "";
    
    var transitionType = 0;
    var pageNumber = 0;
    var readViewControllerArray = NSMutableArray();
    var canSlipe = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.delegate = self;
        self.dataSource = self;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == true && finished == true{
            if transitionType == 0 {
                pageNumber += 1;
            }
            else {
                pageNumber -= 1;
            }
            
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        transitionType = 0
        
//        if pageNumber == (self.readViewControllerArray.count - 1){
//            return nil;
//        }
//        else if pageNumber == self.readViewControllerArray.count - 2{
//            let finalViewController = readViewControllerArray[pageNumber + 1] as? FBAdViewController;
//            return finalViewController
//        }
//        else {
//            let finalViewController = readViewControllerArray[pageNumber + 1] as! ReadViewController;
//
//
//            return finalViewController
//        }
        if viewController is FBAdViewController {
            (self.parent as! ContentViewController).pageReloadDown();
            return nil;
        }
        else {
            let currentViewController = viewController as! ReadViewController;
            
            if currentViewController.pageNumber == readViewControllerArray.count - 1 {
                (self.parent as! ContentViewController).pageReloadDown();
                return nil;
            }
            else if currentViewController.pageNumber == readViewControllerArray.count - 2 && appDelegate.fbAdCanOpen == true{
                return readViewControllerArray[currentViewController.pageNumber + 1] as! FBAdViewController
            }
            else {
                return readViewControllerArray[currentViewController.pageNumber + 1] as! ReadViewController
            }
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        transitionType = 1;
        
        if viewController is FBAdViewController {
            return readViewControllerArray[readViewControllerArray.count - 2] as! ReadViewController
        }
        else {
            let currentViewController = viewController as! ReadViewController;
            
            if currentViewController.pageNumber == 0 {
                (self.parent as! ContentViewController).pageReloadUp();
                return nil;
            }
            else {
                return readViewControllerArray[currentViewController.pageNumber - 1] as! ReadViewController
            }
        }
//        if pageNumber == 0 {
//            return nil;
//        }
//        else {
//            let finalViewController = readViewControllerArray[pageNumber - 1] as! ReadViewController;
//            return finalViewController
//        }
        
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
