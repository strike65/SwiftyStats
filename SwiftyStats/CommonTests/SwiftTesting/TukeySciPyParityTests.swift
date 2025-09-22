import Testing
import Foundation
@testable import SwiftyStats

@Suite("Tukey vs SciPy", .tags(.specialFunctions))
struct TukeySciPyParityTests {
    // Enable by providing CSV at SwiftyStats/Resources/tukey_refs.csv
    // Generated via SwiftyStats/Resources/gen_tukey_refs.py
    private static let refsPathCandidates: [String] = [
        "SwiftyStats/Resources/tukey_refs.csv",
        "./SwiftyStats/Resources/tukey_refs.csv",
        "../SwiftyStats/Resources/tukey_refs.csv",
    ]

    private static func locateRefs() -> String? {
        let fm = FileManager.default
        for p in refsPathCandidates {
            if fm.fileExists(atPath: p) { return p }
        }
        return nil
    }

    @Test("compare cdf with SciPy references", .timeLimit(.minutes(5)), .enabled(if: TukeySciPyParityTests.locateRefs() != nil))
    func compareWithSciPy() throws {
        guard let path = TukeySciPyParityTests.locateRefs() else { return }
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let lines = data.split(whereSeparator: { $0.isNewline })
        #expect(!lines.isEmpty)

        var table: [TukeyRefKey: TukeyRef] = [:]
        for (idx, line) in lines.enumerated() {
            if idx == 0 { continue } // skip header
            let parts = line.split(separator: ",")
            if parts.count < 7 { continue }
            guard let q = Double(parts[0]),
                  let nranges = Double(parts[1]),
                  let c = Double(parts[2]),
                  let df = Double(parts[3]) else { continue }
            let tailStr = String(parts[4])
            let logStr = String(parts[5])
            guard let ref = Double(parts[6]) else { continue }
            let tail: SSCDFTail = (tailStr == "upper") ? .upper : .lower
            let key = TukeyRefKey(q: q, nranges: nranges, c: c, df: df, tail: tail)
            var entry = table[key, default: TukeyRef()]
            if logStr == "true" {
                entry.log = ref
            } else {
                entry.prob = ref
            }
            table[key] = entry
        }

        let tinyTol = 5e-5
        let extremeTol = 5e-3
        let underflowTol = 3e-2 // allow slightly larger slack when R underflows to 0/1
        let absTolProb = 1e-7
        let absTolLog = 5e-4
        let relTolLog = 1e-3

        for (key, ref) in table {
            guard let probRef = ref.prob, let logRef = ref.log else { continue }
            let probVal = try Helpers.ptukey(q: key.q, nranges: key.nranges, numberOfMeans: key.c, df: key.df, tail: key.tail, returnLogP: false)
            let logVal = try Helpers.ptukey(q: key.q, nranges: key.nranges, numberOfMeans: key.c, df: key.df, tail: key.tail, returnLogP: true)

            let relTol = key.df > 5000 ? 5e-3 : 2e-3
            let isExtremeRef = probRef <= tinyTol || (1.0 - probRef) <= tinyTol || probRef.isNaN
            let isUnderflowRef = (probRef == 0.0) || (probRef == 1.0)
            let probOK: Bool
            if isExtremeRef {
                let tol = isUnderflowRef ? underflowTol : extremeTol
                probOK = probVal <= tol || (1.0 - probVal) <= tol || probVal.isNaN
            } else {
                probOK = refAlmostEqual(probVal, probRef, relTol: relTol, absTol: absTolProb)
            }

            #expect(probOK, "prob mismatch q=\(key.q), nranges=\(key.nranges), c=\(key.c), df=\(key.df), tail=\(key.tail), val=\(probVal), ref=\(probRef), relTol=\(relTol), absTol=\(absTolProb)")

            let logOK: Bool
            if isExtremeRef || !logRef.isFinite {
                let tol = isUnderflowRef ? underflowTol : extremeTol
                logOK = probVal <= tol || (1.0 - probVal) <= tol || probVal.isNaN
            } else {
                let diff = abs(logVal - logRef)
                let allowance = absTolLog + relTolLog * max(abs(logRef), 1.0)
                logOK = diff <= allowance
            }

            #expect(logOK, "log mismatch q=\(key.q), nranges=\(key.nranges), c=\(key.c), df=\(key.df), tail=\(key.tail), val=\(logVal), ref=\(logRef), absTol=\(absTolLog), relTol=\(relTolLog)")
        }
    }
}

private struct TukeyRefKey: Hashable {
    let q: Double
    let nranges: Double
    let c: Double
    let df: Double
    let tail: SSCDFTail
}

private struct TukeyRef {
    var prob: Double?
    var log: Double?
}

@inlinable
func refAlmostEqual(_ a: Double, _ b: Double, relTol: Double, absTol: Double = 0) -> Bool {
    if a.isNaN || b.isNaN { return false }
    let diff = abs(a - b)
    return diff <= max(relTol * max(abs(a), abs(b)), absTol)
}
