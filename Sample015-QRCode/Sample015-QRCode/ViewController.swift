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
        qrCodeReaderView = QRCodeReaderView(frame: .init(origin: .zero, size: .init(width: 300, height: 300)))
        view.addSubview(qrCodeReaderView)

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
