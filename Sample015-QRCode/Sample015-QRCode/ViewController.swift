//
//  ViewController.swift
//  Sample015-QRCode
//
//  Created by ragingo on 2023/01/25.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private var qrCodeReaderView: QRCodeReaderView!
    private var cancellables: [AnyCancellable] = []

    override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false

        qrCodeReaderView = QRCodeReaderView()
        qrCodeReaderView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeReaderView.layer.borderWidth = 1
        qrCodeReaderView.layer.borderColor = UIColor.white.cgColor
        view.addSubview(qrCodeReaderView)

        NSLayoutConstraint.activate([
            qrCodeReaderView.widthAnchor.constraint(equalToConstant: 300),
            qrCodeReaderView.heightAnchor.constraint(equalToConstant: 300),
            view.centerXAnchor.constraint(equalTo: qrCodeReaderView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: qrCodeReaderView.centerYAnchor)
        ])

        qrCodeReaderView.result
            .sink(receiveValue: { value in
                print(value)
            })
            .store(in: &cancellables)

        if qrCodeReaderView.configure() {
            qrCodeReaderView.start()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        qrCodeReaderView.stop()
    }
}
