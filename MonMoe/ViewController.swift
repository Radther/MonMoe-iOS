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
    
    let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.dimsBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = true
        return controller
    }()
    
    var filtering: Bool = false
    
    var days: [Day]?
    var tableViewDays: [Day]? {
        switch filtering {
        case true:
            var filteredDays = [Day]()
            days?.forEach({ (day) in
                let newEpisodes = day.episodes.filter({ (episode) -> Bool in
                    guard let searchText = searchController.searchBar.text?.trimmingCharacters(in: .newlines) else {
                        return false
                    }
                    return episode.title.localizedCaseInsensitiveContains(searchText)
                })
                filteredDays.append(Day(date: day.date, episodes: newEpisodes))
            })
            return filteredDays.filter({ (day) -> Bool in
                day.episodes.count>0
            })
        case false:
            return days
        }
    }
    
    var today: Date = Date()
    
    let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd, MMMM, yyyy"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()
    
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
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        
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
                let sortedDays = days.sorted(by: { (day1, day2) -> Bool in
                    day1.date < day2.date
                })
                DispatchQueue.main.async {
                    self.days = sortedDays
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.today = Date()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { (notification) in
            guard let keyboardRect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect else {
                return
            }
            
            self.tableView.contentInset.bottom = keyboardRect.height
        }
        
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { (notification) in
            self.tableView.contentInset.bottom = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewDays?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDays![section].episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let episode = tableViewDays![indexPath.section].episodes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        
        cell.titleLabel.text = episode.title
        cell.detailLabel.text = "Episode: \(episode.number)"
        cell.timeLabel.text = timeFormatter.string(from: episode.date)
        
        switch (episode.first, episode.last) {
        case (true, false):
            cell.colorView.backgroundColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
        case (false, true):
            cell.colorView.backgroundColor = #colorLiteral(red: 0.7411764706, green: 0.2, blue: 0.6431372549, alpha: 1)
        default:
            cell.colorView.backgroundColor = UIColor.gray
        }
        
        cell.airedView.isHidden = episode.date > today
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let day = tableViewDays![section]
        return sectionDateFormatter.string(from: day.date)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return tableViewDays?.map({ (day) -> String in
            dayFormatter.string(from: day.date)
        })
    }
    
}

extension ViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text Change")
        updateTableView()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        filtering = true
        updateTableView()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        filtering = false
        updateTableView()
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
}
