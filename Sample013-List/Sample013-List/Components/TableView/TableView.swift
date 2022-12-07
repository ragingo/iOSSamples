//
//  TableView.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/06.
//

import SwiftUI
import Differentiator

struct TableViewSectionModel: IdentifiableType, Equatable {
    typealias Identity = UUID

    let identity = UUID()
}

struct TableView<
    ItemType: Hashable & IdentifiableType,
    Cell: View
>: View
{
    typealias TableDataType = [AnimatableSectionModel<TableViewSectionModel, ItemType>]

    @Binding private var data: TableDataType
    private let cellContent: (ItemType) -> Cell
    @State private var needsRefresh = false
    private let onLoadMore: (() -> Void)?
    private let onRefresh: (() -> Void)?

    init(
        data: Binding<TableDataType>,
        @ViewBuilder cellContent: @escaping (ItemType) -> Cell,
        onLoadMore: (() -> Void)? = nil,
        onRefresh: (() -> Void)? = nil
    ) {
        self._data = data
        self.cellContent = cellContent
        self.onLoadMore = onLoadMore
        self.onRefresh = onRefresh
    }

    var body: some View {
        InnerTableView(
            data: $data,
            cellContent: cellContent,
            needsRefresh: $needsRefresh,
            onLoadMore: {
                onLoadMore?()
            },
            onRefresh: {
                onRefresh?()
            }
        )
        .onChange(of: data) { newData in
            // 参考の実装
            // https://github.com/RxSwiftCommunity/RxDataSources/blob/e4627ac4f5/Sources/RxDataSources/RxTableViewSectionedAnimatedDataSource.swift#L97
            let diff = try? Diff.differencesForSectionedView(
                initialSections: data,
                finalSections: newData
            )
            needsRefresh = true
        }
    }
}

private final class InnerTableView<
    ItemType: Hashable & IdentifiableType,
    Cell: View
>: UIViewControllerRepresentable
{
    typealias TableDataType = [AnimatableSectionModel<TableViewSectionModel, ItemType>]
    typealias UIViewControllerType = UIViewController

    @Binding private var data: TableDataType
    private let cellID = UUID().uuidString
    private let cellContent: (ItemType) -> Cell
    private var innerViewController: UIViewControllerType?
    @Binding private var needsRefresh: Bool
    private let onLoadMore: () -> Void
    private let onRefresh: () -> Void

    init(
        data: Binding<TableDataType>,
        @ViewBuilder cellContent: @escaping (ItemType) -> Cell,
        needsRefresh: Binding<Bool>,
        onLoadMore: @escaping () -> Void,
        onRefresh: @escaping () -> Void
    ) {
        self._data = data
        self.cellContent = cellContent
        self._needsRefresh = needsRefresh
        self.onLoadMore = onLoadMore
        self.onRefresh = onRefresh
    }

    func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = UIViewControllerType()
        innerViewController = viewController

        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.register(HostingCell<Cell>.self, forCellReuseIdentifier: cellID)
        viewController.view = tableView

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshControlValueChanged(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if context.coordinator.innerViewController != uiViewController {
            context.coordinator.innerViewController = uiViewController
        }
        if needsRefresh {
            if let innerViewController = context.coordinator.innerViewController {
                Task {
                    let tableView = (innerViewController.view as! UITableView)
                    tableView.reloadData()
                    needsRefresh = false
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITableViewDataSource {
        private let parent: InnerTableView
        var innerViewController: UIViewControllerType?

        init(parent: InnerTableView) {
            self.parent = parent
        }

        // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parent.data.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            defer {
                if parent.data.last == parent.data[indexPath.row] {
                    parent.onLoadMore()
                }
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: parent.cellID) as? HostingCell<Cell> else {
                return UITableViewCell()
            }
            let element = parent.data[0].items[indexPath.row]
            let content = parent.cellContent(element)
            cell.set(rootView: content, parentController: innerViewController)
            return cell
        }
    }

    @objc private func onRefreshControlValueChanged(sender: UIRefreshControl) {
        onRefresh()
        sender.endRefreshing()
    }
}

// 以下のページの大部分を参考にさせていただいた！
// https://github.com/noahsark769/NGSwiftUITableCellSizing/blob/main/NGSwiftUITableCellSizing/HostingCell.swift
private final class HostingCell<Content: View>: UITableViewCell {
    private let hostingController = UIHostingController<Content?>(rootView: nil)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        hostingController.view.backgroundColor = .clear
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(rootView: Content, parentController: UIViewController?) {
        self.hostingController.rootView = rootView
        self.hostingController.view.invalidateIntrinsicContentSize()

        let requiresControllerMove = hostingController.parent != parentController
        if requiresControllerMove {
            parentController?.addChild(hostingController)
        }

        if !self.contentView.subviews.contains(hostingController.view) {
            self.contentView.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            hostingController.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            hostingController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            hostingController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        }

        if requiresControllerMove {
            hostingController.didMove(toParent: parentController)
        }
    }
}
//
//struct TableView_Previews: PreviewProvider {
//    struct DebugCell: View {
//        let element: Int
//        var body: some View {
//            Text("\(element)")
//        }
//    }
//
//    struct DebugView: View {
//        @State private var data: [Int] = []
//
//        var body: some View {
//            TableView(
//                data: $data,
//                cellContent: { index, element in
//                    TableViewTextCell(text: "\(element)")
//                }
//            )
//            .onAppear {
//                Task {
//                    data.append(contentsOf: [1, 2, 3])
//                }
//            }
//        }
//    }
//
//    static var previews: some View {
//        DebugView()
//    }
//}
