/*
 * Copyright (c) 2023 Félix Poulin-Bélanger. All rights reserved.
 */

import SwiftUI

struct ContentView: View {
    @State var kfd: UInt64 = 0
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Button("kopen") {
                            kfd = kopen(0x800, 0x0, 0x2, 0x2)
                        }
                        .disabled(kfd != 0).frame(minWidth: 0, maxWidth: .infinity)
                        Button("kclose") {
                            kclose(kfd)
                            kfd = 0
                        }
                        .disabled(kfd == 0).frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
                .listRowBackground(Color.clear)
                if kfd != 0 {
                    Section {
                        VStack {
                            Text("Success!").foregroundColor(.green)
                            Text("Look at output in Xcode")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationBarTitle(Text("kfd"), displayMode: .inline)
        }
    }
}
