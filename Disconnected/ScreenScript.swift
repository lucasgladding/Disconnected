import SwiftUI

let didChangeScreenParamsEvent = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)

struct ScreenScript: View {
    @AppStorage("screen.path")
    var path = ""

    @AppStorage("screen.arguments")
    var arguments = ""

    @State
    var presentFileImportSheet = false

    @State
    var debug = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Image(systemName: "display")
                    .font(.system(size: 50, weight: .thin))
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(Color.white)

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Script")
                        TextField("Path", text: $path)
                        Button("Select script...", action: { presentFileImportSheet = true })
                            .fileImporter(
                                isPresented: $presentFileImportSheet,
                                allowedContentTypes: [.script],
                                onCompletion: onSelect
                            )
                    }

                    HStack {
                        Text("Arguments")
                        TextField("Arguments", text: $arguments)
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
        .onReceive(didChangeScreenParamsEvent) { _ in
            print("Changed screen params")
            execute()
        }
    }

    private func onSelect(_ result: Result<URL, Error>) {
        switch result {
        case .success(let file):
            path = file.path()
        case .failure(let error):
            print("Could not select script \(error)")
        }
    }

    private func execute() {
        do {
            if let output = try Script.run(source: path, arguments: arguments) {
                debug += output
            }
        } catch {
            print("Unexpected error \(error)")
        }
    }
}

#Preview {
    ScreenScript()
        .frame(height: 500)
}
