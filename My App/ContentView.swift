import SwiftUI

struct ContentView: View {
    @State var kfd: UInt64 = 0
    @State var LogItems: [String] = ["Ready!"]
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scroll in
                    VStack(alignment: .leading) {
                        ForEach(0..<LogItems.count, id: \.self) { LogItem in
                            Text("[*] \(LogItems[LogItem])")
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
                    kfd = kopen(0x800, 0x0, 0x2, 0x2)
                } else {
                    postExploit()
                    kclose(kfd)
                    kfd = 0
                }
            } label: {
                Text(kfd == 0 ? "Exploit: Log 20" : "Post Exploit")
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

import SwiftUI

struct ContentView: View {
    @State var kfd: UInt64 = 0
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
                    kfd = kopen(0x800, 0x0, 0x2, 0x2)
                } else {
                    postExploit()
                    kclose(kfd)
                    kfd = 0
                }
            } label: {
                Text(kfd == 0 ? "Exploit: Log 19" : "Post Exploit")
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
    private(set) var outputFd: [Int32] = [0, 0]
    private(set) var errFd: [Int32] = [0, 0]
    private let readQueue: DispatchQueue
    private let outputSource: DispatchSourceRead
    private let errorSource: DispatchSourceRead
    init(_ LogItems: Binding<[Strinh]>) {
        readQueue = DispatchQueue(label: "org.coolstar.sileo.logstream", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        guard pipe(&outputFd) != -1,
            pipe(&errFd) != -1 else {
                fatalError("pipe failed")
        }
        let origOutput = dup(STDOUT_FILENO)
        let origErr = dup(STDERR_FILENO)
        setvbuf(stdout, nil, _IONBF, 0)
        guard dup2(outputFd[1], STDOUT_FILENO) >= 0,
            dup2(errFd[1], STDERR_FILENO) >= 0 else {
                fatalError("dup2 failed")
        }
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
                LogItems.wrappedValue.append(String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self)))
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
                LogItems.wrappedValue.append(String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self)))
            }
        }
        outputSource.resume()
        errorSource.resume()
    }
}
