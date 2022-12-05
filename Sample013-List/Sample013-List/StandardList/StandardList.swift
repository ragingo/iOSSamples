//
//  StandardList.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/05.
//

import SwiftUI

struct StandardList: View {
    private var employees: Binding<[Employee]>
    private let onLoadMore: () -> Void
    private let onRefresh: () -> Void

    init(
        employees: Binding<[Employee]>,
        onLoadMore: @escaping () -> Void,
        onRefresh: @escaping () -> Void
    ) {
        self.employees = employees
        self.onLoadMore = onLoadMore
        self.onRefresh = onRefresh
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            list
        } else {
            listRegacy
        }
    }

    @available(iOS 15.0, *)
    var list: some View {
        List(employees.wrappedValue, id: \.id) { employee in
            StandardListRow(employee: employee, action: { _ in })
                .onAppear {
                    if employees.wrappedValue.last == employee {
                        onLoadMore()
                    }
                }
        }
        .refreshable {
            onRefresh()
        }
        .onAppear {
            onLoadMore()
        }
    }

    var listRegacy: some View {
        List(employees.wrappedValue, id: \.id) { employee in
            StandardListRow(employee: employee, action: { _ in })
                .onAppear {
                    if employees.wrappedValue.last == employee {
                        onLoadMore()
                    }
                }
        }
        .onAppear {
            onLoadMore()
        }
    }
}
