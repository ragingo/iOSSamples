//
//  TableView.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/06.
//

import SwiftUI
import Differentiator

struct TableViewSectionType<T: Identifiable & Hashable>: IdentifiableType, Equatable {
    typealias Identity = T
    let value: T
    var id: T.ID { value.id }
    var identity: T { value }
}

struct TableViewSectionItemType<T: Identifiable & Hashable>: IdentifiableType, Equatable {
    typealias Identity = T
    let value: T
    var id: T.ID { value.id }
    var identity: T { value }
}

struct TableView<
    SectionType: Identifiable & Hashable,
    ItemType: Identifiable & Hashable,
    Cell: View
>: View
{
    typealias TableSectionModelType = AnimatableSectionModel<TableViewSectionType<SectionType>, TableViewSectionItemType<ItemType>>
    typealias TableDataType = [TableSectionModelType]
    typealias DiffDataType = [Changeset<TableSectionModelType>]

    @Binding private var data: TableDataType
    private let cellContent: (ItemType) -> Cell
    @State private var needsRefresh = false
    @State private var diffData: DiffDataType = []
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
            diffData: $diffData,
            cellContent: cellContent,
            needsRefresh: $needsRefresh,
            onLoadMore: {
                onLoadMore?()
            },
            onRefresh: {
                onRefresh?()
            }
        )
        .onChange(of: data) { [oldData = data] newData in
            // 参考の実装
            // https://github.com/RxSwiftCommunity/RxDataSources/blob/5.0.2/Sources/RxDataSources/RxTableViewSectionedAnimatedDataSource.swift#L97
            let diffData = try? Diff.differencesForSectionedView(
                initialSections: oldData,
                finalSections: newData
            )
            self.diffData = diffData ?? []
            needsRefresh = true
        }
    }
}

// UIViewControllerRepresentable の実装は struct でないといけない
// iOS 14 では動作するが、 iOS 16 ではクラッシュする。
private final class InnerTableView<
    SectionType: Identifiable & Hashable,
    ItemType: Identifiable & Hashable,
    Cell: View
>: UIViewControllerRepresentable
{
    typealias TableSectionModelType = AnimatableSectionModel<TableViewSectionType<SectionType>, TableViewSectionItemType<ItemType>>
    typealias TableDataType = [TableSectionModelType]
    typealias DiffDataType = [Changeset<TableSectionModelType>]
    typealias UIViewControllerType = UIViewController

    private var data: TableDataType = []

    @Binding private var diffData: DiffDataType
    private let cellID = UUID().uuidString
    private let cellContent: (ItemType) -> Cell
    private var innerViewController: UIViewControllerType?
    @Binding private var needsRefresh: Bool
    private let onLoadMore: () -> Void
    private let onRefresh: () -> Void

    private var uiTableView: UITableView? {
        innerViewController?.view as? UITableView
    }

    init(
        diffData: Binding<DiffDataType>,
        @ViewBuilder cellContent: @escaping (ItemType) -> Cell,
        needsRefresh: Binding<Bool>,
        onLoadMore: @escaping () -> Void,
        onRefresh: @escaping () -> Void
    ) {
        self._diffData = diffData
        self.cellContent = cellContent
        self._needsRefresh = needsRefresh
        self.onLoadMore = onLoadMore
        self.onRefresh = onRefresh
    }

    func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = UIViewControllerType()

        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.register(HostingCell<Cell>.self, forCellReuseIdentifier: cellID)
        viewController.view = tableView

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshControlValueChanged(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl

        innerViewController = viewController

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if needsRefresh, let uiTableView = uiViewController.view as? UITableView {
            diffData.forEach { changeset in
                uiTableView.performBatchUpdates {
                    context.coordinator.parent.data = changeset.finalSections

                    // RxDataSource モジュールを使ってないから tableView.batchUpdates() が使えない。
                    // 以下のリンク先の本家実装を参考に、最低限のコードで更新処理を実行
                    // https://github.com/RxSwiftCommunity/RxDataSources/blob/5.0.2/Sources/RxDataSources/UI+SectionedViewType.swift
                    uiTableView.deleteSections(.init(changeset.deletedSections), with: .automatic)
                    uiTableView.insertSections(.init(changeset.insertedSections), with: .automatic)
                    changeset.movedSections.forEach {
                        uiTableView.moveSection($0.from, toSection: $0.to)
                    }
                    uiTableView.deleteRows(at: .init(changeset.deletedItems.map { IndexPath(row: $0.itemIndex, section: $0.sectionIndex) }), with: .automatic)
                    uiTableView.insertRows(at: .init(changeset.insertedItems.map { IndexPath(row: $0.itemIndex, section: $0.sectionIndex) }), with: .automatic)
                    uiTableView.reloadRows(at: .init(changeset.updatedItems.map { IndexPath(row: $0.itemIndex, section: $0.sectionIndex) }), with: .automatic)
                    changeset.movedItems.forEach {
                        uiTableView.moveRow(at: IndexPath(row: $0.from.itemIndex, section: $0.from.sectionIndex), to: IndexPath(row: $0.to.itemIndex, section: $0.to.sectionIndex))
                    }
                }
            }

            Task {
                needsRefresh = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        let parent: InnerTableView

        init(parent: InnerTableView) {
            self.parent = parent
        }

        // MARK: - UITableViewDataSource
        func numberOfSections(in tableView: UITableView) -> Int {
            return parent.data.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parent.data[section].items.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            defer {
                let isLastSection = parent.data.last == parent.data[indexPath.section]
                let isLastItem = parent.data[indexPath.section].items.last == parent.data[indexPath.section].items[indexPath.row]
                if isLastSection && isLastItem {
                    parent.onLoadMore()
                }
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: parent.cellID) as? HostingCell<Cell> else {
                return UITableViewCell()
            }
            let element = parent.data[indexPath.section].items[indexPath.row]
            let content = parent.cellContent(element.value)
            cell.set(rootView: content, parentController: parent.innerViewController)
            return cell
        }

        // MARK: - UITableViewDelegate
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
