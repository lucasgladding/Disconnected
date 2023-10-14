import Foundation

class Script {
    static func run(source: String, arguments: String = "") throws -> String? {
        let pipe = Pipe()

        let process = Process()
        process.standardOutput = pipe
        process.standardError = pipe

        var components: [String] = [source]
        if arguments != "" {
            components.append(arguments)
        }

        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = components

        try process.run()

        print("Script completed")

        guard let data = try pipe.fileHandleForReading.readToEnd() else {
            print("Could not read output from pipe")
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
