//
//  AlbumsDataSource.swift
//  TestLocalAlbums
//
//  Created by Oleksiy Radyvanyuk on 18/06/2019.
//  Copyright © 2019 NGTI. All rights reserved.
//

import UIKit
import Photos

class AlbumsDataSource: NSObject, UITableViewDataSource {
    var topLevelCollections = [PHCollection]()
    var albums = [PHAssetCollection]()
    var moments = [PHAssetCollection]()
    var smartAlbums = [PHAssetCollection]()

    func refresh() {
        refreshTopLevelCollections()
        refreshAlbums()
        refreshMoments()
        refreshSmartAlbums()
    }

    private func refreshTopLevelCollections() {
        topLevelCollections.removeAll()

        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAllBurstAssets = true
        fetchOptions.wantsIncrementalChangeDetails = false

        let collections = PHCollection.fetchTopLevelUserCollections(with: fetchOptions)
        collections.enumerateObjects { [weak self] collection, index, _ in
            self?.topLevelCollections.append(collection)
        }
    }

    private func refreshAlbums() {
        albums.removeAll()

        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAllBurstAssets = true
        fetchOptions.wantsIncrementalChangeDetails = false

        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        result.enumerateObjects { [weak self] assetCollection, index, _ in
            self?.albums.append(assetCollection)
        }
    }

    private func refreshMoments() {
        moments.removeAll()

        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAllBurstAssets = true
        fetchOptions.wantsIncrementalChangeDetails = false

        let result = PHAssetCollection.fetchAssetCollections(with: .moment, subtype: .any, options: fetchOptions)
        result.enumerateObjects { [weak self] assetCollection, index, _ in
            self?.moments.append(assetCollection)
        }
    }

    private func refreshSmartAlbums() {
        smartAlbums.removeAll()

        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAllBurstAssets = true
        fetchOptions.wantsIncrementalChangeDetails = false

        let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        result.enumerateObjects { [weak self] assetCollection, index, _ in
            self?.smartAlbums.append(assetCollection)
        }
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)

        // Configure the cell...
        switch indexPath.section {
        case 0:
            configureCollectionCell(cell, at: indexPath)
        case 1:
            configureAssetCollectionCell(cell, from: albums, at: indexPath)
        case 2:
            configureAssetCollectionCell(cell, from: moments, at: indexPath)
        case 3:
            configureAssetCollectionCell(cell, from: smartAlbums, at: indexPath)
        default:
            ()
        }

        return cell
    }

    private func configureCollectionCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let collection = topLevelCollections[indexPath.row]
        cell.textLabel?.text = collection.localizedTitle ?? "N/A"
    }

    private func configureAssetCollectionCell(_ cell: UITableViewCell, from collection: [PHAssetCollection], at indexPath: IndexPath) {
        let assetCollection = collection[indexPath.row]
        cell.textLabel?.text = assetCollection.localizedTitle ?? "N/A"
        if assetCollection.estimatedAssetCount != NSNotFound {
            cell.detailTextLabel?.text = "\(assetCollection.estimatedAssetCount) items"
        } else {
            cell.detailTextLabel?.text = nil
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return topLevelCollections.count
        case 1:
            return albums.count
        case 2:
            return moments.count
        case 3:
            return smartAlbums.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Top Level Collections"
        case 1:
            return "Albums"
        case 2:
            return "Moments"
        case 3:
            return "Smart Albums"
        default:
            return nil
        }
    }
}
