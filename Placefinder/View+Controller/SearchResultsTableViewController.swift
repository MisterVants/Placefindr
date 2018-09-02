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
    
    
    // MARK: - Initialization
    
    init(viewModel: SearchResultsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)

        tableView.register(PlaceTypeCell.self, forCellReuseIdentifier: PlaceTypeCell.reuseIdentifier)
        tableView.register(AutocompletePredictionCell.self, forCellReuseIdentifier: AutocompletePredictionCell.reuseIdentifier)
        
        // Bind data reload
        viewModel.updateTableResults.bind { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfResultSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // not done yet
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellType = viewModel.cellTypeForIndexPath(indexPath) else { return UITableViewCell() }
        
        switch cellType {
        case .placeType:
            return cellForPlaceTypeSectionForRowAt(indexPath)
        case .autocompleteSuggestion:
            return cellForAutocompleteResultSectionForRowAt(indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath)
    }
    
    private func cellForPlaceTypeSectionForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTypeCell.reuseIdentifier) as! PlaceTypeCell
        cell.model = viewModel.placeSuggestionForRowAt(indexPath)
        return cell
    }
    
    private func cellForAutocompleteResultSectionForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AutocompletePredictionCell.reuseIdentifier) as! AutocompletePredictionCell
        cell.model = viewModel.autocompletePredictionForRowAt(indexPath)
        return cell
    }
    
    // Prevents keyboard from covering last TableView cells
    @objc
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            
            let isOpening = (endFrameY < UIScreen.main.bounds.size.height)
            if isOpening {   // opening
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIScreen.main.bounds.size.height - endFrameY, right: 0)
            } else {         // closing
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
}


// MARK: - Search Results Updater

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


// MARK: - UISearchBar Delegate

extension SearchResultsTableViewController: UISearchBarDelegate {
    
    // Send text search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text ?? ""
        viewModel.didPressSearchButton(searchText)
    }
}














