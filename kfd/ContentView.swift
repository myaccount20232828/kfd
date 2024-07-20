/*
 * Copyright (c) 2023 Félix Poulin-Bélanger. All rights reserved.
 */

import SwiftUI

struct ContentView: View {
    @State private var kfd: UInt64 = 0

    private var puaf_pages_options = [16, 32, 64, 128, 256, 512, 1024, 2048]
    @State private var puaf_pages_index = 7
    @State private var puaf_pages = 0

    private var puaf_method_options = ["physpuppet", "smith", "landa"]
    @State private var puaf_method = 2

    private var kread_method_options = ["kqueue_workloop_ctl", "sem_open", "IOSurface"]
    @State private var kread_method = 1

    private var kwrite_method_options = ["dup", "sem_open", "IOSurface"]
    @State private var kwrite_method = 1

    var body: some View {
        VStack {
        Form {
            NavigationView {
                Section {
                    Picker(selection: $puaf_pages_index, label: Text("puaf pages:")) {
                        ForEach(0 ..< puaf_pages_options.count, id: \.self) {
                            Text(String(self.puaf_pages_options[$0]))
                        }
                    }.disabled(kfd != 0)
                }
                Section {
                    Picker(selection: $puaf_method, label: Text("puaf method:")) {
                        ForEach(0 ..< puaf_method_options.count, id: \.self) {
                            Text(self.puaf_method_options[$0])
                        }
                    }.disabled(kfd != 0)
                }
                Section {
                    Picker(selection: $kread_method, label: Text("kread method:")) {
                        ForEach(0 ..< kread_method_options.count, id: \.self) {
                            Text(self.kread_method_options[$0])
                        }
                    }.disabled(kfd != 0)
                }
                Section {
                    Picker(selection: $kwrite_method, label: Text("kwrite method:")) {
                        ForEach(0 ..< kwrite_method_options.count, id: \.self) {
                            Text(self.kwrite_method_options[$0])
                        }
                    }.disabled(kfd != 0)
                }
            }
        }
            LogView()
            Button("kopen") {
                DispatchQueue.global(qos: .utility).async {
                    puaf_pages = puaf_pages_options[puaf_pages_index]
                    kfd = kopen_intermediate(UInt64(puaf_pages), UInt64(puaf_method), UInt64(kread_method), UInt64(kwrite_method))
                }
            }
        }
    }
}

struct LogView: View {
    @State var LogItems: [LogItem] = []
    let pipe = Pipe()
    let sema = DispatchSemaphore(value: 0)
    var body: some View {
        ScrollView {
            ScrollViewReader { scroll in
                VStack(alignment: .leading) {
                    ForEach(LogItems) { Item in
                        Text(Item.Message.lineFix())
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundColor(.white)
                        .id(Item.id)
                    }
                }
                .onChange(of: LogItems) { _ in
                    DispatchQueue.main.async {
                        scroll.scrollTo(LogItems.last?.id, anchor: .bottom)
                    }
                }
                .contextMenu {
                    Button {
                        var LogString = ""
                        for Item in LogItems {
                            LogString += Item.Message
                        }
                        UIPasteboard.general.string = LogString
                    } label: {
                        Label("Copy to clipboard", systemImage: "doc.on.doc")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 80, height: 300)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(20)
        .onAppear {
            pipe.fileHandleForReading.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if data.isEmpty  {
                    fileHandle.readabilityHandler = nil
                    sema.signal()
                } else {
                    LogItems.append(LogItem(Message: String(data: data, encoding: .utf8)!))
                }
            }
            setvbuf(stdout, nil, _IONBF, 0)
            dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        }
    }
}

struct LogItem: Identifiable, Equatable {
    var id = UUID()
    var Message: String
}

extension String {
    // If last char is a new line remove it
    func lineFix() -> String {
        return String(self.last == "\n" ? String(self.dropLast()) : self)
    }
}
