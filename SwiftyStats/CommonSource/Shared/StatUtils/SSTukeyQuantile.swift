import Foundation

extension Helpers {
    /// Quantile of Tukey's studentized range distribution.
    ///
    /// Solves for q such that P(Q <= q) = p (for the requested tail) using a
    /// robust bracketing+bisection scheme. The CDF P(Q <= q) is evaluated by
    /// the clean implementation `ptukey_new` described in SSTukeyNew.swift.
    ///
    /// Mathematical notes
    /// ------------------
    /// - The CDF in q is continuous and strictly increasing on q > 0, so
    ///   bracketing by doubling the upper endpoint followed by bisection is
    ///   guaranteed to converge.
    /// - Input p is converted to the lower-tail probability via r_derived
    ///   helpers, supporting both tail selection and log-prob input.
    /// - Boundary handling: p <= 0 → q = 0; p >= 1 → q = +∞.
    internal static func qtukey(p: Double, nranges: Double, numberOfMeans: Double, df: Double, tail: SSCDFTail, log_p: Bool) throws -> Double {
        // NaN handling
        if p.isNaN || nranges.isNaN || numberOfMeans.isNaN || df.isNaN { return .nan }
        if df < 2 || nranges < 1 || numberOfMeans < 2 { return .nan }

        // Convert input probability to lower-tail probability in [0, 1]
        let pl: Double = Helpers.r_dt_qIv(x: p, tail: tail, log_p: log_p)
        if pl <= 0 { return 0 }
        if pl >= 1 || !pl.isFinite { return .infinity }

        // Normalize discrete params to valid domain
        let rr = max(1.0, floor(nranges))
        let cc = max(2.0, floor(numberOfMeans))

        // Bracket [lo, hi] with F(lo) <= pl <= F(hi)
        var lo = 0.0
        var hi = 1.0
        func cdf(_ q: Double) throws -> Double { try Helpers.ptukey_new(q: q, nranges: rr, numberOfMeans: cc, df: df, tail: .lower, returnLogP: false) }

        var fhi = try cdf(hi)
        var iter = 0
        while fhi < pl && iter < 64 {
            hi *= 2
            fhi = try cdf(hi)
            iter += 1
        }

        // Bisection solve (monotone in q)
        let tolProb = 1e-10
        let tolQ = 1e-10
        var mid = hi
        while iter < 256 {
            mid = 0.5 * (lo + hi)
            let fmid = try cdf(mid)
            if abs(fmid - pl) <= tolProb || (hi - lo) <= tolQ { break }
            if fmid < pl {
                lo = mid
            } else {
                hi = mid
                fhi = fmid
            }
            iter += 1
        }
        return mid
    }
}
