import Testing
import Foundation
@testable import SwiftyStats

extension Tag {
    @Tag static var specialFunctions: Self
}

@Suite("SSptukey vs ptukey", .tags(.specialFunctions))
struct TukeyComparisonTests {

    @Test("moderate df, c=5", .timeLimit(.minutes(1)), .enabled(if: ProcessInfo.processInfo.environment["SS_COMPARE_TUKEY"] == "1" || ProcessInfo.processInfo.environment["SS_COMPARE_TUKEY"]?.lowercased() == "true"))
    func compareModerateDF() throws {
        let q = 3.5, c = 5.0, df = 10.0, r = 1.0
        let oldv = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
        let newv = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
        let ok = relativeAlmostEqual(oldv, newv, relTol: 5e-3, absTol: 1e-6)
        #expect(ok, "q=\(q), c=\(c), df=\(df), r=\(r), old=\(oldv), new=\(newv)")
    }

    @Test("df=30, c=10", .timeLimit(.minutes(1)), .enabled(if: ProcessInfo.processInfo.environment["SS_COMPARE_TUKEY"] == "1" || ProcessInfo.processInfo.environment["SS_COMPARE_TUKEY"]?.lowercased() == "true"))
    func compareDF30() throws {
        let q = 4.0, c = 10.0, df = 30.0, r = 1.0
        let oldv = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
        let newv = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
        let ok = relativeAlmostEqual(oldv, newv, relTol: 5e-3, absTol: 1e-6)
        #expect(ok, "q=\(q), c=\(c), df=\(df), r=\(r), old=\(oldv), new=\(newv)")
    }

    @Test("df=120, c=3", .timeLimit(.minutes(1)), .enabled(if: ProcessInfo.processInfo.environment["SS_COMPARE_TUKEY"] == "1" || ProcessInfo.processInfo.environment["SS_COMPARE_TUKEY"]?.lowercased() == "true"))
    func compareDF120() throws {
        let q = 6.0, c = 3.0, df = 120.0, r = 1.0
        let oldv = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
        let newv = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
        let ok = relativeAlmostEqual(oldv, newv, relTol: 5e-3, absTol: 1e-6)
        #expect(ok, "q=\(q), c=\(c), df=\(df), r=\(r), old=\(oldv), new=\(newv)")
    }

    @Test("very large df path", .timeLimit(.minutes(1)), .enabled(if: ProcessInfo.processInfo.environment["SS_COMPARE_TUKEY"] == "1" || ProcessInfo.processInfo.environment["SS_COMPARE_TUKEY"]?.lowercased() == "true"))
    func compareLargeDF() throws {
        let q = 4.5, c = 8.0, df = 50000.0, r = 1.0
        let oldv = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
        let newv = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
        let ok = relativeAlmostEqual(oldv, newv, relTol: 1e-2, absTol: 1e-6)
        #expect(ok, "q=\(q), c=\(c), df=\(df), r=\(r), old=\(oldv), new=\(newv)")
    }
}

@inlinable
func relativeAlmostEqual(_ a: Double, _ b: Double, relTol: Double, absTol: Double = 0) -> Bool {
    if a.isNaN || b.isNaN { return false }
    let diff = abs(a - b)
    return diff <= max(relTol * max(abs(a), abs(b)), absTol)
}
