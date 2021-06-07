//
//  TableViewController.swift
//  AnotherRedditClient
//
//  Created by Kaan Karay on 4.06.2021.
//
import UIKit

class TableViewController: UITableViewController {
    
    var customRefreshControl = UIRefreshControl()
    
    ///Kick starting the loop by downloading first {threadCount} posts manually.
    func kickStart() {
        getPosts { firstResults in
            /// These results has 2 keys, ["data", "kind"] we are interested with what firstResults["data"] has.
            for k in 0...threadCount-1{
                let post = anyObjectToJSON(obj: firstResults[k]["data"]!)
                do {
                    let encodedData = try NSKeyedArchiver.archivedData(withRootObject: post, requiringSecureCoding: false)
                    UserDefaults.standard.setValue(encodedData, forKey: "postNo\(k)") /// Saves as Dictionary<String, Any>
                    passIDArr[k] = "+" // Means we saved this value and cell can use userDefaults to read it.
                } catch let err { print("Error saving the data to userdefaults : \(err.localizedDescription)") }
                passIDArr[k + threadCount] = post["name"] as! String // Referance to download for the threadCount'th cell.
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.customRefreshControl.endRefreshing()
            }
        }
    }
    
    @objc func pullToRefresh(_ sender:AnyObject){
        passIDArr = []
        for _ in 0...maxPostsInPage-1 { passIDArr.append("") } /// Fill the ID passing array.
        kickStart()
        
    }
    
    // MARK: - View did... methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "cellID")
        tableView.rowHeight = UITableView.automaticDimension /// Change the row height depending on the thumbnail image.
        tableView.estimatedRowHeight = 160
        customRefreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableView.addSubview(customRefreshControl)
        
        kickStart()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for _ in 0...maxPostsInPage-1 { passIDArr.append("") } /// Fill the ID passing array.
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return maxPostsInPage }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 160 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! PostCell
        cell.superTableController = self /// For alertViews and etc, we need an reference to this UITableViewController
        cell.cellNumber = indexPath.row
        cell.updateView()
        print(passIDArr)
        
        return cell
    }
    
}
