extension String {
    func deletePrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    var url: URL {
        return URL(fileURLWithPath: deletePrefix("file://"))
    }
}
