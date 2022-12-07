//
//  ContentView.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: {
                        TableViewSampleView()
                    },
                    label: {
                        Image(systemName: "tablecells")
                            .resizable()
                            .frame(width: 50)
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("TableViewSampleView")
                                .font(.title2)
                            Text("SwiftUI 用に UITableView をラップした \"TableView\" を試す為の画面")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                )
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
