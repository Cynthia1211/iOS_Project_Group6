//
//  TreasuresViewController.swift
//  Project-Group6
//
//  Created by Alexander Tumanan on 2026-08-01.
// Description: "My Treasures" screen. Shows two lists — treasures the
// current user has found, and treasures the current user has placed —
// and lets them navigate to the "Place New Treasure" screen.
import UIKit
class TreasuresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let mainDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet var tableFound: UITableView!
    @IBOutlet var tablePlaced: UITableView!

    var treasuresFound: [Treasure] = []
    var treasuresPlaced: [Treasure] = []

    var currentUserUUID: String {
        mainDelegate.people
            .first(where: { $0.email?.lowercased() == mainDelegate.currentEmail.lowercased() })?
            .uuid ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableFound.dataSource = self
        tableFound.delegate = self
        tablePlaced.dataSource = self
        tablePlaced.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload every time the tab is shown, so a treasure just placed
        // or just found shows up right away.
        loadTreasures()
    }

    func loadTreasures() {
        mainDelegate.readDataFromDatabase()
        let userUUID = currentUserUUID
        treasuresFound = TreasureManager.shared.searchTreasureByFoundBy(userUUID: userUUID)
        treasuresPlaced = TreasureManager.shared.searchTreasureByPlaceBy(userUUID: userUUID)
        tableFound.reloadData()
        tablePlaced.reloadData()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableFound {
            return treasuresFound.count
        } else {
            return treasuresPlaced.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "treasureHistoryCell") as? TreasureHistoryTableViewCell ?? TreasureHistoryTableViewCell(style: .default, reuseIdentifier: "treasureHistoryCell")

        let treasure = (tableView == tableFound) ? treasuresFound[indexPath.row] : treasuresPlaced[indexPath.row]

        tableCell.lblTitle.text = treasure.title
        let status = treasure.isTreasureFound ? "Found" : "Not found yet"
        tableCell.lblStatus.text = "\(treasure.points) pts • \(status)"

        return tableCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
