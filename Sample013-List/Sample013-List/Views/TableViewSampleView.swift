//
//  TableViewSampleView.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/07.
//

import SwiftUI

struct TableViewSampleView: View {
    @State private var employees: [Employee] = []
    @State private var isLoading = false
    @State private var isFirstLoadFailed = false
    @State private var isMoreLoadFailed = false
    @StateObject private var viewModel: SampleViewModel

    // MARK: - デバッグ用
    @State private var forceFirstLoadError = false
    @State private var forceMoreLoadError = false

    init() {
        self._viewModel = .init(wrappedValue: SampleViewModel())
    }

    var body: some View {
        VStack {
            debugView

            ZStack {
                firstLoadErrorState
                    .opacity(isFirstLoadFailed ? 1.0 : 0.0)
                    .zIndex(isFirstLoadFailed ? 1 : 0)

                TableView(
                    data: $employees,
                    cellContent: { index, employee in
                        TableViewButtonCell(label: { Text("\(employee.name)") }) {}
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 50)
                    },
                    onLoadMore: {
                        Task {
                            await viewModel.loadMore(
                                forceFirstLoadError: forceFirstLoadError,
                                forceMoreLoadError: forceMoreLoadError
                            )
                        }
                    },
                    onRefresh: {
                        Task {
                            await viewModel.refresh(forceFirstLoadError: forceFirstLoadError)
                        }
                    }
                )
                .overlay(
                    moreLoadingState
                        .opacity(isLoading ? 1.0 : 0.0),
                    alignment: .bottom
                )
                .overlay(
                    moreLoadErrorState
                        .opacity(isMoreLoadFailed ? 1.0 : 0.0)
                        .zIndex(isMoreLoadFailed ? 1 : 0)
                        .padding(),
                    alignment: .bottom
                )
                .onAppear {
                    Task {
                        await viewModel.loadMore()
                    }
                }
                .onChange(of: viewModel.state) { state in
                    switch state {
                    case .initial:
                        isLoading = false
                        isFirstLoadFailed = false
                        isMoreLoadFailed = false
                    case .loading:
                        isLoading = true
                        isFirstLoadFailed = false
                        isMoreLoadFailed = false
                    case .loaded(let employees):
                        isLoading = false
                        isFirstLoadFailed = false
                        isMoreLoadFailed = false
                        self.employees = employees
                    case .unchanged:
                        isLoading = false
                        isFirstLoadFailed = false
                        isMoreLoadFailed = false
                    case .firstLoadFailed:
                        isLoading = false
                        isFirstLoadFailed = true
                        isMoreLoadFailed = false
                        self.employees = []
                    case .moreLoadFailed:
                        isLoading = false
                        isFirstLoadFailed = false
                        isMoreLoadFailed = true
                    }
                }
            }
        }
    }

    private var moreLoadingState: some View {
        ProgressView()
            .progressViewStyle(.circular)
    }

    private var firstLoadErrorState: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
            Text("エラー発生")
                .font(.title)
        }
    }

    private var moreLoadErrorState: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            Text("エラー発生")
                .font(.title)
        }
    }

    private var debugView: some View {
        HStack(spacing: 32) {
            Toggle("初回データ取得時にエラー", isOn: $forceFirstLoadError)
                .fixedSize()
            Toggle("追加データ取得時にエラー", isOn: $forceMoreLoadError)
                .fixedSize()
        }
    }
}

struct TableViewSampleView_Previews: PreviewProvider {
    static var previews: some View {
        TableViewSampleView()
    }
}
