//
//  FBAdViewController.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/12/25.
//

import UIKit
import FBAudienceNetwork

class FBAdViewController: UIViewController,FBNativeAdDelegate {
    var pageNumber = 0;
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nativeAd = FBNativeAd(placementID: "156413368451300_156438941782076");
        nativeAd.delegate = self;
        
        
        nativeAd.loadAd()
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        print("fb ad error")
    }

    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        
        let adView = FBNativeAdView(nativeAd: nativeAd, with: FBNativeAdViewType.genericHeight400);
        self.view.addSubview(adView);
        
        let size = self.view.frame.size;
        let xOffset = size.width / 2 - 160;
        let yOffset = size.height / 2 - 200;
        adView.frame = CGRect(x: Int(xOffset), y: Int(yOffset), width: 320, height: 400);
        
//        nativeAd.registerView(forInteraction: adView, with: self);
//        nativeAd.registerView(forInteraction: adView, mediaView: nil, iconView: nil, viewController: self);
        
    }
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        
    }
    
    func nativeAdDidFinishHandlingClick(_ nativeAd: FBNativeAd) {
        
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
