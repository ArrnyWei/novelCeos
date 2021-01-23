//
//  DZMReadView.swift
//  DZMeBookRead
//
//  Created by 邓泽淼 on 2017/5/15.
//  Copyright © 2017年 DZM. All rights reserved.
//

import UIKit

class DZMReadView: UIView {
    let appdelegate = UIApplication.shared.delegate as! AppDelegate;
    var attrs:[NSAttributedString.Key:Any]?;
    
    /// 内容
    var content:String? {
        
        didSet{
            
            if content != nil && !content!.isEmpty {
                
                frameRef = GetReadFrameRef(content: content!)
            }
        }
    }
    
    func GetReadFrameRef(content:String) ->CTFrame {
        
        // 段落配置
        let paragraphStyle = NSMutableParagraphStyle()

        // 行间距
        paragraphStyle.lineSpacing = appdelegate.lineSpace

        // 段间距
        paragraphStyle.paragraphSpacing = 2

        // 当前行间距(lineSpacing)的倍数(可根据字体大小变化修改倍数)
        paragraphStyle.lineHeightMultiple = 1.0

        // 对其
        paragraphStyle.alignment = NSTextAlignment.justified
        
        let attributedString = NSMutableAttributedString(string: content,attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: appdelegate.textSize),NSAttributedString.Key.foregroundColor:appdelegate.textColor,NSAttributedString.Key.backgroundColor:appdelegate.backColor,NSAttributedString.Key.paragraphStyle:paragraphStyle])
        
//        let attributedString = NSMutableAttributedString(string: content,attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: appdelegate.textSize),NSForegroundColorAttributeName:appdelegate.textColor,NSBackgroundColorAttributeName:appdelegate.backColor])
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        let path = CGPath(rect: self.frame, transform: nil)
        
        let frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, content.count), path, nil)
        
        return frameRef
    }
    
    /// CTFrame
    var frameRef:CTFrame? {
        
        didSet{
            
            if frameRef != nil {
                
                setNeedsDisplay()
            }
        }
    }
    
    /// 绘制
    override func draw(_ rect: CGRect) {
        
        
        
        if (frameRef == nil) {return}
        
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.textMatrix = CGAffineTransform.identity
        
        ctx?.translateBy(x: 0, y: bounds.size.height);
        
        ctx?.scaleBy(x: 1.0, y: -1.0);
        
        CTFrameDraw(frameRef!, ctx!);
    }

    
}
