//
//  SecondViewController.swift
//  server-monitor
//
//  Created by Hibiki Okada on 2019/12/24.
//  Copyright © 2019 Hibiki Okada. All rights reserved.
//

import UIKit
struct graphs: Codable{
    var jsonrpc: String?
    var result: [Result]?
    struct Result: Codable{
        var graphid: String?
        var name: String?
        var width: String?
        var height: String?
        var yaxismin: String?
        var yaxismax: String?
        var templateid: String?
        var show_work_period: String?
        var show_triggers: String?
        var graphtype: String?
        var show_legend: String?
        var show_3d: String?
        var percent_left: String?
        var percent_right: String?
        var ymin_type: String?
        var ymax_type: String?
        var ymin_itemid: String?
        var ymax_itemid: String?
        var flags: String?
    }
    var id: Int?
}
struct graphdetail{
    var graphid: String
    var name: String
}
extension graphdetail: Comparable {

    static func == (lhs: graphdetail, rhs: graphdetail) -> Bool {
        return lhs.name == rhs.name
    }

    static func < (lhs: graphdetail, rhs: graphdetail) -> Bool {
        return lhs.name < rhs.name
    }
}

class SecondViewController: UIViewController,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "NameCell")
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    var result: String = ""
    var graph: [String:String] = [:]    {didSet {
        tableView.reloadData()
        }}
    var items = Array<graphdetail>(){didSet {
    tableView.reloadData()
    }}
    var count: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = serverName
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        navigationItem.title = serverName
        if let _=request{
        graphidGet()
        }
        else{
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let selectedRow = tableView.indexPathForSelectedRow{
            let controller = segue.destination as! DetailViewController
            controller.info = items[selectedRow.row]
        }
    }
    func graphidGet(){
        let params:[String:Any] = [
            "auth": accessToken,
            "method": "graph.get",
            "params":[
                "output": "extend",
                "hostids": hostid
            ],
            "id": 1,
            "jsonrpc": "2.0"
        ]
        
        do{
            request?.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as! URLRequest, completionHandler: {(data,response,error) -> Void in
                if let _=data{
                    let resultData = String(data: data!, encoding: .utf8)!
                    //UI処理
                    DispatchQueue.main.async(execute: { () -> Void in
                        //jsonのパース
                        self.result = resultData
                        do {
                            let json: graphs = try JSONDecoder().decode(graphs.self, from: self.result.data(using: .utf8)!)
                            do{self.count = try json.result?.count ?? 0}
                            catch{}
                            if let _ = json.result{
                                if self.items.count==0{
                                    if json.result!.count != 0{
                                        for i in 0...json.result!.count-1{
                                            self.items += [graphdetail(graphid:json.result![i].graphid!, name:json.result![i].name!)]
                                        }
                                    }
                                }
                                self.items.sort()
                            }
                        } catch {
                            print("error:", error.localizedDescription)
                        }
                    })
                }
                else{
                }
            })
            task.resume()
        }catch{
            print("Error:\(error)")
        }
    }
}

