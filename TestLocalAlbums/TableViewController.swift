//
//  TableViewController.swift
//  TestLocalAlbums
//
//  Created by Oleksiy Radyvanyuk on 18/06/2019.
//  Copyright © 2019 NGTI. All rights reserved.
//

import UIKit
import Photos

class TableViewController: UITableViewController {
    let albumsDataSource = AlbumsDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = albumsDataSource
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }

    private func refresh() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            reloadData()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.refresh()
                }
            }
        default:
            sayNothingToShow()
        }
    }

    private func reloadData() {
        albumsDataSource.refresh { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func sayNothingToShow() {
        let alert = UIAlertController(title: "Uh-oh...",
                                      message: "Wrong choice, please tap \"Allow\" next time!",
                                      preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}
