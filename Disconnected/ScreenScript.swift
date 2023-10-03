import SwiftUI

let didChangeScreenParamsEvent = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)

struct ScreenScript: View {
    @AppStorage("screen.script")
    var script: URL?

    @State
    var presentScriptSheet = false

    @State
    var debug: String = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Image(systemName: "display")
                    .font(.system(size: 50, weight: .thin))
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(Color.white)

            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Choose the script to execute when receiving the system event.")
                    if let script = script {
                        HStack {
                            Label(script.path, systemImage: "terminal.fill")
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Remove script", action: remove)
                        }
                    } else {
                        HStack {
                            Button("Select script...", action: { presentScriptSheet = true })
                                .fileImporter(
                                    isPresented: $presentScriptSheet,
                                    allowedContentTypes: [.script],
                                    onCompletion: onSelect
                                )
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading) {
                    ScrollView {
                        HStack {
                            Text(debug)
                                .font(.body.monospaced())
                            Spacer()
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color.white)

                    Button("Clear debug") {
                        debug = ""
                    }
                }
            }
            .padding()
        }
        .onReceive(didChangeScreenParamsEvent) { event in
            print("Changed screen params \(event)")
            execute()
        }
    }

    private func onSelect(_ result: Result<URL, Error>) {
        switch result {
        case .success(let file):
            script = file
        case .failure(let error):
            print("Could not select script \(error)")
        }
    }

    private func execute() {
        guard let script = script else {
            return
        }
        do {
            if let output = try run(script: script) {
                debug += output
            }
        } catch {
            print("Unexpected error \(error)")
        }
    }

    private func run(script: URL) throws -> String? {
        let pipe = Pipe()

        let process = Process()
        process.standardOutput = pipe
        process.standardError = pipe

        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "source \(script.path)"]

        try process.run()

        print("Script completed")

        guard let data = try pipe.fileHandleForReading.readToEnd() else {
            print("Could not read output from pipe")
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func remove() {
        script = nil
    }
}

#Preview {
    ScreenScript()
        .frame(height: 500)
}
