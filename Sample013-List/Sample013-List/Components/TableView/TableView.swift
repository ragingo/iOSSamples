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
        .onChange(of: data) { newData in
            // let diff: [Changeset<AnimatableSectionModel<TableViewSectionType<SectionType>, TableViewSectionItemType<ItemType>>>]?
            // 参考の実装
            // https://github.com/RxSwiftCommunity/RxDataSources/blob/e4627ac4f5/Sources/RxDataSources/RxTableViewSectionedAnimatedDataSource.swift#L97
            let diffData = try? Diff.differencesForSectionedView(
                initialSections: data,
                finalSections: newData
            )
            self.diffData = diffData ?? []
            needsRefresh = true
        }
    }
}

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
        if needsRefresh, let uiTableView {
            Task {
                diffData.forEach { changeset in
                    uiTableView.performBatchUpdates {
                        data = changeset.finalSections
                        // RxDataSource モジュールを使ってないから tableView.batchUpdates() が使えない。
                        // 以下のリンク先の本家実装を参考に、最低限のコードで更新処理を実行
                        // https://github.com/RxSwiftCommunity/RxDataSources/blob/5.0.2/Sources/RxDataSources/UI+SectionedViewType.swift
                        uiTableView.deleteSections(.init(changeset.deletedSections), with: .automatic)
                        uiTableView.insertSections(.init(changeset.insertedSections), with: .automatic)
                        changeset.movedSections.forEach {
                            uiTableView.moveSection($0.from, toSection: $0.to)
                        }
                        uiTableView.deleteRows(at: .init(changeset.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) }), with: .automatic)
                        uiTableView.insertRows(at: .init(changeset.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) }), with: .automatic)
                        uiTableView.reloadRows(at: .init(changeset.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) }), with: .automatic)
                        changeset.movedItems.forEach {
                            uiTableView.moveRow(at: IndexPath(item: $0.from.itemIndex, section: $0.from.sectionIndex), to: IndexPath(item: $0.to.itemIndex, section: $0.to.sectionIndex))
                        }
                    }
                }
                needsRefresh = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITableViewDataSource {
        private let parent: InnerTableView

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
            let element = parent.data[indexPath.section].items[indexPath.row]
            let content = parent.cellContent(element.value)
            cell.set(rootView: content, parentController: parent.innerViewController)
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
