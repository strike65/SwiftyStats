import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Helpers {
    internal static func SSptukey(q: Double, nranges: Double, numberOfMeans: Double, df: Double, tail: SSCDFTail, returnLogP: Bool) -> Double {
        if q.isNaN || nranges.isNaN || numberOfMeans.isNaN || df.isNaN { return .nan }
        if q <= 0 { return Helpers.r_dt_0(tail: tail, log_p: returnLogP) }
        if df < 2 || nranges < 1 || numberOfMeans < 2 { return .nan }
        if !q.isFinite { return Helpers.r_dt_1(tail: tail, log_p: returnLogP) }

        let rr = max(1.0, floor(nranges))
        let cc = max(2.0, floor(numberOfMeans))

        do {
            // Prefer the newer, numerically-improved implementation
            return try Helpers.ptukey_new(q: q, nranges: rr, numberOfMeans: cc, df: df, tail: tail, returnLogP: returnLogP)
        } catch {
            // Fallback to legacy implementation on unexpected errors
            do {
                return try Helpers.ptukey(q: q, nranges: rr, numberOfMeans: cc, df: df, tail: tail, returnLogP: returnLogP)
            } catch {
                return .nan
            }
        }
    }
}
