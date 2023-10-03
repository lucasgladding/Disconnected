import SwiftUI

let didChangeScreenParamsEvent = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)

struct ScriptForm: View {
    @State
    var presentScriptSheet = false

    @State
    var script: URL?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose the script to execute when receiving the system event.")
            if let script = script {
                HStack {
                    Label(script.path, systemImage: "terminal")
                    Spacer()
                    Button("Remove script", action: { self.script = nil })
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
        .onReceive(didChangeScreenParamsEvent) { _ in
            print("did change screen params")
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
            try run(script: script)
        } catch {
            print("Unexpected error \(error)")
        }
    }

    private func run(script: URL) throws {
        let pipe = Pipe()

        let process = Process()
        process.standardOutput = pipe
        process.standardError = pipe

        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "source \(script.path)"]

        try process.run()

        print("Script done")

        guard let data = try pipe.fileHandleForReading.readToEnd() else {
            print("Could not read output from pipe")
            return
        }

        if let output = String(data: data, encoding: .utf8) {
            print(output)
        }
    }
}

#Preview {
    ScriptForm()
        .frame(width: 600, height: 400)
}
