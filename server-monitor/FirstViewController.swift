//
//  FirstViewController.swift
//  server-monitor
//
//  Created by Hibiki Okada on 2019/12/24.
//  Copyright © 2019 Hibiki Okada. All rights reserved.
//

import UIKit

struct login: Codable {
    let jsonrpc: String
    let result: String
    let id: Int
}
struct Logout: Codable{
    let jsonrpc: String
    let result: Bool?
    let id: Int
}
struct get: Codable {
    let jsonrpc: String?
    let result: [Result]
    struct Result: Codable{
        let hostid: String?
        let proxy_hostid: String?
        let host: String?
        let status: String?
        let disable_until: String?
        let error: String?
        let available: String?
        let errors_from: String?
        let lastaccess: String?
        let ipmi_authtype: String?
        let ipmi_privilege: String?
        let ipmi_username: String?
        let ipmi_password: String?
        let ipmi_disable_until: String?
        let ipmi_available: String?
        let maintenanceid: String?
        let maintenance_status: String?
        let maintenance_type: String?
        let maintenance_from: String?
        let ipmi_errors_from: String?
        let snmp_errors_from: String?
        let ipmi_erorr: String?
        let snmp_error: String?
        let jmx_disable_until: String?
        let jmx_available: String?
        let jmx_errors_from: String?
        let jmx_error: String?
        let name: String?
        let flages: String?
        let templateid: String?
        let description: String?
        let tls_connect: String?
        let tls_accept: String?
        let tls_issuer: String?
        let tls_subject: String?
        let tls_psk_identity: String?
        let tls_psk: String?
        let proxy_address: String?
        let auto_compress: String?
        let inventory_mode: String?
    }
    let id: Int
}
var accessToken: String = ""
var serverName: String = "disconnected"
var hostid: String = ""
var request: NSMutableURLRequest? = nil
var Domain: String = ""

class FirstViewController: UIViewController, UITextFieldDelegate{
    var result: String = ""
    
    @IBOutlet weak var domain: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var status: UILabel!
    @IBAction func logout(_ sender: UIButton) {
      
        if accessToken != ""{
              logout()
            self.domain.text=""
            self.username.text=""
            self.password.text=""
            accessToken = ""
            serverName = "disconnected"
            hostid = ""
            request = nil
            Domain = ""
        }
    }
    
    @IBAction func getAccessToken(_ sender: UIButton) {
        //未入力の場合
        if domain.text=="" || username.text=="" || password.text=="" {
            status.text="fill all the blank."
        }
        else{
            //アクセストークン未取得の場合新たに取得
            if accessToken==""{
                status.text=""
                Domain = domain.text ?? "disconnected"
                
                
                var url = "https://" + domain.text! + "/zabbix/api_jsonrpc.php"
                // create the url-request
                do{
                    if let tmpUrl = URL(string: url){
                        request = try NSMutableURLRequest(url: tmpUrl)
                    }
                    //request body 作成
                    
                    request?.httpMethod="POST"
                    
                    request?.addValue("application/json-rpc", forHTTPHeaderField: "Content-Type")
                    
                    let params:[String:Any] = [
                        "method": "user.login",
                        "params":[
                            "password": self.password.text!,
                            "user": self.username.text!,],
                        "id": 1,
                        "jsonrpc": "2.0"
                    ]
                    
                    do{
                        request?.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                        if let request = request{
                            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as! URLRequest, completionHandler: {(data,response,error) -> Void in
                                let resultData = String(data: data ?? "".data(using: .utf8)!, encoding: .utf8)!
                                print("result:\(resultData)")
                                print("response:\(response)")
                                //UI処理
                                DispatchQueue.main.async(execute: { () -> Void in
                                    //jsonのパース
                                    self.result = resultData
                                    do {
                                        let json: login = try JSONDecoder().decode(login.self, from: self.result.data(using: .utf8)!)
                                        print(json)
                                        do{
                                            accessToken = try! json.result
                                        }
                                        catch{
                                            self.status.text="no response's returned"
                                        }
                                        if json.result != nil{
                                            self.userGet(request: request,auth: accessToken)
                                        }
                                    } catch {
                                        print("error:", error.localizedDescription)
                                        self.status.text="invalid domain or username or password"
                                    }
                                })
                            })
                            task.resume()
                        }
                    }catch{
                        print("Error:\(error)")
                        self.status.text="request error"
                    }
                }
                catch {
                    self.status.text="domain is invalid"
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.domain.text=""
        self.username.text=""
        self.password.text=""
        self.status.text=""
        domain.delegate = self
        username.delegate = self
        password.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }

    func userGet(request:NSMutableURLRequest,auth:String){
        let params:[String:Any] = [
            "auth": auth,
            "method": "host.get",
            "params":[
                "password": self.password.text!,
                "user": self.username.text!,],
            "id": 1,
            "jsonrpc": "2.0"
        ]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)!
                print("resultData:\(resultData)")
                //UI処理
                DispatchQueue.main.async(execute: { () -> Void in
                    //jsonのパース
                    self.result = resultData
                    do {
                        let json: get = try JSONDecoder().decode(get.self, from: self.result.data(using: .utf8)!)
                        if !json.result.isEmpty{
                            serverName=json.result[0].host!
                            hostid=json.result[0].hostid!
                            self.status.text="You're now logged in!"
                        }
                        else{
                            self.status.text="no response received"
                            accessToken = ""
                            serverName = "disconnected"
                            hostid = ""
                            Domain = ""
                        }
                    } catch {
                        print("error:", error.localizedDescription)
                        self.status.text="invalid username or password"
                    }
                })
            })
            task.resume()
        }catch{
            print("Error:\(error)")
            self.status.text="request error"
            return
        }
        
    }
    func logout(){
        var url = "https://" + Domain + "/zabbix/api_jsonrpc.php"
        // create the url-request
        
        if let tmpUrl = URL(string: url){
            request = try NSMutableURLRequest(url: tmpUrl)
        }
        //request body 作成
        
        request?.httpMethod="POST"
        
        request?.addValue("application/json-rpc", forHTTPHeaderField: "Content-Type")
        
        
        let params:[String:Any] = [
            "auth": accessToken,
            "method": "user.logout",
            "params":[],
            "id": 1,
            "jsonrpc": "2.0"
        ]
        
        do{
            if let _ = request{
            request!.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as! URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)!
                print("resultData:\(resultData)")
                //UI処理
                DispatchQueue.main.async(execute: { () -> Void in
                    //jsonのパース
                    self.result = resultData
                    do {
                        let json: Logout = try JSONDecoder().decode(Logout.self, from: self.result.data(using: .utf8)!)
                        if json.result ?? false{
                            print("\(json.result)")
                            self.status.text="You're not logged in"
                        }
                        else{
                            self.status.text="logout failed"
                        }
                    } catch {
                        print("error:", error.localizedDescription)
                        self.status.text="invalid username or password"
                    }
                })
            })
            task.resume()
            }
        }catch{
            print("Error:\(error)")
            self.status.text="request error"
            return
        }
        
    }
    
    
}

