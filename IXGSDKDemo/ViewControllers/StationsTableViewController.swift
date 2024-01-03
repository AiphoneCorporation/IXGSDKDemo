//
//  StationListTableTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit
import AiphoneIntercomCorePkg

class StationsTableViewController: UITableViewController {
    var stations = [Station]()
    let stationsManager = StationsManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "StationCellView", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: StationsTableViewCell.cellIdentifier)
        
        let response = stationsManager.fetchStations(auth: "TODO")
        switch response {
        case .success(let stations):
            self.stations = stations
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stations.count//TODO: size of stations list
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StationsTableViewCell.cellIdentifier, for: indexPath) as? StationsTableViewCell else { return UITableViewCell() }
        
        if let station = stations[safeIndex: indexPath.row] {
            
            // Configure the cell...
            cell.configure(station: station)
        }
        

        return cell
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

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex
        else { return nil }
        
        return self[index]
    }
}
