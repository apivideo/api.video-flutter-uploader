extension Progress {
    var percentage: Int {
        return Int(completedUnitCount * 100 / totalUnitCount)
    }
}
