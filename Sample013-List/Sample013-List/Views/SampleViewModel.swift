//
//  SampleViewModel.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/07.
//

import Foundation

final class SampleViewModel: ObservableObject {
    enum State: Equatable {
        case initial
        case loading
        case loaded(employees: [Employee])
        case unchanged
        case firstLoadFailed
        case moreLoadFailed
    }

    @Published private(set) var state: State = .initial

    private static let itemsPerPage = 50
    private static let intiniteLoadEnabled = true
    private static let totalItemsCount = 1000

    private var employees: [Employee] = []
    private var infiniteSequence = (1...).lazy
    private var offset = 1

    private var hasMore: Bool {
        Self.intiniteLoadEnabled ? true : offset < Self.totalItemsCount
    }

    @MainActor
    func loadMore(forceFirstLoadError: Bool = false, forceMoreLoadError: Bool = false) async {
        state = .loading

        if forceFirstLoadError, offset == 1 {
            state = .firstLoadFailed
            return
        }

        if forceMoreLoadError {
            state = .moreLoadFailed
            return
        }

        if !hasMore {
            state = .unchanged
            return
        }

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let employees = await Self.request(offset: offset)

        self.employees.append(contentsOf: employees)
        offset += Self.itemsPerPage

        state = .loaded(employees: self.employees)
    }

    func refresh(forceFirstLoadError: Bool = false) async {
        offset = 1
        employees.removeAll(keepingCapacity: true)

        await loadMore(forceFirstLoadError: forceFirstLoadError)
    }

    private static func request(offset: Int) async -> [Employee] {
        let range = (1...).lazy
            .filter { $0 >= offset } // from
            .filter { Self.intiniteLoadEnabled ? true : $0 <= Self.totalItemsCount } // to
            .prefix(Self.itemsPerPage)

        let employees = Array(range)
            .map { Employee(id: $0, name: "emp \($0)") }

        return employees
    }
}
