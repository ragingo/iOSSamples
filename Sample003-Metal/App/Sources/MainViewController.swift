//
//  MainViewController.swift
//  App
//
//  Created by ragingo on 2021/06/21.
//

import UIKit
import MetalKit

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(RgMetalView(frame: view.frame))
    }
}
