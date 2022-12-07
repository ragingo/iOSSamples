//
//  ContentView.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/05.
//

import SwiftUI

struct ContentView: View {
    @State private var employees: [Employee] = []
    @State private var sequence = (1...).lazy
    @State private var offset = 1
    private let itemsPerPage = 50

    var body: some View {
        TableView(
            data: $employees,
            cellContent: { index, employee in
                TableViewButtonCell(label: { Text("\(employee.name)") }) {}
                    .frame(maxWidth: .infinity, alignment: .leading)
            },
            onLoadMore: {
                Task {
                    await loadMore()
                }
            },
            onRefresh: {
                Task {
                    await loadMore(isRefresh: true)
                }
            }
        )
        .onAppear {
            Task {
                await loadMore()
            }
        }

//        StandardList(
//            employees: $employees,
//            onLoadMore: {
//                Task {
//                    await loadMore()
//                }
//            },
//            onRefresh: {
//                Task {
//                    await loadMore(isRefresh: true)
//                }
//            }
//        )
    }

    private func loadMore(isRefresh: Bool = false) async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        if isRefresh {
            offset = 1
            employees.removeAll(keepingCapacity: true)
        }

        let range = sequence.filter { $0 >= offset }.prefix(itemsPerPage)
        let emps = Array(range).map { Employee(id: $0, name: "emp \($0)") }
        employees.append(contentsOf: emps)
        offset += itemsPerPage
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}