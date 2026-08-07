//
//  TreasuresViewController.swift
//  Project-Group6
//
//  Created by Alexander Tumanan on 2026-08-01.
//

import UIKit

// Displays the treasures the current user has found and the treasures
// they have placed.
class TreasuresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let mainDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet var tableFound: UITableView!   // List of treasures found
    @IBOutlet var tablePlaced: UITableView!  // List of treasures placed

    var treasuresFound: [Treasure] = []
    var treasuresPlaced: [Treasure] = []

    // Looks up the UUID of the currently logged-in user by matching
    // their email against the people array.
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

    // Reloads both lists each time this tab is shown.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTreasures()
    }

    // Loads the current user's found and placed treasures from the
    // database and refreshes both table views.
    func loadTreasures() {
        mainDelegate.readDataFromDatabase()
        let userUUID = currentUserUUID
        treasuresFound = TreasureManager.shared.searchTreasureByFoundBy(userUUID: userUUID)
        treasuresPlaced = TreasureManager.shared.searchTreasureByPlaceBy(userUUID: userUUID)
        tableFound.reloadData()
        tablePlaced.reloadData()
    }

    // MARK: - UITableViewDataSource

    // Returns the number of rows for the given table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableFound {
            return treasuresFound.count
        } else {
            return treasuresPlaced.count
        }
    }

    // Configures and returns the cell for the given row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "treasureHistoryCell") as? TreasureHistoryTableViewCell ?? TreasureHistoryTableViewCell(style: .default, reuseIdentifier: "treasureHistoryCell")

        let treasure = (tableView == tableFound) ? treasuresFound[indexPath.row] : treasuresPlaced[indexPath.row]

        tableCell.lblTitle.text = treasure.title
        let status = treasure.isTreasureFound ? "Found" : "Not found yet"
        tableCell.lblStatus.text = "\(treasure.points) pts • \(status)"

        return tableCell
    }

    // Returns a fixed row height for every treasure row.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
