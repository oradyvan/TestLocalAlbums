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

    func refresh() {
        refreshTopLevelCollections()
        refreshAlbums()
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

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)

        // Configure the cell...
        switch indexPath.section {
        case 0:
            configureCollectionCell(cell, at: indexPath)
        case 1:
            configureAlbumCell(cell, at: indexPath)
        default:
            ()
        }

        return cell
    }

    private func configureCollectionCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let collection = topLevelCollections[indexPath.row]
        cell.textLabel?.text = collection.localizedTitle ?? "N/A"
    }

    private func configureAlbumCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let album = albums[indexPath.row]
        cell.textLabel?.text = album.localizedTitle ?? "N/A"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return topLevelCollections.count
        case 1:
            return albums.count
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
        default:
            return nil
        }
    }
}
