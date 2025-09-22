import Testing
import Foundation
@testable import SwiftyStats

@Suite("SSptukey core behavior", .tags(.specialFunctions))
struct TukeySSptukeyCoreTests {

    @Test("parity with ptukey_new over grid", .timeLimit(.minutes(2)))
    func parityWithNewImpl() throws {
        let qs: [Double] = [0.5, 2.5, 4.0, 6.5]
        let cs: [Double] = [3.0, 5.0, 10.0]
        let dfs: [Double] = [5.0, 30.0, 120.0, 10000.0]
        let rs: [Double] = [1.0, 2.0]
        let tails: [SSCDFTail] = [.lower, .upper]
        for q in qs {
            for c in cs {
                for df in dfs {
                    for r in rs {
                        for tail in tails {
                            let refProb = try Helpers.ptukey_new(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: false)
                            let valProb = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: false)
                            let okProb = almostEqualRelAbs(refProb, valProb, relTol: 2e-3, absTol: 1e-7)
                            #expect(okProb, "prob mismatch q=\(q), c=\(c), df=\(df), r=\(r), tail=\(tail), ref=\(refProb), val=\(valProb)")

                            let refLog = try Helpers.ptukey_new(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: true)
                            let valLog = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: true)
                            let okLog: Bool
                            if refLog.isFinite && valLog.isFinite {
                                let diff = abs(refLog - valLog)
                                okLog = diff <= (5e-4 + 2e-3 * max(abs(refLog), 1.0))
                            } else {
                                // Treat matching infinities (same sign) or both NaN as equal
                                okLog = (refLog.isInfinite && valLog.isInfinite && refLog.sign == valLog.sign) || (refLog.isNaN && valLog.isNaN)
                            }
                            #expect(okLog, "log mismatch q=\(q), c=\(c), df=\(df), r=\(r), tail=\(tail), ref=\(refLog), val=\(valLog)")
                        }
                    }
                }
            }
        }
    }

    @Test("monotonicity in q", .timeLimit(.minutes(1)))
    func monotonicity() throws {
        let c = 8.0, df = 30.0, r = 1.0
        let qs = stride(from: 0.2, through: 8.0, by: 0.2)
        var lastLower = -Double.infinity
        var lastUpper = Double.infinity
        for q in qs {
            let pLower = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false)
            let pUpper = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .upper, returnLogP: false)
            #expect(pLower >= lastLower - 1e-12, "lower tail not non-decreasing at q=\(q)")
            #expect(pUpper <= lastUpper + 1e-12, "upper tail not non-increasing at q=\(q)")
            lastLower = pLower
            lastUpper = pUpper
        }
    }

    @Test("log matches log(prob)", .timeLimit(.minutes(1)))
    func logConsistency() {
        let params: [(Double, Double, Double, Double, SSCDFTail)] = [
            (3.5, 1.0, 5.0, 30.0, .lower),
            (5.0, 2.0, 10.0, 120.0, .upper),
        ]
        for (q, r, c, df, tail) in params {
            let p = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: false)
            let lp = Helpers.SSptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: true)
            if p == 0.0 {
                #expect(lp.isInfinite && lp.sign == .minus, "expected log-prob to be -inf when p == 0; got lp=\(lp)")
            } else if p == 1.0 {
                #expect(lp == 0.0, "expected log-prob to be 0 when p == 1; got lp=\(lp)")
            } else {
                #expect(p > 0 && p < 1)
                let diff = abs(lp - log(p))
                #expect(diff < 1e-8, "log inconsistency q=\(q), r=\(r), c=\(c), df=\(df), tail=\(tail), p=\(p), lp=\(lp)")
            }
        }
    }

    @Test("domain and limits", .timeLimit(.minutes(1)))
    func domainAndLimits() {
        let c = 4.0, df = 10.0, r = 1.0
        // q <= 0
        #expect(Helpers.SSptukey(q: 0.0, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false) == 0.0)
        #expect(Helpers.SSptukey(q: 0.0, nranges: r, numberOfMeans: c, df: df, tail: .upper, returnLogP: false) == 1.0)
        #expect(Helpers.SSptukey(q: 0.0, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: true) == -.infinity)
        #expect(Helpers.SSptukey(q: 0.0, nranges: r, numberOfMeans: c, df: df, tail: .upper, returnLogP: true) == 0.0)

        // invalid df / c / r
        #expect(Helpers.SSptukey(q: 1.0, nranges: 0.0, numberOfMeans: c, df: df, tail: .lower, returnLogP: false).isNaN)
        #expect(Helpers.SSptukey(q: 1.0, nranges: r, numberOfMeans: 1.0, df: df, tail: .lower, returnLogP: false).isNaN)
        #expect(Helpers.SSptukey(q: 1.0, nranges: r, numberOfMeans: c, df: 1.0, tail: .lower, returnLogP: false).isNaN)

        // q = +inf
        #expect(Helpers.SSptukey(q: .infinity, nranges: r, numberOfMeans: c, df: df, tail: .lower, returnLogP: false) == 1.0)
        #expect(Helpers.SSptukey(q: .infinity, nranges: r, numberOfMeans: c, df: df, tail: .upper, returnLogP: false) == 0.0)
    }
}

@inlinable
func almostEqualRelAbs(_ a: Double, _ b: Double, relTol: Double, absTol: Double = 0) -> Bool {
    if a.isNaN || b.isNaN { return false }
    let diff = abs(a - b)
    return diff <= max(relTol * max(abs(a), abs(b)), absTol)
}
