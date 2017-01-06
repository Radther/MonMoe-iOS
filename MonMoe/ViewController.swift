//
//  ViewController.swift
//  MonMoeApp
//
//  Created by Tom Sinlgeton on 06/01/2017.
//  Copyright © 2017 Tom Sinlgeton. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var days: [Day]?
    
    let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
//    let sectionDateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE, dd"
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateData()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 94
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        updateData()
    }

    func updateData() {
        refreshControl.beginRefreshing()
        MONAPI.getCalendar { (result) in
            switch result {
            case let .success(days):
                DispatchQueue.main.async {
                    self.days = days
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            case let .failure(error):
                print(error)
            }
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days![section].episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let episode = days![indexPath.section].episodes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        
        cell.titleLabel.text = episode.title
        cell.detailLabel.text = "Episode: \(episode.number)"
        
        switch (episode.first, episode.last) {
        case (true, false):
            cell.colorView.backgroundColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
        case (false, true):
            cell.colorView.backgroundColor = #colorLiteral(red: 0.7411764706, green: 0.2, blue: 0.6431372549, alpha: 1)
        default:
            cell.colorView.backgroundColor = UIColor.gray
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let day = days![section]
//        
//    }
    
}

