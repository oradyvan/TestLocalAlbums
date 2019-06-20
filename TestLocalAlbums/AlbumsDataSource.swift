//
//  AlbumsDataSource.swift
//  TestLocalAlbums
//
//  Created by Oleksiy Radyvanyuk on 18/06/2019.
//  Copyright © 2019 NGTI. All rights reserved.
//

import UIKit
import Photos

struct AssetCollectionInfo {
    let collectionName: String
    let assetCount: Int
}

class AlbumsDataSource: NSObject, UITableViewDataSource {
    var topLevelCollections = [AssetCollectionInfo]()
    var albums = [AssetCollectionInfo]()
    var moments = [AssetCollectionInfo]()
    var smartAlbums = [AssetCollectionInfo]()

    func refresh(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        topLevelCollections.removeAll()
        refreshTopLevelCollections(group: group, infoBlock: { [weak self] info in
            self?.topLevelCollections.append(info)
        })

        albums.removeAll()
        refreshAssetCollection(of: .album, infoBlock: { [weak self] info in
            self?.albums.append(info)
        }, group: group)

        moments.removeAll()
        refreshAssetCollection(of: .moment, infoBlock: { [weak self] info in
            self?.moments.append(info)
        }, group: group)

        smartAlbums.removeAll()
        refreshAssetCollection(of: .smartAlbum, infoBlock: { [weak self] info in
            self?.smartAlbums.append(info)
        }, group: group)

        group.notify(queue: .main) {
            completion()
        }
    }

    private func refreshTopLevelCollections(group: DispatchGroup,
                                            infoBlock: @escaping (AssetCollectionInfo) -> Void) {
        group.enter()
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAllBurstAssets = true
        fetchOptions.wantsIncrementalChangeDetails = false

        let collections = PHCollection.fetchTopLevelUserCollections(with: fetchOptions)
        let count = collections.count
        collections.enumerateObjects { collection, index, _ in
            let info = AssetCollectionInfo(collectionName: collection.localizedTitle ?? "N/A",
                                           assetCount: NSNotFound)
            infoBlock(info)
            if index == count - 1 {
                group.leave()
            }
        }
    }

    private func refreshAssetCollection(of type: PHAssetCollectionType,
                                        infoBlock: @escaping (AssetCollectionInfo) -> Void,
                                        group: DispatchGroup)  {
        group.enter()
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAllBurstAssets = true
        fetchOptions.wantsIncrementalChangeDetails = false

        let collections = PHAssetCollection.fetchAssetCollections(with: type, subtype: .any, options: fetchOptions)
        let count = collections.count
        collections.enumerateObjects { assetCollection, index, _ in
            let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            let info = AssetCollectionInfo(collectionName: assetCollection.localizedTitle ?? "N/A",
                                           assetCount: assets.count)
            infoBlock(info)
            if index == count - 1 {
                group.leave()
            }
        }
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)

        // Configure the cell...
        switch indexPath.section {
        case 0:
            configureAssetCollectionCell(cell, from: topLevelCollections, at: indexPath)
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

    private func configureAssetCollectionCell(_ cell: UITableViewCell,
                                              from collectionInfo: [AssetCollectionInfo],
                                              at indexPath: IndexPath) {
        let info = collectionInfo[indexPath.row]
        cell.textLabel?.text = info.collectionName
        if info.assetCount != NSNotFound {
            cell.detailTextLabel?.text = "\(info.assetCount) items"
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
