//
//  ViewController.swift
//  TestLocalAlbums
//
//  Created by Oleksiy Radyvanyuk on 18/06/2019.
//  Copyright © 2019 NGTI. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                debugPrint("status = \(status)")
            }
        }
    }
}

