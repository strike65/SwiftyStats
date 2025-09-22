import Testing
import Foundation
@testable import SwiftyStats

@Suite("SSptukey Audit", .tags(.specialFunctions))
struct TukeySSptukeyAudit {
    private static let refsPathCandidates: [String] = [
        "SwiftyStats/Resources/tukey_refs.csv",
        "./SwiftyStats/Resources/tukey_refs.csv",
        "../SwiftyStats/Resources/tukey_refs.csv",
    ]

    private static func locateRefs() -> String? {
        let fm = FileManager.default
        for path in refsPathCandidates {
            if fm.fileExists(atPath: path) { return path }
        }
        return nil
    }

    @Test("report SSptukey error profile", .timeLimit(.minutes(5)), .enabled(if: ProcessInfo.processInfo.environment["SS_AUDIT_SSPTUKEY"] == "1" || ProcessInfo.processInfo.environment["SS_AUDIT_SSPTUKEY"]?.lowercased() == "true"))
    func auditAgainstReferences() throws {
        guard let path = TukeySSptukeyAudit.locateRefs() else {
            #expect(Bool(false), "Missing tukey_refs.csv for audit")
            return
        }
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let rows = data.split(whereSeparator: { $0.isNewline })
        guard !rows.isEmpty else {
            #expect(Bool(false), "Empty references file")
            return
        }

        let sampleLimit = ProcessInfo.processInfo.environment["SS_AUDIT_LIMIT"].flatMap(Double.init).map { Int($0) } ?? 2000
        var probStats = ErrorStats(kind: "probability")
        var logStats = ErrorStats(kind: "log-probability")

        for (index, line) in rows.enumerated() {
            if index == 0 { continue }
            let parts = line.split(separator: ",")
            if parts.count < 7 { continue }
            guard let q = Double(parts[0]),
                  let nranges = Double(parts[1]),
                  let c = Double(parts[2]),
                  let df = Double(parts[3]),
                  let ref = Double(parts[6]) else { continue }
            let tail: SSCDFTail = (parts[4] == "upper") ? .upper : .lower
            let isLog = (parts[5] == "true")

            let value = Helpers.SSptukey(q: q, nranges: nranges, numberOfMeans: c, df: df, tail: tail, returnLogP: isLog)
            let ctx = Context(q: q, nranges: nranges, c: c, df: df, tail: tail, isLog: isLog)
            if isLog {
                logStats.observe(value: value, reference: ref, context: ctx)
            } else {
                probStats.observe(value: value, reference: ref, context: ctx)
            }
            if probStats.count + logStats.count >= sampleLimit { break }
        }

        print(probStats.summary())
        print(logStats.summary())
        if let worst = probStats.finiteReferenceWorstAbs {
            let valProb = Helpers.SSptukey(q: worst.q, nranges: worst.nranges, numberOfMeans: worst.c, df: worst.df, tail: worst.tail, returnLogP: false)
            let baseline = try? Helpers.ptukey_new(q: worst.q, nranges: worst.nranges, numberOfMeans: worst.c, df: worst.df, tail: worst.tail, returnLogP: false)
            print("worstAbsProb ss=\(valProb) new=\(baseline ?? .nan) context=\(worst.description())")
            let singleRange = Helpers.SSptukey(q: worst.q, nranges: 1, numberOfMeans: worst.c, df: worst.df, tail: worst.tail, returnLogP: false)
            print("worstAbsProb singleRange=\(singleRange)")
        }
        if let worstRel = probStats.finiteReferenceWorstRel {
            let valProbRel = Helpers.SSptukey(q: worstRel.q, nranges: worstRel.nranges, numberOfMeans: worstRel.c, df: worstRel.df, tail: worstRel.tail, returnLogP: false)
            let baseline = try? Helpers.ptukey_new(q: worstRel.q, nranges: worstRel.nranges, numberOfMeans: worstRel.c, df: worstRel.df, tail: worstRel.tail, returnLogP: false)
            print("worstRelProb ss=\(valProbRel) new=\(baseline ?? .nan) context=\(worstRel.description())")
        }
        if let logWorst = logStats.finiteReferenceWorstAbs {
            let valLog = Helpers.SSptukey(q: logWorst.q, nranges: logWorst.nranges, numberOfMeans: logWorst.c, df: logWorst.df, tail: logWorst.tail, returnLogP: true)
            let baseline = try? Helpers.ptukey_new(q: logWorst.q, nranges: logWorst.nranges, numberOfMeans: logWorst.c, df: logWorst.df, tail: logWorst.tail, returnLogP: true)
            print("worstAbsLog ss=\(valLog) new=\(baseline ?? .nan) context=\(logWorst.description())")
        }
        if let logWorstRel = logStats.finiteReferenceWorstRel {
            let valLogRel = Helpers.SSptukey(q: logWorstRel.q, nranges: logWorstRel.nranges, numberOfMeans: logWorstRel.c, df: logWorstRel.df, tail: logWorstRel.tail, returnLogP: true)
            let baseline = try? Helpers.ptukey_new(q: logWorstRel.q, nranges: logWorstRel.nranges, numberOfMeans: logWorstRel.c, df: logWorstRel.df, tail: logWorstRel.tail, returnLogP: true)
            print("worstRelLog ss=\(valLogRel) new=\(baseline ?? .nan) context=\(logWorstRel.description())")
        }
        #expect(Bool(true))
    }
}

private struct Context {
    let q: Double
    let nranges: Double
    let c: Double
    let df: Double
    let tail: SSCDFTail
    let isLog: Bool

    func description() -> String {
        let tailLabel = tail == .upper ? "upper" : "lower"
        let mode = isLog ? "log" : "prob"
        return "mode=\(mode) q=\(q) nranges=\(nranges) c=\(c) df=\(df) tail=\(tailLabel)"
    }
}

private struct ErrorStats {
    let kind: String
    private(set) var count: Int = 0
    private(set) var finiteReferenceCount: Int = 0
    private(set) var finiteReferenceMaxAbs: Double = 0
    private(set) var finiteReferenceMaxRel: Double = 0
    private(set) var finiteReferenceWorstAbs: Context?
    private(set) var finiteReferenceWorstRel: Context?
    private(set) var infiniteRefMismatches: [Context] = []
    private(set) var nanRefMismatches: [Context] = []

    private let relFloor = 1e-12
    private let maxExamples = 10

    mutating func observe(value: Double, reference: Double, context: Context) {
        count += 1
        if reference.isFinite {
            finiteReferenceCount += 1
            let absDiff = abs(value - reference)
            if absDiff > finiteReferenceMaxAbs {
                finiteReferenceMaxAbs = absDiff
                finiteReferenceWorstAbs = context
            }
            let scale = max(abs(reference), relFloor)
            let relDiff = absDiff / scale
            if relDiff > finiteReferenceMaxRel {
                finiteReferenceMaxRel = relDiff
                finiteReferenceWorstRel = context
            }
        } else if reference.isInfinite {
            let ok = (reference.sign == .minus && value <= 0) || (reference.sign == .plus && value >= 0)
            if !ok && infiniteRefMismatches.count < maxExamples {
                infiniteRefMismatches.append(context)
            }
        } else if reference.isNaN {
            if !value.isNaN && nanRefMismatches.count < maxExamples {
                nanRefMismatches.append(context)
            }
        }
    }

    func summary() -> String {
        var lines: [String] = []
        lines.append("kind: \(kind)")
        lines.append("totalSamples: \(count)")
        lines.append("finiteReferenceCount: \(finiteReferenceCount)")
        lines.append(String(format: "maxAbsError: %.6e", finiteReferenceMaxAbs))
        if let ctx = finiteReferenceWorstAbs {
            lines.append("maxAbsContext: \(ctx.description())")
        }
        lines.append(String(format: "maxRelError: %.6e", finiteReferenceMaxRel))
        if let ctx = finiteReferenceWorstRel {
            lines.append("maxRelContext: \(ctx.description())")
        }
        if !infiniteRefMismatches.isEmpty {
            lines.append("infiniteReferenceMismatches: \(infiniteRefMismatches.count)")
            for ctx in infiniteRefMismatches {
                lines.append("  ctx=\(ctx.description())")
            }
        }
        if !nanRefMismatches.isEmpty {
            lines.append("nanReferenceMismatches: \(nanRefMismatches.count)")
            for ctx in nanRefMismatches {
                lines.append("  ctx=\(ctx.description())")
            }
        }
        return lines.joined(separator: "\n")
    }
}
