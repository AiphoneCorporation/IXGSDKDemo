//
//  RecordingsTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit
import AiphoneIntercomCorePkg
import SwiftUI

class RecordingsTableViewController: UITableViewController {
    let callRecordsManager = CallRecordsManager()
    let searchController = UISearchController(searchResultsController: nil)
    let scopeButtons = RecordsFilterScope.allCases.map{ $0 }
    var allRecords = [CallRecord]()
    
    
    private(set) var filteredRecords: [CallRecord] = []
    private var scopeButton: RecordsFilterScope = .all

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task{
            let response = await callRecordsManager.fetchRecords()
            switch response {
            case .success(let records):
                self.allRecords = records
                self.filteredRecords = allRecords
                tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
        
        self.configureSearchController()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecords.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordingsListCell", for: indexPath)

        let recording = filteredRecords[indexPath.row]
        
        // Configure the cell...
        let color = if(recording.type == .missed) { UIColor.red } else { UIColor.black }
        
        let textLabel = cell.textLabel
        let detailTextLabel = cell.detailTextLabel
        
        textLabel?.text = recording.stationName
        textLabel?.textColor = color
        
        detailTextLabel?.text = recording.callStarted.formatted(date: .abbreviated, time: .shortened)
        detailTextLabel?.textColor = color
        
        if(recording.type == .outgoing) { cell.imageView?.isHidden = false }
        else { cell.imageView?.isHidden = true }//required because the state is tied to cell position, not cell object

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

extension RecordingsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func configureSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = .search
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All", "Manual Rec.", "Missed Call"]
        searchController.searchBar.showsScopeBar = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        let buttonScope = scopeButtons[selectedScopeButtonIndex]
        filterRecordsBySearchScope(scope: buttonScope)
        tableView.reloadData()
    }
    
    func filterRecordsBySearchScope(scope: RecordsFilterScope) {
        scopeButton = scope
        
        filteredRecords = allRecords.filter{ $0.isMatch(for: scope) }
    }
}

enum RecordsFilterScope: CaseIterable {
    case all
    case manual
    case missed
}

extension CallRecord{
    func isMatch(for scope: RecordsFilterScope) -> Bool {
        switch scope {
        case .all:
            return true
        case .manual:
            return self.isManualRecording
        case .missed:
            return self.type == .missed
        }
    }
}
