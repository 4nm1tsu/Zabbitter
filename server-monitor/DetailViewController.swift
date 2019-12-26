//
//  DetailViewController.swift
//  server-monitor
//
//  Created by Hibiki Okada on 2019/12/26.
//  Copyright © 2019 Hibiki Okada. All rights reserved.
//

import UIKit
class CookieHelper {
    func generate(key: String = "key", value: String = "value") -> HTTPCookie {
        let cookieProperty: [HTTPCookiePropertyKey: Any] = [
            HTTPCookiePropertyKey.domain: "",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: key,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.secure: "TRUE",
            HTTPCookiePropertyKey.expires: Date()
        ]

        return HTTPCookie(properties: cookieProperty)!
    }
}
class DetailViewController: UIViewController {
    var info: graphdetail!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //info.name,info.graphid has been passed
        navigationItem.title = info.name
        graphGet()
    }
    
    func graphGet(){
        var url = "https://" + Domain + "/zabbix/chart2.php?"
        url += "graphid=\(info.graphid)&"
        url += "period=3600"
        // create the url-request
        do{
            request = try NSMutableURLRequest(url: URL(string: url)!)
            
            let cookieStr = "zbx_sessionid" + "=" + accessToken + ";Secure"
            let cookieHeaderField = ["Set-Cookie": cookieStr]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: URL(string: url)!)
            HTTPCookieStorage.shared.setCookies(cookies, for: URL(string: url), mainDocumentURL: URL(string: url))
            request?.httpMethod="GET"
        }
        catch{
            print("error during making a request.")
        }
        do{
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request! as URLRequest, completionHandler: {(data,response,error) -> Void in
                if let _ = data,let image=UIImage(data:data!){
                    DispatchQueue.main.async{
                    self.imageView.image = image
                    }
                    print("aaaaa:\(image)")
                    //UI処理
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                    })
                }
                else{
                    print("data has no value")
                }
            })
            task.resume()
        }catch{
            print("Error:\(error)")
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
