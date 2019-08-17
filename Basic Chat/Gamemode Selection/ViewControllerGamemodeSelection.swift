//
//  ViewControllerGamemodeSelection.swift
//  Planet Pong
//
//  Created by Mac on 6/10/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

//TODO!

import Foundation
import UIKit

struct cellData {
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
}

class ViewControllerGamemodeSelection: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var tableViewData = [cellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.tableView.delegate = self
        
        self.tableView.dataSource = self
        
        tableViewData = [cellData(opened: false, title: "CLASSIC", sectionData: ["1-8 Players", "Be the first to hit all 10 cups!","Play Now"]), cellData(opened: false, title: "SNIPER", sectionData: ["1-4 Players", "Snipe the targets and collect the most bounty.","Play Now"]), cellData(opened: false, title: "WAR", sectionData: ["2-3 Players", "Capture all the cups to be crowned King of Pong Island!","Play Now"]), cellData(opened: false, title: "HORSE", sectionData: ["2-4 Players", "Complete the same shot as the other players, or face the consequences!","Play Now"])]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableViewData[section].opened) {
            return tableViewData[section].sectionData.count+1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].title
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[indexPath.row-1]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if tableViewData[indexPath.section].opened == true {
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
    }

}
