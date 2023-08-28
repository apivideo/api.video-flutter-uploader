extension Progress {
    var percentage: Int {
        return Int(completedUnitCount * 100 / totalUnitCount)
    }

    var progress: Double {
        return Double(completedUnitCount) / Double(totalUnitCount)
    }
}
