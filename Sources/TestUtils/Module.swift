import AIO
import Platform

struct Module {
    let name: String
    init(_ name: String) {
        self.name = name
    }

    var path: String? {
        return xcodeModuleUrl ?? swiftPMModuleUrl
    }

    private var xcodeModuleUrl: String? {
        guard let xcodeBuildDir =
            Environment["__XPC_DYLD_FRAMEWORK_PATH"],
            !xcodeBuildDir.contains(":") else {
                return nil
        }
        return Path(xcodeBuildDir)
            .appending("\(name).framework")
            .appending(name)
            .string
    }

    private var swiftPMModuleUrl: String? {
        var path = Path(#file)
            .deletingLastComponent
            .deletingLastComponent
            .deletingLastComponent
            .appending(".build")

        switch _isDebugAssertConfiguration() {
        case true: path.append("debug")
        case false: path.append("release")
        }
    #if os(macOS)
        path.append("lib\(name).dylib")
    #else
        path.append("lib\(name).so")
    #endif
        print(path.string)
        return path.string
    }
}
