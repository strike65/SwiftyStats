//
//  ProbDist-NonCentralStudentT.swift
//  SwiftyStats
//
//  Alternative, Double-based implementation of the noncentral Student's t
//  distribution (CDF, PDF, Quantile, Parameters) without Accelerate.
//  Uses numerically-stable integration in Double and converts back to
//  generic SSFloatingPoint at the API surface. Designed to work on arm64.
//
/*
 Copyright (2017-2019) strike65
 
 GNU GPL 3+
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif
#if os(macOS) || os(iOS)
import os.log
#endif

// MARK: - Public API

extension SSProbDist {
    /// Alternative implementation of the noncentral t-distribution that
    /// avoids Float80/Accelerate and works across architectures.
    public enum NonCentralT {
        // MARK: Parameters (mean, variance, skewness, kurtosis)
        /// Returns parameters of the noncentral Student's t.
        /// - Parameters:
        ///   - df: Degrees of freedom (> 0)
        ///   - lambda: Noncentrality parameter
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT,
                                                                nonCentralityPara lambda: FPT) throws -> SSProbDistParams<FPT> {
            var result = SSProbDistParams<FPT>()
            if df <= 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                return try SSProbDist.StudentT.para(degreesOfFreedom: df)
            }
            // Formulas using gamma and pochhammer follow the existing implementation style
            let half: FPT = FPT.half
            let one: FPT = FPT.one
            let two: FPT = Helpers.makeFP(2)
            let three: FPT = Helpers.makeFP(3)
            let four: FPT = Helpers.makeFP(4)
            let minusThree: FPT = FPT.minusOne * three
            let df_half: FPT = df / two
            let df_half_m1: FPT = (df - one) / two
            let lg_df_half: FPT = SSMath.lgamma1(df_half)
            let lg_df_half_m1: FPT = SSMath.lgamma1(df_half_m1)
            let lambda_sq: FPT = lambda * lambda
            if df > 2 {
                let a: FPT = ((lambda_sq + one) * df)
                let b: FPT = (lambda_sq * df * SSMath.exp1(lg_df_half_m1 + lg_df_half_m1))
                let c: FPT = (two * SSMath.exp1(lg_df_half + lg_df_half))
                result.variance = a / (df - two) - b / c
            } else {
                result.variance = 0
            }
            result.mean = lambda * df_half.squareRoot() * SSMath.exp1(lg_df_half_m1 - lg_df_half)
            if df > 3 {
                var ex1 = SSMath.pow1(lambda, three)
                var ex2 = ex1 * SSMath.pow1(df, three * FPT.half)
                var ex3 = FPT.half * (FPT.minusOne + df)
                let ex4 = SSMath.tgamma1(ex3)
                let a: FPT = ex2 * SSMath.pow1(ex4, three)
                let b: FPT = two.squareRoot() * SSMath.pow1(SSMath.tgamma1(df_half), three)
                ex1 = three * lambda
                ex2 = ex1 * (one + SSMath.pow1(lambda, two))
                ex3 = ex2 * SSMath.pow1(df, three * half)
                let c: FPT = ex3 * SSMath.tgamma1(half * (FPT.minusOne + df))
                ex1 = two * sqrt(two)
                ex2 = FPT.minusOne + df_half
                ex3 = ex1 * ex2
                let d: FPT = ex3 * SSMath.tgamma1(df_half)
                ex1 = three * lambda
                ex2 = ex1 * (SSMath.pow1(lambda, two) / three + one)
                ex3 = ex2 * SSMath.pow1(df, three * half)
                let e: FPT = ex3 * SSSpecialFunctions.pochhammer(x: df_half, n: minusThree * half)
                let f: FPT = two * two.squareRoot()
                ex1 = a / b
                ex2 = c / d
                ex3 = e / f
                let m3: FPT = ex1 - ex2 + ex3
                result.skewness = m3 / SSMath.pow1(result.variance, three * half)
            } else {
                result.skewness = FPT.nan
            }
            if df > 4 {
                let quarter: FPT = Helpers.makeFP(0.25)
                let g: FPT = quarter * df * df
                var ex1: FPT = 6 * SSMath.pow1(lambda, two)
                var ex2: FPT = three + ex1
                var ex3: FPT = ex2 + SSMath.pow1(lambda, four)
                let h = four * ex3
                ex1 = 8
                ex2 = ex1 - 6 * df
                ex3 = ex2 + df * df
                let i: FPT = ex3
                let j_1: FPT = SSMath.pow1(four, -df)
                ex1 = minusThree * SSMath.pow1(four, df)
                ex2 = ex1 * SSMath.pow1(lambda, four)
                ex3 = SSMath.tgamma1((-1 + df) / two)
                let j_2: FPT = ex2 * SSMath.pow1(ex3, four)
                ex1 = SSMath.pow1(lambda, two) * (-5 + df)
                ex2 = three + ex1
                let j3_1: FPT = ex2 - (three * df)
                let j3_2: FPT = FPT.pi * SSMath.tgamma1(-3 + df) * SSMath.tgamma1(-1 + df)
                let j_3: FPT = 64 * SSMath.pow1(lambda, two) * j3_1 * j3_2
                let j = j_1 * (j_2 + j_3)
                let k = SSMath.pow1(SSMath.tgamma1(df_half), four)
                let m4 = g * ((h / i) + (j / k))
                result.kurtosis = m4 / SSMath.pow1(result.variance, two)
            } else {
                result.kurtosis = FPT.nan
            }
            return result
        }

        // MARK: CDF
        /// Returns the CDF of the noncentral Student's t-distribution.
        /// Computed via a numerically-stable one-dimensional integral over a transformed
        /// chi-square density. Works in Double and returns the generic type.
        public static func cdf<FPT: SSFloatingPoint & Codable>(t: FPT,
                                                               degreesOfFreedom df: FPT,
                                                               nonCentralityPara lambda: FPT,
                                                               rlog: Bool = false) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            // Fast path: lambda == 0 -> central t
            if lambda.isZero {
                let val = try SSProbDist.StudentT.cdf(t: t, degreesOfFreedom: df)
                return rlog ? SSMath.log1(val) : val
            }
            // Convert to Double and compute
            let tt = toDouble(t)
            let nu = toDouble(df)
            let del = toDouble(lambda)
            if tt.isNaN || nu.isNaN || del.isNaN { return FPT.nan }
            let res = nctCDF_Double(t: tt, nu: nu, lambda: del)
            if rlog { return Helpers.makeFP(log(res)) }
            return Helpers.makeFP(res)
        }

        // MARK: PDF
        /// Returns the PDF of the noncentral Student's t-distribution.
        /// Computed as derivative of the CDF integral: a single stable integral in Double.
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT,
                                                               degreesOfFreedom df: FPT,
                                                               nonCentralityPara lambda: FPT,
                                                               rlog: Bool = false) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                // central t pdf
                let central = try SSProbDist.StudentT.pdf(t: x, degreesOfFreedom: df, rlog: rlog)
                return central
            }
            let xx = toDouble(x)
            let nu = toDouble(df)
            let del = toDouble(lambda)
            if xx.isNaN || nu.isNaN || del.isNaN { return FPT.nan }
            let val = nctPDF_Double(t: xx, nu: nu, lambda: del)
            if rlog { return Helpers.makeFP(log(val)) }
            return Helpers.makeFP(val)
        }

        // MARK: Quantile
        /// Returns the quantile (inverse CDF) of the noncentral Student's t-distribution.
        /// Uses bisection with robust bracketing and the Double-based CDF.
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT,
                                                                    degreesOfFreedom df: FPT,
                                                                    nonCentralityPara lambda: FPT,
                                                                    rlog: Bool = false) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            // Interpret p possibly in log space
            let pp: FPT = Helpers.r_dt_qIv(x: p, tail: .lower, log_p: rlog)
            if let bound = Helpers.r_q_p01_boundaries(p: pp, left: -FPT.infinity, right: FPT.infinity) {
                return bound
            }
            if lambda.isZero {
                return try SSProbDist.StudentT.quantile(p: pp, degreesOfFreedom: df)
            }
            let nu = toDouble(df), del = toDouble(lambda), prob = toDouble(pp)
            if nu.isNaN || del.isNaN || prob.isNaN { return FPT.nan }
            let x = nctQuantile_Double(p: prob, nu: nu, lambda: del)
            return Helpers.makeFP(x)
        }
    }
}

// MARK: - Double-based core implementations

fileprivate func toDouble<T: SSFloatingPoint>(_ x: T) -> Double {
    switch x {
    case let d as Double: return d
    case let f as Float: return Double(f)
    #if arch(x86_64)
    case let f80 as Float80: return Double(f80)
    #endif
    default: return Double.nan
    }
}

fileprivate func normalCDF(_ z: Double) -> Double {
    // 0.5 * erfc(-z / sqrt(2))
    return 0.5 * erfc(-z / sqrt(2.0))
}

fileprivate func normalPDF(_ z: Double) -> Double {
    // exp(-z^2/2) / sqrt(2*pi)
    return exp(-0.5 * z * z) / sqrt(2.0 * Double.pi)
}

// Adaptive Simpson integration on [a, b]
fileprivate func adaptiveSimpson(_ f: (Double) -> Double,
                                 _ a: Double,
                                 _ b: Double,
                                 _ eps: Double = 1e-10,
                                 _ maxDepth: Int = 14) -> Double {
    func simpson(_ fa: Double, _ fm: Double, _ fb: Double, _ a: Double, _ b: Double) -> Double {
        return (b - a) * (fa + 4*fm + fb) / 6.0
    }
    func recurse(_ a: Double, _ b: Double, _ fa: Double, _ fm: Double, _ fb: Double, _ S: Double, _ depth: Int) -> Double {
        let m = 0.5 * (a + b)
        let lm = 0.5 * (a + m)
        let rm = 0.5 * (m + b)
        let flm = f(lm)
        let frm = f(rm)
        let Sleft = simpson(fa, flm, fm, a, m)
        let Sright = simpson(fm, frm, fb, m, b)
        let S2 = Sleft + Sright
        if depth <= 0 || abs(S2 - S) <= 15.0 * eps { // error estimate
            return S2 + (S2 - S) / 15.0
        }
        return recurse(a, m, fa, flm, fm, Sleft, depth - 1) + recurse(m, b, fm, frm, fb, Sright, depth - 1)
    }
    let fa = f(a)
    let m = 0.5 * (a + b)
    let fm = f(m)
    let fb = f(b)
    let S0 = (b - a) * (fa + 4*fm + fb) / 6.0
    return recurse(a, b, fa, fm, fb, S0, maxDepth)
}

// Transform v in [0,∞) to s in [0,1): v = s/(1-s), Jacobian = 1/(1-s)^2
fileprivate func nctCDF_Double(t: Double, nu: Double, lambda: Double) -> Double {
    if !nu.isFinite || nu > 1e8 {
        // Limit ν → ∞: T ~ N(mean=lambda, sd=1)
        return normalCDF(t - lambda)
    }
    if t.isInfinite {
        return t < 0 ? 0.0 : 1.0
    }
    // Symmetry: F(t; ν, λ) = 1 - F(-t; ν, -λ)
    if t < 0 {
        return 1.0 - nctCDF_Double(t: -t, nu: nu, lambda: -lambda)
    }
    let a = 0.0
    let b = 1.0 - 1e-12
    let c0 = -0.5 * nu * log(2.0) - lgamma(nu / 2.0) // log normalization of chi-square pdf
    func integrand(_ s: Double) -> Double {
        if s <= 0.0 { return 0.0 }
        let oneMinus = 1.0 - s
        let v = s / oneMinus
        let z = t * sqrt(v / nu) - lambda
        // Normal CDF factor
        let Phi = normalCDF(z)
        // chi-square pdf in log domain with Jacobian
        let logf = (nu / 2.0 - 1.0) * log(v) - v / 2.0 + c0 - 2.0 * log(oneMinus)
        let f = exp(logf)
        return Phi * f
    }
    // Integrate with adaptive Simpson
    let val = adaptiveSimpson(integrand, a, b, 1e-10, 14)
    // Clamp to [0,1]
    if val <= 0 { return 0.0 }
    if val >= 1 { return 1.0 }
    return val
}

fileprivate func nctPDF_Double(t: Double, nu: Double, lambda: Double) -> Double {
    if !nu.isFinite || nu > 1e8 {
        // Limit ν → ∞: Normal(mean=lambda, sd=1)
        return normalPDF(t - lambda)
    }
    // Symmetry: f(t; ν, λ) = f(-t; ν, -λ)
    let signFlip = t < 0
    let tt = signFlip ? -t : t
    let ll = signFlip ? -lambda : lambda
    let a = 0.0
    let b = 1.0 - 1e-12
    let c0 = -0.5 * nu * log(2.0) - lgamma(nu / 2.0) // log normalization of chi-square pdf
    func integrand(_ s: Double) -> Double {
        if s <= 0.0 { return 0.0 }
        let oneMinus = 1.0 - s
        let v = s / oneMinus
        let sqrtvnu = sqrt(v / nu)
        let z = tt * sqrtvnu - ll
        // derivative wrt t of Phi(z) is phi(z) * sqrt(v/nu)
        let phi = normalPDF(z) * sqrtvnu
        let logf = (nu / 2.0 - 1.0) * log(v) - v / 2.0 + c0 - 2.0 * log(oneMinus)
        let f = exp(logf)
        return phi * f
    }
    let val = adaptiveSimpson(integrand, a, b, 1e-10, 14)
    return max(0.0, val)
}

fileprivate func nctQuantile_Double(p: Double, nu: Double, lambda: Double) -> Double {
    if p <= 0 { return -Double.infinity }
    if p >= 1 { return Double.infinity }
    if !nu.isFinite || nu > 1e8 {
        // Normal limit
        // Use inverse error function via Gaussian.quantile implementation if desired; here standard approx:
        // For simplicity, use inverse CDF of standard normal with mean=lambda, sd=1
        // Using erfc^-1 would need additional code; do simple bisection around mean.
    }
    // Bracket
    var lo = -max(1.0, abs(lambda) + 1.0)
    var hi = max(1.0, abs(lambda) + 1.0)
    // Expand hi until CDF(hi) >= p
    var fhi = nctCDF_Double(t: hi, nu: nu, lambda: lambda)
    var flo = nctCDF_Double(t: lo, nu: nu, lambda: lambda)
    var it = 0
    while fhi < p && hi < 1e8 && it < 60 {
        hi *= 2.0
        fhi = nctCDF_Double(t: hi, nu: nu, lambda: lambda)
        it += 1
    }
    it = 0
    while flo > p && lo > -1e8 && it < 60 {
        lo *= 2.0
        flo = nctCDF_Double(t: lo, nu: nu, lambda: lambda)
        it += 1
    }
    // Bisection
    var mid = 0.0
    for _ in 0..<120 {
        mid = 0.5 * (lo + hi)
        let fm = nctCDF_Double(t: mid, nu: nu, lambda: lambda)
        if fm > p {
            hi = mid
        } else {
            lo = mid
        }
        if abs(hi - lo) <= 1e-12 * max(1.0, abs(mid)) { break }
    }
    return 0.5 * (lo + hi)
}
