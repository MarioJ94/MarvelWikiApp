//
//  CharacterListViewerViewController.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 28/12/21.
//

import Foundation
import UIKit
import Combine

fileprivate enum CharacterListViewerSection {
    case main
}

fileprivate enum CharacterListViewerMode {
    case searching(criteria: String)
    case fullList
}

fileprivate enum SupplementaryViewKind : String {
    case footer = "footer"
}

fileprivate typealias CharacterFullListViewerSnapshot = SnapshotState<CharacterListViewerSection, CharacterListViewerItem, CharacterListViewerError>
fileprivate typealias CharacterSearchListViewerSnapshot = SnapshotState<CharacterListViewerSection, CharacterListViewerItem, CharacterListSearchViewerError>

final class CharacterListViewerViewController : UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<CharacterListViewerSection, CharacterListViewerItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<CharacterListViewerSection, CharacterListViewerItem>
    var viewModel : CharacterListViewerViewModelUseCase?
    var searchViewModel : CharacterListViewerSearchViewModelUseCase?

    private weak var collectionView: UICollectionView?
    private var dataSource: DataSource?
    private weak var searchBar: UISearchBar?
    private weak var spinner: UIActivityIndicatorView!
    
    private var fullModeSnapshot : SnapshotState = CharacterFullListViewerSnapshot(snapshot: Snapshot(), contentOffset: .zero, lastError: nil)
    private var searchModeSnapshot : SnapshotState = CharacterSearchListViewerSnapshot(snapshot: Snapshot(), contentOffset: .zero, lastError: nil)
    private var currentMode : CharacterListViewerMode = .fullList
    private var fullViewModelSubscription : AnyCancellable? = nil
    private var searchViewModelSubscription : AnyCancellable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Characters"
        self.view.backgroundColor = .defaultBackgroundColor
        self.configureViews()
        self.configureFullListBinding()
        self.showSpinner()
        self.addDismisKeyboardGesture()
    }
    
    private func addDismisKeyboardGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction(sender:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        self.collectionView?.keyboardDismissMode = .onDrag
    }
    
    private func supplementaryViewReuseIdFor(kind: SupplementaryViewKind) -> String{
        switch kind {
        case .footer:
            return "footerId"
        }
    }
    
    @objc
    private func dismissKeyboardAction(sender: UITapGestureRecognizer) {
        let touchedInsideSearchBar: Bool
        if let searchBar = self.searchBar {
            touchedInsideSearchBar = searchBar.bounds.contains(sender.location(in: searchBar))
        } else {
            touchedInsideSearchBar = false
        }
        
        if !touchedInsideSearchBar {
            self.view.endEditing(true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isBeingPresented || self.isMovingToParent {
            self.viewModel?.loadIfNeeded(page: 0)
        }
    }
    
    private func showSpinner() {
        self.spinner.startAnimating()
    }
    
    private func hideSpinner() {
        self.spinner.stopAnimating()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: self.layoutSection(forIndex:environment:))
        return layout
    }
    
    private func numberOfItems(environment: NSCollectionLayoutEnvironment) -> (minimum: CGFloat, maximum: CGFloat) {
        let defaultReturn : (CGFloat,CGFloat) = (4,6)
        let compactHorizontalReturn : (CGFloat,CGFloat) = (2,4)
        let compactVerticalReturn : (CGFloat,CGFloat) = (4,6)
        switch environment.traitCollection.userInterfaceIdiom {
        case .carPlay:
            return defaultReturn
        case .mac:
            return defaultReturn
        case .pad:
            if environment.traitCollection.verticalSizeClass == .compact {
                return compactVerticalReturn
            } else if self.traitCollection.horizontalSizeClass == .compact {
                return compactHorizontalReturn
            } else {
                return defaultReturn
            }
        case .phone:
            if self.traitCollection.verticalSizeClass == .compact {
                return compactVerticalReturn
            } else {
                return compactHorizontalReturn
            }
        case .tv:
            return defaultReturn
        case .unspecified:
            return defaultReturn
        @unknown default:
            return defaultReturn
        }
    }
    
    private func layoutSection(forIndex index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let desiredWidth: CGFloat = 200
        let minMaxValues = self.numberOfItems(environment: environment)
        let minimumItemCount = minMaxValues.minimum
        let maximumItemCount = minMaxValues.maximum
        
        let calculatedItemCount = environment.container.effectiveContentSize.width / desiredWidth
        let itemCount = max(min(calculatedItemCount, maximumItemCount), minimumItemCount)
        
        let fractionWidth: CGFloat = 1 / (itemCount.rounded())
        
        let estimation = NSCollectionLayoutDimension.estimated(desiredWidth)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionWidth),
                                              heightDimension: estimation)
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: estimation)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(itemCount))
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let footerHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(50.0))
        
        let canAddFooter = self.canAddFooter()
        if canAddFooter {
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerHeaderSize,
                elementKind: SupplementaryViewKind.footer.rawValue,
                alignment: .bottom)
            section.boundarySupplementaryItems = [footer]
        }
        
        return section
    }
    
    private func canAddFooter() -> Bool {
        switch currentMode {
        case .searching(_):
            return self.searchViewModel?.canLoadMoreContents(currentItemsOnDisplay: self.searchModeSnapshot.snapshot.numberOfItems) ?? false
        case .fullList:
            return self.viewModel?.canDisplayHintToLoadMoreContents(currentItemsOnDisplay: self.fullModeSnapshot.snapshot.numberOfItems) ?? false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func configureViews() {
        guard self.collectionView == nil && self.dataSource == nil && self.searchBar == nil && self.spinner == nil else {
            return
        }
        
        let searchBarHeight : CGFloat = 50
        // Collection & DataSource
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        
        let footerKind = SupplementaryViewKind.footer
        let reuseFooterId = self.supplementaryViewReuseIdFor(kind: footerKind)
        collectionView.register(SpinnerCollectionViewFooter.self,
                                forSupplementaryViewOfKind: footerKind.rawValue,
                                withReuseIdentifier: reuseFooterId)
        let cellRegistration = UICollectionView.CellRegistration<CharacterCollectionViewCell, CharacterListViewerItem> { (cell, indexPath, item) in
            switch item {
            case .loaded(let model, _):
                cell.label.text = model.name
                cell.loadImage(url: model.thumbnail)
            case .error(let model, _):
                cell.label.text = model.name
            }
        }
        
        let dataSource = DataSource(collectionView: collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell? in
            // Return the cell.
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let self = self else {
                return nil
            }
            if kind == SupplementaryViewKind.footer.rawValue {
                let kind = SupplementaryViewKind.footer
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: footerKind.rawValue,
                                                                           withReuseIdentifier: self.supplementaryViewReuseIdFor(kind: kind),
                                                                           for: indexPath) as? SpinnerCollectionViewFooter
                view?.setSpinnerColor(color: .defaultBackgroundSpinnerColor)
                return view
            }
            return nil
        }
        
        collectionView.delegate = self
        self.dataSource = dataSource
        self.collectionView = collectionView
        
        // SearchBar
        let searchBar = UISearchBar()
        self.view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.alpha = 0.8
        self.searchBar = searchBar
        
        // Spinner
        let spinner = UIActivityIndicatorView(style: .large)
        self.view.addSubview(spinner)
        spinner.color = .defaultBackgroundSpinnerColor
        spinner.hidesWhenStopped = true
        spinner.backgroundColor = .black.withAlphaComponent(0.6)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.frame = self.view.bounds
        self.spinner = spinner
        
        // Constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: searchBarHeight),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            spinner.topAnchor.constraint(equalTo: collectionView.topAnchor),
            spinner.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            spinner.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
    }
    
    private func configureFullListBinding() {
        guard let viewModel = self.viewModel else {
            return
        }
        self.fullViewModelSubscription = viewModel.characterListListViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] newViewModelResult in
                if let self = self {
                    switch self.currentMode {
                    case .fullList:
                        self.hideSpinner()
                        switch newViewModelResult {
                        case .failure(let error):
                            self.assignFullListError(error: error)
                            self.displayCurrentFullListError()
                        case .success(let value):
                            self.assignFullListItems(items: value.entries)
                            self.dataSource?.apply(self.fullModeSnapshot.snapshot, animatingDifferences: true)
                        }
                    default:
                        switch newViewModelResult {
                        case .failure(let error):
                            self.assignFullListError(error: error)
                        case .success(let value):
                            self.assignFullListItems(items: value.entries)
                        }
                    }
                }
            })
    }
    
    private func configureNewSearchListBinding() {
        guard let searchViewModel = self.searchViewModel else {
            return
        }
        self.searchViewModelSubscription = searchViewModel.characterListSearchViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] newViewModelResult in
                if let self = self {
                    switch self.currentMode {
                    case .searching(_):
                        self.hideSpinner()
                        switch newViewModelResult {
                        case .failure(let error):
                            self.assignSearchListError(error: error)
                            self.displayCurrentSearchListError()
                        case .success(let value):
                            let hadPreviousSearchData = self.searchModeSnapshot.snapshot.numberOfItems != 0
                            self.assignSearchListItems(items: value.displayModel.entries)
                            self.dataSource?.apply(self.searchModeSnapshot.snapshot, animatingDifferences: hadPreviousSearchData)
                            if !hadPreviousSearchData {
                                self.view.endEditing(true)
                                self.assignSearchListOffset(offset: .zero)
                                self.collectionView?.setContentOffset(.zero, animated: false)
                            }
                        }
                    default:
                        switch newViewModelResult {
                        case .failure(let error):
                            self.assignSearchListError(error: error)
                        case .success(let value):
                            let resetOffset = self.searchModeSnapshot.snapshot.numberOfItems == 0
                            self.assignSearchListItems(items: value.displayModel.entries)
                            if resetOffset {
                                self.assignSearchListOffset(offset: .zero)
                            }
                        }
                    }
                }
            })
    }
    
    private func displayCurrentFullListError() {
        guard let error = self.fullModeSnapshot.lastError else {
            return
        }
        switch error {
        case .InitialFetchError:
            let popup = UIAlertController(title: "Error", message: "There was an error loading", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Reload", style: .default) { [weak self] act in
                self?.loadPageOfCurrentMode(page: 0)
            }
            popup.addAction(okAction)
            self.present(popup, animated: true, completion: nil)
        case .FetchError(let page):
            let popup = UIAlertController(title: "Error", message: "There was an error loading", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Reload", style: .default) { [weak self] act in
                self?.loadPageOfCurrentMode(page: page)
            }
            popup.addAction(okAction)
            self.present(popup, animated: true, completion: nil)
        case .TotalChanged:
            let popup = UIAlertController(title: "Important", message: "Data has been updated. A refresh from scratch is necessary", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Refresh", style: .default) { [weak self] act in
                self?.viewModel?.reset()
                self?.viewModel?.loadIfNeeded(page: 0)
            }
            popup.addAction(okAction)
            self.present(popup, animated: true, completion: nil)
        case .NoResults:
            let popup = UIAlertController(title: "Important", message: "There are no results. Try again. If the error persists, come back later.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Retry", style: .default) { [weak self] act in
                self?.viewModel?.reset()
                self?.viewModel?.loadIfNeeded(page: 0)
            }
            popup.addAction(okAction)
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    private func displayCurrentSearchListError() {
        guard let error = self.searchModeSnapshot.lastError else {
            return
        }
        switch error {
        case .Error(let error, let searchCriteria):
            switch error {
            case .InitialFetchError:
                let popup = UIAlertController(title: "Error", message: "There was an error loading the results for \(searchCriteria)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Reload", style: .default) { [weak self] act in
                    self?.showSpinner()
                    self?.searchViewModel?.loadIfNeeded(page: 0, searchCriteria: searchCriteria)
                }
                popup.addAction(okAction)
                self.present(popup, animated: true, completion: nil)
            case .FetchError(let page):
                let popup = UIAlertController(title: "Error", message: "There was an error loading", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Reload", style: .default) { [weak self] act in
                    self?.searchViewModel?.loadIfNeeded(page: page, searchCriteria: searchCriteria)
                }
                popup.addAction(okAction)
                self.present(popup, animated: true, completion: nil)
            case .TotalChanged:
                let popup = UIAlertController(title: "Important", message: "Data has been updated. A refresh from scratch is necessary", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Refresh", style: .default) { [weak self] act in
                    self?.searchViewModel?.reset()
                    self?.searchViewModel?.loadIfNeeded(page: 0, searchCriteria: searchCriteria)
                }
                popup.addAction(okAction)
                self.present(popup, animated: true, completion: nil)
            case .NoResults:
                let popup = UIAlertController(title: "No results", message: "No matches for '\(searchCriteria)'.\nTry another name", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default)
                popup.addAction(okAction)
                self.present(popup, animated: true, completion: nil)
            }
        }
    }
    
    private func assignFullListError(error: CharacterListViewerError) {
        self.fullModeSnapshot = .init(snapshot: self.fullModeSnapshot.snapshot,
                                      contentOffset: self.fullModeSnapshot.contentOffset,
                                      lastError: error)
    }
    
    private func assignFullListItems(items: [CharacterListViewerItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        self.fullModeSnapshot = .init(snapshot: snapshot,
                                      contentOffset: self.fullModeSnapshot.contentOffset,
                                      lastError: self.fullModeSnapshot.lastError)
    }
    
    private func clearSearchListSnapshot() {
        let snapshot = Snapshot()
        self.searchModeSnapshot = .init(snapshot: snapshot, contentOffset: .zero, lastError: nil)
    }
    
    private func assignSearchListError(error: CharacterListSearchViewerError) {
        self.searchModeSnapshot = .init(snapshot: self.searchModeSnapshot.snapshot,
                                        contentOffset: self.searchModeSnapshot.contentOffset,
                                        lastError: error)
    }
    
    private func assignSearchListItems(items: [CharacterListViewerItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        self.searchModeSnapshot = .init(snapshot: snapshot,
                                        contentOffset: self.searchModeSnapshot.contentOffset,
                                        lastError: self.searchModeSnapshot.lastError)
    }
    
    private func assignSearchListOffset(offset: CGPoint) {
        self.searchModeSnapshot = .init(snapshot: self.searchModeSnapshot.snapshot,
                                        contentOffset: offset,
                                        lastError: self.searchModeSnapshot.lastError)
    }
    
    private func restoreFullListSnapshot() {
        self.dataSource?.apply(self.fullModeSnapshot.snapshot)
        if fullModeSnapshot.snapshot.numberOfItems == 0 {
            self.showSpinner()
        } else {
            self.hideSpinner()
        }
        self.collectionView?.setContentOffset(self.fullModeSnapshot.contentOffset, animated: false)
    }
    
    private func saveCurrentFullListSnapshotState() {
        if let dataSource = dataSource, let collectionView = self.collectionView {
            self.fullModeSnapshot = SnapshotState(snapshot: dataSource.snapshot(),
                                                  contentOffset: collectionView.contentOffset,
                                                  lastError: nil)
        }
    }
    
    private func prepareForNewSearch() {
        self.showSpinner()
        self.configureNewSearchListBinding()
    }
}

extension CharacterListViewerViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .loaded(let model, _):
            guard let characterId = model.characterId else {
                return
            }
            let characterDetailsScreen = Assembly.shared.provideCharacterDetailsScreen(withCharacterId: characterId)
            self.navigationController?.pushViewController(characterDetailsScreen, animated: true)
        case .error(_, let page):
            self.loadPageOfCurrentMode(page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dataSource = self.dataSource, let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        guard item == dataSource.snapshot().itemIdentifiers.last else {
            return
        }
        switch item {
        case .loaded(_, let page):
            self.loadPageOfCurrentMode(page: page + 1)
        case .error(_, let page):
            self.loadPageOfCurrentMode(page: page + 1)
        }
    }
    
    private func loadPageOfCurrentMode(page: Int) {
        switch currentMode {
        case .fullList:
            self.viewModel?.loadIfNeeded(page: page)
        case .searching(let criteria):
            self.searchViewModel?.loadIfNeeded(page: page, searchCriteria: criteria)
        }
    }
}

extension CharacterListViewerViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            self.changeMode(newMode: .fullList)
            return
        }
        self.searchViewModel?.reset()
        self.changeMode(newMode: .searching(criteria: text))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.showsCancelButton = false
            self.searchViewModel?.reset()
            self.changeMode(newMode: .fullList)
        } else {
            searchBar.showsCancelButton = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        self.searchBar(searchBar, textDidChange: "")
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.collectionView?.alpha = 0.6
        self.collectionView?.isUserInteractionEnabled = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.collectionView?.alpha = 1
        self.collectionView?.isUserInteractionEnabled = true
    }
    
    private func changeMode(newMode: CharacterListViewerMode) {
        let oldValue = self.currentMode
        self.currentMode = newMode
        switch (oldValue, newMode) {
        case (.fullList, .searching(let text)):
            self.saveCurrentFullListSnapshotState()
            self.prepareForNewSearch()
            self.searchViewModel?.loadIfNeeded(page: 0, searchCriteria: text)
        case (.searching(_), .fullList):
            self.searchViewModelSubscription = nil
            self.clearSearchListSnapshot()
            self.restoreFullListSnapshot()
        case (.searching(let oldText), .searching(let text)):
            if oldText != text {
                self.prepareForNewSearch()
                self.searchViewModel?.loadIfNeeded(page: 0, searchCriteria: text)
            }
        case (.fullList, .fullList):
            break
        }
    }
}
