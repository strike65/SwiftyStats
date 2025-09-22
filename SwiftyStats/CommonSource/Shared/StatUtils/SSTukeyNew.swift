//
//  SSTukeyNew.swift
//  Clean Swift 6 implementation of Tukey's studentized range distribution.
//
//  Mathematical summary
//  --------------------
//  Let Q denote Tukey's studentized range statistic for c means and df error
//  degrees of freedom. The lower-tail CDF P(Q <= q) can be expressed via a
//  mixture over a scale parameter arising from the t/chi-square components.
//
//  For df -> infinity (known variance), the distribution reduces to the
//  range of i.i.d. standard normals. Using Hartley's form, the CDF for a
//  single range of width w is
//
//     W(w; c) = [ 2 Phi(w/2) - 1 ]^c
//               + c * ∫ phi(x) * [ Phi(x) - Phi(x - w) ]^(c-1) dx,  x ∈ [w/2, ∞),
//
//  where Phi and phi denote the standard normal CDF and PDF. For rr
//  independent ranges, the probability becomes W(w; c)^rr. We evaluate W via
//  Gauss–Legendre quadrature on sub-intervals of [w/2, 8], plus the closed
//  form term.
//
//  For finite df, we integrate W over a mixing density that depends on df.
//  This file computes
//
//     P(Q <= q) ≈ ∫ W( q * sqrt(u/2) ; c )^rr * g_df(u) du
//
//  using 16-point Gauss–Legendre quadrature in the outer integral with a
//  stable log-weight formulation. The implementation follows the same
//  structure used in common statistical libraries but is written afresh for
//  Swift with careful cutoffs for numerical stability (underflow/overflow).
//
//  Numerical details
//  -----------------
//  - Inner integral (W): 12-point Gauss–Legendre on 2–3 sub-intervals.
//  - Outer integral (mixture over df): 16-point Gauss–Legendre; sub-interval
//    size chosen by df; large-df shortcut uses the normal-range approximation.
//  - Thresholds on exponential terms and small contributions are applied to
//    avoid denormals while keeping relative error small across the domain.
//  - Tail/log-p handling is delegated to r_derived_macros for consistency.
//
//  References
//  ----------
//  - Hartley, H. O. (1950s/60s work on the range distribution)
//  - Copenhaver, M. D., & Holland, B. S. (1988). Multiple comparisons of
//    simple effects in two-way ANOVA with fixed effects.
//  - Stroud, A. H., & Secrest, D. (1966). Gaussian Quadrature Formulas.
//

import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

// MARK: - Core numerics

/// Compute W(w; c)^rr where W(w; c) is the lower-tail CDF of the normal-range
/// distribution (df = ∞ case) for range width w and number of means c.
///
/// Implements Hartley’s decomposition:
///   W(w; c) = [2 Phi(w/2) - 1]^c + c ∫ phi(x) [Phi(x) - Phi(x-w)]^(c-1) dx,
/// with the integral evaluated by Gauss–Legendre over x ∈ [w/2, 8].
/// Returns W(w; c)^rr with early cutoffs for very small/large probabilities.
fileprivate func ss_wprob(_ w: Double, rr: Double, cc: Double) throws -> Double {
    // Guard trivial/limit cases
    let qsqz = 0.5 * w
    if qsqz <= 0 { return 0 }
    if qsqz >= 8.0 { return 1.0 }

    // Gauss–Legendre (order 12) nodes/weights on (0, 1)
    let nleg = 12
    let ihalf = nleg / 2
    let xleg: [Double] = [
        0.981560634246719250690549090149,
        0.904117256370474856678465866119,
        0.769902674194304687036893833213,
        0.587317954286617447296702418941,
        0.367831498998180193752691536644,
        0.125233408511468915472441369464
    ]
    let aleg: [Double] = [
        0.047175336386511827194615961485,
        0.106939325995318430960254718194,
        0.160078328543346226334652529543,
        0.203167426723065921749064455810,
        0.233492536538354808760849898925,
        0.249147045813402785000562436043
    ]

    // First Hartley term: [2 Phi(w/2) - 1]^c
    var pr_w = 2.0 * (try SSProbDist.Gaussian.cdf(x: qsqz, mean: 0, variance: 1)) - 1.0
    if pr_w >= exp(-80.0 / cc) { // C2 cut-off (more permissive)
        pr_w = pow(pr_w, cc)
    } else {
        pr_w = 0.0
    }

    // Choose number of subintervals for the second term
    let wlar = 3.0
    let wincr = (w > wlar) ? 2.0 : 3.0

    // Integrate f(x) = c * phi(x) * [Phi(x) - Phi(x - w)]^(c-1) over x in [w/2, 8]
    var blb = qsqz
    var bub = min(8.0, blb + wincr)
    var einsum = 0.0
    let cc1 = cc - 1.0
    while blb < 8.0 - 1e-15 {
        // Midpoint/half-length for affine map from u in [-1,1]
        let a = 0.5 * (bub + blb)
        let b = 0.5 * (bub - blb)
        var elsum = 0.0
        var jj = 1
        while jj <= nleg {
            let j = (jj > ihalf) ? (nleg - jj + 1) : jj
            let xx = (jj > ihalf) ? xleg[j - 1] : -xleg[j - 1]
            let ac = a + b * xx
            // If exp(-ac^2/2) is too small, break
            let qexpo = ac * ac
            if qexpo > 80.0 { break }
            // Compute rinsum = Phi(ac) - Phi(ac - w)
            let pplus = try SSProbDist.Gaussian.cdf(x: ac, mean: 0, variance: 1)
            let pminus = try SSProbDist.Gaussian.cdf(x: ac, mean: w, variance: 1)
            let rinsum = pplus - pminus
            // Ignore small contributions (more permissive)
            if rinsum >= exp(-60.0 / cc1) {
                // Add Legendre contribution
                let term = aleg[j - 1] * exp(-0.5 * qexpo) * pow(rinsum, cc1)
                elsum += term
            }
            jj += 1
        }
        // Scale by mapping Jacobian and constants
        elsum *= (2.0 * b) * cc * Double.sqrt2piinv
        einsum += elsum
        blb = bub
        bub = min(8.0, bub + wincr)
    }
    pr_w += einsum
    // If pr_w^rr is tiny, return 0 (more permissive)
    if pr_w <= exp(-60.0 / rr) { return 0.0 }
    pr_w = pow(pr_w, rr)
    if pr_w >= 1.0 { return 1.0 }
    return pr_w
}

/// Lower/upper tail CDF for Tukey's studentized range with parameters:
///  - q: statistic value (q > 0)
///  - rr: number of independent ranges (nranges ≥ 1, internally floored)
///  - cc: number of means per range (c ≥ 2, internally floored)
///  - df: degrees of freedom for the error term (df ≥ 2)
///  - tail: lower vs upper tail selection
///  - logP: whether to return log-probability
///
/// For df > 25000 we use the normal-range approximation W, otherwise a
/// Gauss–Legendre mixture integral in a stable log-weight form.
fileprivate func ss_ptukey(q: Double, rr: Double, cc: Double, df: Double, tail: SSCDFTail, logP: Bool) throws -> Double {
    // Guard invalid input
    if q <= 0 { return Helpers.r_dt_0(tail: tail, log_p: logP) }
    if df < 2 || rr < 1 || cc < 2 { return Double.nan }
    if !q.isFinite { return Helpers.r_dt_1(tail: tail, log_p: logP) }

    // Large df: approximate with range distribution of standard normal
    if df > 25000 {
        let w = try ss_wprob(q, rr: rr, cc: cc)
        return Helpers.r_dt_val(x: w, tail: tail, log_p: logP)
    }

    // Gauss–Legendre (order 16) for outer integral
    let nlegq = 16
    let ihalfq = 8
    let xlegq: [Double] = [
        0.989400934991649932596154173450,
        0.944575023073232576077988415535,
        0.865631202387831743880467897712,
        0.755404408355003033895101194847,
        0.617876244402643748446671764049,
        0.458016777657227386342419442984,
        0.281603550779258913230460501460,
        0.0950125098376374401853193354250
    ]
    let alegq: [Double] = [
        0.0271524594117540948517805724560,
        0.0622535239386478928628438369944,
        0.0951585116824927848099251076022,
        0.124628971255533872052476282192,
        0.149595988816576732081501730547,
        0.169156519395002538189312079030,
        0.182603415044923588866763667969,
        0.189450610455068496285396723208
    ]

    // Integration parameters per df (more permissive thresholds)
    let eps1 = -80.0
    let eps2 = 1.0e-16
    let dhaf = 100.0
    let dquar = 800.0
    let deigh = 5000.0
    let ulen1 = 1.0, ulen2 = 0.5, ulen3 = 0.25, ulen4 = 0.125

    let f2 = 0.5 * df
    let f2lf = (f2 * log(df)) - (df * Double.ln2) - lgamma(f2)
    let f21 = f2 - 1.0

    var ulen: Double
    if df <= dhaf { ulen = ulen1 }
    else if df <= dquar { ulen = ulen2 }
    else if df <= deigh { ulen = ulen3 }
    else { ulen = ulen4 }

    func integrateOnce(ulen: Double) throws -> Double {
        var ansLoc = 0.0
        var i = 1
        while i <= 100 {
            var otsum = 0.0
            let twa1 = (2.0 * Double(i) - 1.0) * ulen
            var jj = 1
            while jj <= nlegq {
                let j: Int
                let signPlus = (jj > ihalfq)
                if signPlus {
                    j = jj - ihalfq - 1
                } else {
                    j = jj - 1
                }
                let x = xlegq[j]
                let xl = x * ulen
                let expoTerm: Double
                let arg: Double
                if signPlus {
                    expoTerm = f2lf + f21 * log(twa1 + xl) - (xl + twa1) * (0.25 * df)
                    arg = (x * ulen + twa1) * 0.5
                } else {
                    expoTerm = f2lf + f21 * log(twa1 - xl) + (xl - twa1) * (0.25 * df)
                    arg = (-x * ulen + twa1) * 0.5
                }
                if expoTerm >= eps1 {
                    let a = max(0.0, arg)
                    let qsqz = q * sqrt(a)
                    let wprb = try ss_wprob(qsqz, rr: rr, cc: cc)
                    let contrib = wprb * alegq[j] * exp(expoTerm)
                    otsum += contrib
                }
                jj += 1
            }
            if Double(i) * ulen > 1.0 && otsum <= eps2 { break }
            // Gauss–Legendre on [-1,1] scaled to segment length; multiply by ulen (Jacobian)
            ansLoc += (ulen * otsum)
            i += 1
        }
        return min(1.0, ansLoc)
    }
    var ans = try integrateOnce(ulen: ulen)
    if ans == 0.0 {
        let finer = ulen * 0.5
        ans = try integrateOnce(ulen: finer)
    }
    if ans > 1.0 { ans = 1.0 }
    return Helpers.r_dt_val(x: ans, tail: tail, log_p: logP)
}

// MARK: - Public shim

extension Helpers {
    internal static func ptukey_new(q: Double, nranges: Double, numberOfMeans: Double, df: Double, tail: SSCDFTail, returnLogP: Bool) throws -> Double {
        return try ss_ptukey(q: q, rr: nranges, cc: numberOfMeans, df: df, tail: tail, logP: returnLogP)
    }
}
