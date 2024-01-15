import SwiftUI

struct ContentView: View {
    @State var kfd: UInt64 = 0
    var body: some View {
        VStack {
            Text(GetLogString())
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
                Text(kfd == 0 ? "Exploit: Log 4" : "Post Exploit")
                .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .frame(width: UIScreen.main.bounds.width - 80, height: 70)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
        }
    }
}
