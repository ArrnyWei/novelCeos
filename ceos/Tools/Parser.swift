//
//  Parser.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/3/14.
//
//

import UIKit
import Foundation
import Kanna
extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.lowerBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.upperBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}


class Parser: NSObject,XMLParserDelegate {
    
    let hostURL = "http://www.uukanshu.com"
    let peopleHostURL = "http://www.mytxt.cc/"

    var appdelegate:AppDelegate?;
    
    func getHome() -> NSDictionary {
        let niceNovelArray = NSMutableArray();
        let hotNovelArray = NSMutableArray();
        let dic = NSMutableDictionary();
        guard let myURL = URL(string: self.hostURL) else {
            print("Error: \(self.hostURL) doesn't seem to be a valid URL")
            return [:];
        }
        
        do {
            let dogString = changeDogStringToPeopleString(try Data(contentsOf: myURL));
            
            if let doc = try? HTML(html: dogString, encoding: .utf8) {

                
                
                for link in doc.xpath("//ul[@class='block']/li") {
                    let tempDic = NSMutableDictionary();
                    
                    tempDic.setValue(link.at_xpath("span[@class='sm']")?.at_xpath("a")?.text!, forKey: "title");
                    tempDic.setValue(link.at_xpath("span[@class='sm']")?.at_xpath("a")?["href"]!, forKey: "url");
                    tempDic.setValue(link.at_xpath("span[@class='zj']")?.at_xpath("a")?.text!, forKey: "indexTitle");
                    tempDic.setValue(link.at_xpath("span[@class='zz']")?.text!, forKey: "author");
                    tempDic.setValue(link.at_xpath("span[@class='sj']")?.text!, forKey: "date");
                    
                    niceNovelArray.add(tempDic);
                }
                dic.setValue(niceNovelArray, forKey: "New");
                
                for link in doc.xpath("//ul[@class='zxxslb']/li") {
                    let tempDic = NSMutableDictionary();
                    
                    tempDic.setValue(link.at_xpath("p[@class='fm']")?.at_xpath("a")?["title"]!, forKey: "title");
                    tempDic.setValue(link.at_xpath("p[@class='fm']")?.at_xpath("a")?["href"]!, forKey: "url");
                    tempDic.setValue(link.at_xpath("p[@class='fm']")?.at_xpath("a")?.at_xpath("img")?["src"]!, forKey: "image");
                    tempDic.setValue(link.at_xpath("p[@class='ms']")?.at_xpath("span[@class='jj']")?.text!, forKey: "desc");
                    tempDic.setValue(link.at_xpath("p[@class='ms']")?.at_xpath("span[@class='zz']")?.text!, forKey: "author");
                    
                    hotNovelArray.add(tempDic);
                }
                dic.setValue(hotNovelArray, forKey: "Hot");
            }
            
//            print("dogString : \(dogString)")
        } catch let error {
            print("Error: \(error)")
        }
        
        return dic;
    }
    func getPeopleHome() -> NSDictionary {
        let niceNovelArray = NSMutableArray();
        let hotNovelArray = NSMutableArray();
        let newNovelArray = NSMutableArray();
        let dic = NSMutableDictionary();
        guard let myURL = URL(string: self.peopleHostURL) else {
            print("Error: \(self.hostURL) doesn't seem to be a valid URL")
            return [:];
        }
        
        do {
//            let dogString = changeDogStringToPeopleString(try Data(contentsOf: myURL));
            let dogString = changeDogStringToPeopleStringforPeople(try Data(contentsOf: myURL))
            
            if let doc = try? HTML(html: dogString, encoding: .utf8) {
                
                
                
                for link in doc.xpath("//div[@class='last_update_m62topxs']/ul/li") {
                    let tempDic = NSMutableDictionary();
                    
                    tempDic.setValue(link.at_xpath("strong")?.at_xpath("a")?.text!, forKey: "title");
                    tempDic.setValue(link.at_xpath("strong")?.at_xpath("a")?["href"]!, forKey: "url");
                    tempDic.setValue(link.at_xpath("em")?.at_xpath("a")?.text!, forKey: "indexTitle");
                    tempDic.setValue(link.at_xpath("em")?.at_xpath("a")?["href"]!, forKey: "indexUrl");
                    tempDic.setValue(link.at_xpath("span[@class='author']")?.text!, forKey: "author");
                    tempDic.setValue(link.at_xpath("span[@class='update_time']")?.text!, forKey: "date");
                    
                    niceNovelArray.add(tempDic);
                }
                dic.setValue(niceNovelArray, forKey: "Update");
                
                for link in doc.xpath("//div[@class='new_article']/ul/li") {
                    let tempDic = NSMutableDictionary();
                    
                    tempDic.setValue(link.at_xpath("a")?.text, forKey: "title");
                    tempDic.setValue(link.at_xpath("a")?["href"]!, forKey: "url");
                    tempDic.setValue(link.text!.components(separatedBy: "/")[1], forKey: "author");
                    
                    newNovelArray.add(tempDic);
                }
                dic.setValue(newNovelArray, forKey: "New");
                
                for link in doc.xpath("//ul[@class='ranking-list']/li") {
                    let tempDic = NSMutableDictionary();
                    
                    tempDic.setValue(link.at_xpath("a")?.text, forKey: "title");
                    tempDic.setValue(link.at_xpath("a")?["href"]!, forKey: "url");
                    
                    hotNovelArray.add(tempDic);
                }
                dic.setValue(hotNovelArray, forKey: "TopList");
                
                
            }
            
            //            print("dogString : \(dogString)")
        } catch let error {
            print("Error: \(error)")
        }
        
        return dic;
    }
    
    func getList(_ listUrl:String,pageIndex:Int) -> NSDictionary{
        let listArray = NSMutableArray();
        let dic = NSMutableDictionary();
        
        guard let myURL = URL(string: "\(self.hostURL)/list/\(listUrl)-\(pageIndex).html") else {
            print("Error: \(self.hostURL) doesn't seem to be a valid URL")
            return [:];
        }
        
        do {
            let dogString = changeDogStringToPeopleString(try Data(contentsOf: myURL));
            
            if let doc = try? HTML(html: dogString, encoding: .utf8) {
                
                
                for link in doc.xpath("//div[@class='content clearfix']/span[@class='list-item']") {
                    let tempDic = NSMutableDictionary();
                    
                    if listUrl == "quanben" {
                        tempDic.setValue(link.at_xpath("a[@class='bookImg']")?["href"]!.replacingOccurrences(of: "t", with: "b"), forKey: "url");
                    }
                    else {
                        tempDic.setValue(link.at_xpath("a[@class='bookImg']")?["href"]!, forKey: "url");
                        
                    }
                    
                    tempDic.setValue(link.at_xpath("a[@class='bookImg']")?.at_xpath("img")?["src"]!, forKey: "image");
                    tempDic.setValue(link.at_xpath("a[@class='bookImg']")?.at_xpath("img")?["alt"]!.replacingOccurrences(of: "全文閱讀", with: ""), forKey: "title");
                    
                    for bookItem in link.xpath("div[@class='book-info']/dl/dt") {
                        
                        if bookItem.text?.contains("作者：") == true{
                            tempDic.setValue(bookItem.text!, forKey: "author");
                        }
                        else if bookItem.text?.contains("簡介：") == true {
                            tempDic.setValue(bookItem.text?.replacingOccurrences(of: "簡介：\r\n          ", with: ""), forKey: "desc");
                        }
                    }
                    listArray.add(tempDic);
                }
                dic.setValue(listArray, forKey: "List");
                
            }
            
            //            print("dogString : \(dogString)")
        } catch let error {
            print("Error: \(error)")
        }

        
        return dic;
    }
    
    func getPeopleList(_ listUrl:String,pageIndex:Int) -> NSDictionary{
        let listArray = NSMutableArray();
        let dic = NSMutableDictionary();
        
        var finalString = "";
        
        if listUrl == "11" {
            finalString = "http://www.mytxt.cc/modules/article/articlelist.php?fullflag=1&page=\(pageIndex)";
        }
        else {
            finalString = "\(self.peopleHostURL)mulu/\(listUrl)-\(pageIndex).html";
        }
        
        do {
//            let dogString = changeDogStringToPeopleString(try Data(contentsOf: URL(string: finalString)!));
            let dogString = changeDogStringToPeopleStringforPeople(try Data(contentsOf: URL(string: finalString)!))
            
            if let doc = try? HTML(html: dogString, encoding: .utf8) {
                
                
                for link in doc.xpath("//div[@id='alist_m62topxs']/div[@id='alistbox_m62topxs']") {
                    let tempDic = NSMutableDictionary();
                    
                
                    
                    tempDic.setValue(link.at_xpath("div[@class='info']/div[@class='title']/h2/a")?["href"]!, forKey: "url");
                    
                    
                    tempDic.setValue(link.at_xpath("div[@class='pic']/a")?.at_xpath("img")?["src"]!, forKey: "image");
                    tempDic.setValue(link.at_xpath("div[@class='pic']/a")?.at_xpath("img")?["title"]!, forKey: "title");
                    
                    tempDic.setValue(link.at_xpath("div[@class='info']/div[@class='title']/span/a")?.text!, forKey: "author");
                    tempDic.setValue(link.at_xpath("div[@class='info']/div[@class='intro']")?.text!, forKey: "desc");
                    
                    for bookItem in link.xpath("div[@class='book-info']/dl/dt") {
                        
                        if bookItem.text?.contains("作者：") == true{
                            tempDic.setValue(bookItem.text!, forKey: "author");
                        }
                        else if bookItem.text?.contains("簡介：") == true {
                            tempDic.setValue(bookItem.text?.replacingOccurrences(of: "簡介：\r\n          ", with: ""), forKey: "desc");
                        }
                    }
                    listArray.add(tempDic);
                }
                dic.setValue(listArray, forKey: "List");
                
            }
            
            //            print("dogString : \(dogString)")
        } catch let error {
            print("Error: \(error)")
        }
        
        
        return dic;
    }

    
    func getNovel(_ novelUrl: String) -> NSDictionary{
        
        let listArray = NSMutableArray();
        let dic = NSMutableDictionary();
        
        guard let myURL = URL(string: "\(self.hostURL)\(novelUrl)") else {
            print("Error: \(self.hostURL) doesn't seem to be a valid URL")
            return [:];
        }
        
        do {
            let dogString = changeDogStringToPeopleString(try Data(contentsOf: myURL));
            
            if let doc = try? HTML(html: dogString, encoding: .utf8) {
                
                var descString = "";
                
                dic.setValue(doc.at_xpath("//dl[@class='jieshao']/dt[@class='jieshao-img']/a/img")?["alt"]!, forKey: "title");
                dic.setValue(doc.at_xpath("//dl[@class='jieshao']/dt[@class='jieshao-img']/a/img")?["src"]!, forKey: "image");
                dic.setValue(doc.at_xpath("//dl[@class='jieshao']/dt[@class='jieshao-img']/a/span[@class='status-text']")?.text!, forKey: "state");
                dic.setValue(doc.at_xpath("//dl[@class='jieshao']/dd[@class='jieshao_content']/h2/a")?.text!, forKey: "author");
                
                if let firstString = doc.at_xpath("//dl[@class='jieshao']/dd[@class='jieshao_content']/h3")?.text!.replacingOccurrences(of: "http://Www.uukanshu.net              \r\n              \r\n                －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－\r\n              ", with: ""){
                    descString = descString + firstString;
                }
                
                
                if let secondString = doc.at_xpath("//dl[@class='jieshao']/dd[@class='jieshao_content']/p")?.text?.replacingOccurrences(of: "\r\n    ", with: "") {
                    descString = descString + secondString
                }
                
                 dic.setValue(descString, forKey: "desc");
                
                for link in doc.xpath("//div[@class='zhangjie clear']/ul[@id='chapterList']/li") {
                    
                    if link["class"] != "volume" {
                        let tempDic = NSMutableDictionary();
                        
                        tempDic.setValue(link.at_xpath("a")?["href"]!, forKey: "url");
                        tempDic.setValue(link.at_xpath("a")?.text!, forKey: "title");
                        
                        listArray.insert(tempDic, at: 0);
                    }
                    
                    
                }
                dic.setValue(listArray, forKey: "List");
                
            }
            
        } catch let error {
            print("Error: \(error)")
        }

        
        return dic;
    }
    
    func getPeopleNovel(_ novelUrl: String) -> NSDictionary{
        
        let listArray = NSMutableArray();
        let dic = NSMutableDictionary();
        
        var finalUrl = "";
        
        if novelUrl.contains("http://www.mytxt.cc/") {
            finalUrl = novelUrl;
        }
        else {
            finalUrl = "\(self.peopleHostURL)\(novelUrl)";
        }
        do {
            let dogString = changeDogStringToPeopleStringforPeople(try Data(contentsOf: URL(string: finalUrl)!))
            
            if let doc = try? HTML(html: dogString, encoding: .utf8) {
                
                var descString = "";
                
                dic.setValue(doc.at_xpath("//meta[@name='og:novel:book_name']")?["content"]!, forKey: "title");
                dic.setValue(doc.at_xpath("//meta[@property='og:image']")?["content"]!, forKey: "image");
                dic.setValue(doc.at_xpath("//meta[@name='og:novel:status']")?["content"]!, forKey: "state");
                dic.setValue(doc.at_xpath("//meta[@name='og:novel:author']")?["content"]!, forKey: "author");
                
                if let firstString = doc.at_xpath("//meta[@property='og:description']")?["content"]!.replacingOccurrences(of: "&nbsp;", with: ""){
                    descString = descString + firstString;
                }
                dic.setValue(descString, forKey: "desc");
                
                for link in doc.xpath("//div[@class='story_list_m62topxs']/div[@class='cp_list_m62topxs']") {
                    
                    for secondLink in link.xpath("ol[@class='cp_dd_m62topxs']") {
                        let tempDic = NSMutableDictionary();
                        tempDic.setValue(secondLink.at_xpath("li/a")?["href"]!, forKey: "url");
                        tempDic.setValue(secondLink.at_xpath("li/a")?.text!, forKey: "title");
                        listArray.insert(tempDic, at: 0);
                    }
                }
                dic.setValue(listArray, forKey: "List");
                
            }
            
        } catch let error {
            print("Error: \(error)")
        }
        
        
        return dic;
    }
    
    func getPeopleContent(_ contentUrl: String) -> NSDictionary{
        
        let dic = NSMutableDictionary();
        
        var finalUrl = "";
        
        if contentUrl.contains("http://www.mytxt.cc/") {
            finalUrl = contentUrl;
        }
        else {
            finalUrl = "\(self.peopleHostURL)\(contentUrl)";
        }
        
        do {
//            let dogString = changeDogStringToPeopleString(try Data(contentsOf: URL(string: finalUrl)!));
            let dogString = changeDogStringToPeopleStringforPeople(try Data(contentsOf: URL(string: finalUrl)!))
            var tempString = "";
            
            if let doc = try? HTML(html: dogString, encoding: .utf8) {
                
                dic.setValue(doc.at_xpath("//div[@class='chapter_info_main_m62topxs']/h1")?.text!, forKey: "title");
                
                tempString = (doc.at_xpath("//div[@class='detail_con_m62topxs']")?.innerHTML?
                    
                    .replacingOccurrences(of: "<br>", with:"\n")
                    .replacingOccurrences(of: "<p>", with:"")
                    .replacingOccurrences(of: "</p>", with:"\n")
                    .replacingOccurrences(of: "&nbsp;", with:"\t"))!
                
                let offset:Range = tempString.range(of: "<p style=\"font-size:11.3px;\">")!
                
                tempString = tempString.substring(to: offset.lowerBound);
                
//                tempString.removeSubrange(tempString.range(of: "<p style=\"font-size:11.3px;\">")!);
                
                

//
                dic.setValue(tempString, forKey: "newContent");
                
            }
            
        } catch let error {
            print("Error: \(error)")
        }
        
        
        return dic;
    }
    
    func getContent(_ contentUrl: String) -> NSDictionary{
    
        let dic = NSMutableDictionary();
        
        guard let myURL = URL(string: "\(self.hostURL)\(contentUrl)") else {
            print("Error: \(self.hostURL) doesn't seem to be a valid URL")
            return [:];
        }
        
        do {
            let dogString = changeDogStringToPeopleString(try Data(contentsOf: myURL));
            var tempString = "";
            
            if let doc = try? HTML(html: dogString, encoding: .utf8) {
                
                dic.setValue(doc.at_xpath("//div[@class='h1title']/h1")?.text!, forKey: "title");
//                dic.setValue(doc.at_xpath("//div[@id='contentbox']")?.text?.replacingOccurrences(of: "(adsbygoogle = window.adsbygoogle || []).push({});", with: "").replacingOccurrences(of: "\r\n", with: "").replacingOccurrences(of: "　　", with: "\n"), forKey: "content");
                var content = doc.at_xpath("//div[@id='contentbox']")?.innerHTML!;
                var noAd = false;
                repeat {
                    if (content!.contains("<div class=\"ad_content\">")) {
                        let replaceString = content!.slice(from: "<div class=\"ad_content\">", to: "</div>")
                        
                        content = content?.replacingOccurrences(of: replaceString!, with: "");
                    }
                    else {
                        noAd = true;
                    }
                    
                }while(noAd == false);
                
                
                dic.setValue(content!.replacingOccurrences(of: "<br>", with:"\n").replacingOccurrences(of: "<p>", with:"").replacingOccurrences(of: "</p>", with:"\n").replacingOccurrences(of: "&nbsp;", with:"\t"), forKey: "content");

                tempString = dic["content"] as! String;
                
                dic.setValue(tempString, forKey: "newContent");
                
            }
            
        } catch let error {
            print("Error: \(error)")
        }
        
        
        return dic;
    }
    
    func changeDogStringToPeopleStringforPeople(_ dogData:Data) -> String {
        
        let cfEnc = CFStringEncodings.GB_18030_2000;
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue));
        var peopleString = String(data: dogData, encoding: String.Encoding(rawValue: enc))
        
        if peopleString == nil {
            peopleString = String(data: dogData, encoding: .utf8)
        }
        
        
        if peopleString != nil {
            if appdelegate?.languageChoose == "cn" {
                return peopleString!;
            }
            else {
                //            return (peopleString!).reve;
                let string = NSString(string: peopleString!);
                let zhString = string.reverse();
                
                return zhString!;
                
            }
        }
        else {
            return "";
        }
    }
    
    func changeDogStringToPeopleString(_ dogData:Data) -> String {
        
        let cfEnc = CFStringEncodings.GB_18030_2000;
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue));
        
        
        let peopleString = String(data: dogData, encoding: String.Encoding(rawValue: enc))
        
        if peopleString != nil {
            if appdelegate?.languageChoose == "cn" {
                return peopleString!;
            }
            else {
                //            return (peopleString!).reve;
                let string = NSString(string: peopleString!);
                let zhString = string.reverse();
                
                return zhString!;
                
            }
        }
        else {
            return "";
        }
    }
    
    
    
}
