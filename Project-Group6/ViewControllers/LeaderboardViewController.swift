//
//  LeaderboardViewController.swift
//  Project-Group6
//
//  Created by Sophie School on 2026-07-30.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    var rankedPeople: [PeopleData] = []
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let startDate = startDatePicker.date
            let endDate = endDatePicker.date
            rankedPeople = mainDelegate.people
                .filter { person in
                    guard let birthDateString = person.dateofBirth,
                          let birthDate = formatter.date(from: birthDateString) else {
                        return false
                    }
                    return birthDate >= startDate && birthDate <= endDate
                }
                .sorted {
                    ($0.score ?? 0) > ($1.score ?? 0)
                }
            tableView.reloadData()
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainDelegate.readDataFromDatabase()
        rankedPeople = mainDelegate.people.compactMap { $0 }
            .sorted { ($0.score ?? 0) > ($1.score ?? 0) }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankedPeople.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "leaderboardcell") as? LeaderboardTableViewCell ?? LeaderboardTableViewCell(style: .default, reuseIdentifier: "leaderboardcell")
        let person = rankedPeople[indexPath.row]
        
        tableCell.lblRank.text = "\(indexPath.row + 1)"
        tableCell.lblUsername.text = person.username ?? ""
        tableCell.lblScore.text = "\(person.score ?? 0)"

        return tableCell
    }

}
