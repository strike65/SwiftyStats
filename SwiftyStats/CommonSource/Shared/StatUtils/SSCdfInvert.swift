import Foundation

extension Helpers {
    /// Generic inverter for a monotonically increasing CDF on [lowerBound, +∞) or a finite interval.
    ///
    /// - Parameters:
    ///   - lowerBound: Left bracket (finite). Caller ensures the target is >= CDF(lowerBound).
    ///   - upperSeed: Initial right bracket seed; the routine will expand geometrically if needed.
    ///   - target: Target lower-tail probability in (0, 1).
    ///   - cdf: Monotonically increasing CDF function.
    ///   - maxExpandIters: Max geometric expansions of the right bracket.
    ///   - maxBisectionIters: Max bisection iterations.
    ///   - probTol: Probability tolerance |F(x) - p|.
    ///   - xTol: Abscissa tolerance |hi - lo|.
    /// - Returns: x such that CDF(x) ~= target within tolerances.
    @inlinable
    internal static func invertCDFMonotone<FPT: SSFloatingPoint>(
        lowerBound: FPT,
        upperSeed: FPT,
        target: FPT,
        cdf: (FPT) throws -> FPT,
        maxExpandIters: Int = 64,
        maxBisectionIters: Int = 256,
        probTol: FPT = FPT(1) / FPT(1_000_000_000_000),
        xTol: FPT = FPT(1) / FPT(1_000_000_000_000)
    ) rethrows -> FPT {
        var lo = lowerBound
        var hi = upperSeed > lowerBound ? upperSeed : (lowerBound + FPT.one)
        var fhi = try cdf(hi)
        var i = 0
        while fhi < target && i < maxExpandIters {
            let width = hi - lo
            hi = lo + (width > FPT.zero ? width * FPT(2) : FPT.one)
            fhi = try cdf(hi)
            i += 1
        }

        var mid = hi
        var it = 0
        while it < maxBisectionIters {
            mid = (lo + hi) * FPT.half
            let fmid = try cdf(mid)
            if abs(fmid - target) <= probTol || (hi - lo) <= xTol { break }
            if fmid < target { lo = mid } else { hi = mid }
            it += 1
        }
        return mid
    }
}

