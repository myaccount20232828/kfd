import SwiftUI

struct ContentView: View {
    @State var kfd: UInt64 = 0
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scroll in
                    VStack(alignment: .leading) {
                        ForEach(GetLogString().split(separator: "\n"), id: \.self) { LogItem in
                            Text("[*] \(String(LogItem))")
                            //.textSelection(.enabled)
                            .font(.custom("Menlo", size: 15))
                        }
                    }
                    .onReceive(GetString()) { obj in
                        DispatchQueue.global(qos: .utility).async {
                            //scroll.scrollTo(LogItems.count - 1)
                            UIPasteboard.general.string = "Refresh"
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width - 80, height: 300)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)          
            Button {
                if kfd == 0 {
                    kfd = kopen(0x800, 0x0, 0x2, 0x2)
                } else {
                    postExploit()
                    kclose(kfd)
                    kfd = 0
                    //UIPasteboard.general.string = GetLogString()
                }
            } label: {
                Text(kfd == 0 ? "Exploit: Log 2" : "Post Exploit")
                .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .frame(width: UIScreen.main.bounds.width - 80, height: 70)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
        }
    }
}
