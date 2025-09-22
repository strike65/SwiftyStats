import Testing
import Foundation
@testable import SwiftyStats

@Suite("Tukey Debug")
struct TukeyDebug {
    @Test("print values for specific case", .timeLimit(.minutes(1)), .enabled(if: ProcessInfo.processInfo.environment["SS_TUKEY_DEBUG"] == "1"))
    func printSpecific() throws {
        let q = 3.0, c = 29.0, df = 5.0, r = 13.0
        let tail: SSCDFTail = .lower
        let v_old = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: false)
        let v_new = try Helpers.ptukey_new(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: false)
        let l_old = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: true)
        let l_new = try Helpers.ptukey_new(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: true)
        print("Tukey(q=3,r=13,c=29,df=5,lower): old=\(v_old) new=\(v_new) log_old=\(l_old) log_new=\(l_new)")
    }

    @Test("print case 2", .timeLimit(.minutes(1)), .enabled(if: ProcessInfo.processInfo.environment["SS_TUKEY_DEBUG2"] == "1"))
    func printSpecific2() throws {
        let q = 4.5, c = 23.0, df = 240.0, r = 4.0
        let tail: SSCDFTail = .lower
        let p = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: false)
        let lp = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: true)
        let p_new = try Helpers.ptukey_new(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: false)
        let lp_new = try Helpers.ptukey_new(q: q, nranges: r, numberOfMeans: c, df: df, tail: tail, returnLogP: true)
        let p_upper = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .upper, returnLogP: false)
        let lp_upper = try Helpers.ptukey(q: q, nranges: r, numberOfMeans: c, df: df, tail: .upper, returnLogP: true)
        print("Tukey(q=4.5,r=4,c=23,df=240,lower): p=\(p) lp=\(lp) new_p=\(p_new) new_lp=\(lp_new) upper=\(p_upper) upper_log=\(lp_upper)")
    }
}
