import SwiftUI

struct ContentView: View {
    @State var kfd: UInt64 = 0
    @State var LogItems: [String.SubSequence] = ["Ready!"]
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scroll in
                    VStack(alignment: .leading) {
                        ForEach(LogItems, id: \.self) { LogItem in
                            Text("[*] \(String(LogItem))")
                            .font(.custom("Menlo", size: 15))
                        }
                    }
                    .onChange(of: LogItems) { _ in
                        DispatchQueue.global(qos: .utility).async {
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
            Button {
                if kfd == 0 {
                    kfd = kopen(UInt64(2048), 0x0, 0x2, 0x2)
                } else {
                    postExploit()
                    kclose(kfd)
                    kfd = 0
                }
            } label: {
                Text(kfd == 0 ? "Exploit: Log v3" : "Post Exploit")
                .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .frame(width: UIScreen.main.bounds.width - 80, height: 70)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
            Button {
                print(Date())
            } label: {
                Text("Test")
            }
            Button {
                postExploit()
            } label: {
                Text("Post Exploit")
            }
            .disabled(kfd == 0)
        }
        .onAppear {
            LogStream($LogItems)
        }
    }
}

//From https://github.com/Odyssey-Team/Taurine/blob/main/Taurine/app/LogStream.swift
//Code from Taurine https://github.com/Odyssey-Team/Taurine under BSD 4 License
class LogStream {
    private(set) var outputString = ""
    private(set) var outputFd: [Int32] = [0, 0]
    private(set) var errFd: [Int32] = [0, 0]
    private let readQueue: DispatchQueue
    private let outputSource: DispatchSourceRead
    private let errorSource: DispatchSourceRead
    init(_ LogItems: Binding<[String.SubSequence]>) {
        readQueue = DispatchQueue(label: "org.coolstar.sileo.logstream", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        pipe(&outputFd)
        pipe(&errFd)
        let origOutput = dup(STDOUT_FILENO)
        let origErr = dup(STDERR_FILENO)
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(outputFd[1], STDOUT_FILENO)
        dup2(errFd[1], STDERR_FILENO)
        outputSource = DispatchSource.makeReadSource(fileDescriptor: outputFd[0], queue: readQueue)
        errorSource = DispatchSource.makeReadSource(fileDescriptor: errFd[0], queue: readQueue)
        outputSource.setCancelHandler {
            close(self.outputFd[0])
            close(self.outputFd[1])
        }
        errorSource.setCancelHandler {
            close(self.errFd[0])
            close(self.errFd[1])
        }
        let bufsiz = Int(BUFSIZ)
        outputSource.setEventHandler {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsiz)
            defer { buffer.deallocate() }
            let bytesRead = read(self.outputFd[0], buffer, bufsiz)
            guard bytesRead > 0 else {
                if bytesRead == -1 && errno == EAGAIN {
                    return
                }
                self.outputSource.cancel()
                return
            }
            write(origOutput, buffer, bytesRead)
            let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
            array.withUnsafeBufferPointer { ptr in
                let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                self.outputString.append(str)
                LogItems.wrappedValue = self.outputString.split(separator: "\n")
            }
        }
        errorSource.setEventHandler {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsiz)
            defer { buffer.deallocate() }
            let bytesRead = read(self.errFd[0], buffer, bufsiz)
            guard bytesRead > 0 else {
                if bytesRead == -1 && errno == EAGAIN {
                    return
                }
                self.errorSource.cancel()
                return
            }
            write(origErr, buffer, bytesRead)
            let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
            array.withUnsafeBufferPointer { ptr in
                let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                self.outputString.append(str)
                UIPasteboard.general.string = self.outputString
                LogItems.wrappedValue = self.outputString.split(separator: "\n")
            }
        }
        outputSource.resume()
        errorSource.resume()
    }
}
