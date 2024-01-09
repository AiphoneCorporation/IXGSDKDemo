//
//  RecordingsTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import AiphoneIntercomCorePkg
import SwiftUI

class RecordingsTableViewController: UITableViewController {
    let callRecordsManager = CallRecordsManager()//SDK records manager
    let searchController = UISearchController(searchResultsController: nil)//handles search bar and tab bar
    let scopeButtons = RecordsFilterScope.allCases.map{ $0 }//tab bar
    private var scopeButton: RecordsFilterScope = .all//sets default state of tab bar to all tab
    var allRecords = [CallRecord]()//default array of call record type to hold entire list of user records
    private(set) var filteredRecords: [CallRecord] = []//list to only hold the list of records the are valid under current filter perameters
    private let cellLLeadingIndentCompensationValue: CGFloat = -12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task{
            let response = await callRecordsManager.fetchRecords()//fetches all records from SDK
            switch response {
            case .success(let records):
                self.allRecords = records
                self.filteredRecords = allRecords//sets filtered records to desired default state of all records
                tableView.reloadData()//updates list now that we have data
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        self.configureSearchController()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//should always be one based on current implementation
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecords.count//size of list based on current filter perameters
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordingsListCell", for: indexPath)//the current cell to be displayed
        let record = filteredRecords[indexPath.row]//the record tied to current cell
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.hour, .minute, .second]
        
        // Configure the cell...
        cell.contentConfiguration = UIHostingConfiguration {
            HStack() {
                VStack{
                    if record.type == .outgoing {
                        Image(systemName: "phone.arrow.up.right").imageScale(.small).padding(.leading, cellLLeadingIndentCompensationValue)
                    } else {
                        Image(systemName: "phone.arrow.up.right").imageScale(.small).padding(.leading, cellLLeadingIndentCompensationValue).hidden()
                    }
                }
                
                VStack(alignment: .leading) {
                    let color = if(record.type == .missed) { Color.red } else { Color.black }//text color will be red if missed, black if not
                    
                    Text(record.stationName).font(.headline).foregroundStyle(color)
                    Text(record.callStarted.formatted(date: .abbreviated, time: .shortened)).font(.footnote).foregroundStyle(color)
                }
                
                Spacer()
                
                VStack(alignment: .center){
                    if(record.url != nil){
                        Image(systemName: "play.circle").imageScale(.large).foregroundColor(.blue)
                    }
                    if let duration = record.duration {
                        Text(formatter.string(from: duration) ?? "").font(.footnote)
                    }
                }
            }
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

extension RecordingsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func configureSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.scopeButtonTitles = ["All", "Manual Rec.", "Missed Call"]//tab titles
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex//current tab position
        let buttonScope = scopeButtons[selectedScopeButtonIndex]//scope tied to current tab position
        filterRecordsBySearchScope(scope: buttonScope, searchText: searchController.searchBar.text ?? "")//filters list based on scope
        tableView.reloadData()//updates the list now that we have new filter perameters
    }
    
    func filterRecordsBySearchScope(scope: RecordsFilterScope, searchText: String) {
        scopeButton = scope//sets the tab button to the current position
        filteredRecords = allRecords.filter{ record in
            let recordTypeCondition = record.isMatch(for: scopeButton)//filter list based on current tab
            //record is valid if search is empty or if search is included in the stations name of the record
            let searchCondition = searchText.isEmpty || record.stationName.lowercased().contains(searchText.lowercased())
            return recordTypeCondition && searchCondition
        }
    }
}

enum RecordsFilterScope: CaseIterable {//current tab filter perameters
    case all//all records
    case manual//only records that have a manual recording
    case missed//only records that are missed calls
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
