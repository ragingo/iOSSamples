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
        qrCodeReaderView.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(qrCodeReaderView)

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.text = "読み取ったデータはここに表示されます"
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            // qrCodeReaderView
            qrCodeReaderView.widthAnchor.constraint(equalToConstant: 300),
            qrCodeReaderView.heightAnchor.constraint(equalToConstant: 300),
            view.centerXAnchor.constraint(equalTo: qrCodeReaderView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: qrCodeReaderView.centerYAnchor),
            // textView
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: qrCodeReaderView.bottomAnchor, constant: 16),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        ])

        qrCodeReaderView.result
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak textView] value in
                textView?.text = value
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
