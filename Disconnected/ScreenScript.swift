import SwiftUI

let didChangeScreenParamsEvent = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)

struct ScreenScript: View {
    @AppStorage("screen.path")
    var path = ""

    @AppStorage("screen.arguments")
    var arguments = ""

    @State
    var presentFileImporter = false

    @State
    var debug = ""

    @State
    var frames: [CGRect] = []

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Image(systemName: "display")
                    .font(.system(size: 50, weight: .thin))
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(Color.white)

            VStack(spacing: 20) {
                Grid(alignment: .trailing) {
                    GridRow {
                        Text("Script")
                        HStack {
                            TextField("Path", text: $path)
                            Button("Select script...", action: { presentFileImporter = true })
                                .fileImporter(
                                    isPresented: $presentFileImporter,
                                    allowedContentTypes: [.script],
                                    onCompletion: onSelect
                                )
                        }
                    }

                    GridRow {
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
            let previous = frames
            frames = NSScreen.screens.map { $0.frame }
            guard previous == frames else {
                return
            }
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
