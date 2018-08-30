//
//  SearchResultsTableViewController.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 29/08/18.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {

    var viewModel: SearchResultsViewModel
    
    var lastQueryString: String = ""
    
    init(viewModel: SearchResultsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PlaceTypeCell.self, forCellReuseIdentifier: PlaceTypeCell.reuseIdentifier)
        tableView.register(AutocompletePredictionCell.self, forCellReuseIdentifier: AutocompletePredictionCell.reuseIdentifier)
        
        viewModel.updateTableResultsTrigger.bind { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfResultSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""//HEADER \(section)"
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // this here
//        guard let section = ResultCellType(rawValue: indexPath.section) else { return UITableViewCell() }
        let section = viewModel.cellTypeForRow()
        
        switch section {
        case .placeType:
            return cellForPlaceTypeSectionForRowAt(indexPath)
        case .autocompletePlace:
            return cellForAutocompleteResultSectionForRowAt(indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath)
    }
    
    private func cellForPlaceTypeSectionForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTypeCell.reuseIdentifier) as! PlaceTypeCell
        cell.model = viewModel.placeTypeForRowAt(indexPath)
        return cell
    }
    
    private func cellForAutocompleteResultSectionForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AutocompletePredictionCell.reuseIdentifier) as! AutocompletePredictionCell
        cell.model = viewModel.autocompletePredictionForRowAt(indexPath)
        return cell
    }
}

extension SearchResultsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Send partial string to autocomplete query
        let queryString = searchController.searchBar.text ?? ""
        viewModel.updateSearchResults(partialString: queryString)
        
        // Force view unhide only if the text was erased
        if queryString.isEmpty && !lastQueryString.isEmpty {
            searchController.searchResultsController?.view.isHidden = false
        }
        lastQueryString = queryString
    }
}

extension SearchResultsTableViewController: UISearchBarDelegate {
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        //        print("Search Bar did end editing")
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("Search Button clicked, current string: \(searchBar.text ?? "no_text")")
        // send search
        let searchText = searchBar.text ?? ""
        viewModel.didPressSearchButton(searchText)
    }
    
//    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        //        print("Search Bar should begin")
////        searchBar.pare
//        return true
//    }
}



enum ResultCellType: Int {
    case placeType
    case autocompletePlace
    // maybe history?
}










