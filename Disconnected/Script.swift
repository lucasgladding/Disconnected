import Foundation

class Script {
    static func run(script: URL) throws -> String? {
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
}
