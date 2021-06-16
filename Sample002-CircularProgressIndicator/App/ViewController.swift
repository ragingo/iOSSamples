//
//  ViewController.swift
//  App
//
//  Created by ragingo on 2021/06/16.
//

import UIKit

class ViewController: UIViewController {

    private var circularProgressIndicator: CircularProgressIndicator?

    override func viewDidLoad() {
        super.viewDidLoad()

        let indicator = CircularProgressIndicator()
        indicator.bounds = .init(x: 0, y: 0, width: 50, height: 50)
        indicator.center = view.center
        indicator.baseColor = .yellow
        indicator.barColor = .orange
        circularProgressIndicator = indicator
        view.addSubview(indicator)

        // indicator.updateProgressWithAnimation(duration: 3)
        indicator.updateProgress(value: 0.5)
    }

}
