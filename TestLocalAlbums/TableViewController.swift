//
//  TableViewController.swift
//  TestLocalAlbums
//
//  Created by Oleksiy Radyvanyuk on 18/06/2019.
//  Copyright © 2019 NGTI. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    let albumsDataSource = AlbumsDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = albumsDataSource
        albumsDataSource.refresh { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
