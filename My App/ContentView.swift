import SwiftUI

struct ContentView: View {
    @State var kfd: UInt64 = 0
    @State var test = "nothing"
    @State var LogItems: [String.SubSequence] = ["Ready!"]
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scroll in
                    VStack(alignment: .leading) {
                        ForEach(0..<LogItems.count, id: \.self) { LogItem in
                            Text("[*] \(String(LogItems[LogItem]))")
                            .font(.custom("Menlo", size: 15))
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("com.AppInstalleriOS.LogStream"))) { obj in
                        DispatchQueue.global(qos: .utility).async {
                            test = "\(test)\nchanged"
                            LogItems = GetLogString.split(separator: "\n")
                            scroll.scrollTo(LogItems.count - 1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width - 80, height: 300)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
            Text(test)
            Button {
                if kfd == 0 {
                    kfd = kopen(0x800, 0x0, 0x2, 0x2)
                } else {
                    postExploit()
                    kclose(kfd)
                    kfd = 0
                    UIPasteboard.general.string = GetLogString()
                }
            } label: {
                Text(kfd == 0 ? "Exploit: Log 6" : "Post Exploit")
                .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .frame(width: UIScreen.main.bounds.width - 80, height: 70)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
            Button {
                testPrint()
            } label: {
                Text("Test")
            }
        }
    }
}
