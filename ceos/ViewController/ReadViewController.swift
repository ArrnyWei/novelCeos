//
//  ReadViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/12/25.
//

import UIKit

class ReadViewController: UIViewController {

    var pageNumber = 0;
    var attrs:[NSAttributedString.Key:Any]?;
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    var content = "";
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
    }
    
    func setFrame(_ frame:CGRect) {
        self.view.frame = frame;
        let readView = DZMReadView(frame: self.view.frame);
        
        readView.backgroundColor = UIColor.clear;
        readView.attrs = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: appdelegate.textSize),NSAttributedString.Key.foregroundColor:appdelegate.textColor,NSAttributedString.Key.backgroundColor:appdelegate.backColor];
        
        
        
        readView.content = content;
        
        self.view.addSubview(readView);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
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
