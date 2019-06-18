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
        albumsDataSource.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
