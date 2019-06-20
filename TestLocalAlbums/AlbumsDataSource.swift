//
//  AlbumsDataSource.swift
//  TestLocalAlbums
//
//  Created by Oleksiy Radyvanyuk on 18/06/2019.
//  Copyright © 2019 NGTI. All rights reserved.
//

import UIKit
import Photos

struct AssetCollectionInfoSection {
    let title: String
    let infoList: [AssetCollectionInfo]
}

struct AssetCollectionInfo {
    let collectionName: String
    let assetCount: Int
}

class AlbumsDataSource: NSObject, UITableViewDataSource {
    var sections = [AssetCollectionInfoSection]()

    func refresh(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        sections.removeAll()
        var topLevelCollections = [AssetCollectionInfo]()
        refreshTopLevelCollections(group: group, infoBlock: { info in
            topLevelCollections.append(info)
        })
        sections.append(AssetCollectionInfoSection(title: "Top Level Collections",
                                                   infoList: topLevelCollections))

        var albums = [AssetCollectionInfo]()
        refreshAssetCollection(of: .album, infoBlock: { info in
            albums.append(info)
        }, group: group)
        sections.append(AssetCollectionInfoSection(title: "Albums",
                                                   infoList: albums))

        var smartAlbums = [AssetCollectionInfo]()
        refreshAssetCollection(of: .smartAlbum, infoBlock: { info in
            smartAlbums.append(info)
        }, group: group)
        sections.append(AssetCollectionInfoSection(title: "Smart Albums",
                                                   infoList: smartAlbums))

        var moments = [AssetCollectionInfo]()
        refreshAssetCollection(of: .moment, infoBlock: { info in
            moments.append(info)
        }, group: group)
        sections.append(AssetCollectionInfoSection(title: "Moments (iOS 13 deprecated)",
                                                   infoList: moments))

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
        let section = sections[indexPath.section]
        configureAssetCollectionCell(cell, from: section.infoList, at: indexPath)
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
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = sections[section]
        return data.infoList.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let data = sections[section]
        return data.title
    }
}
