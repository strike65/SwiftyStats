//
//  Created by VT on 20.07.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
/*
 Copyright (c) 2017 Volker Thieme
 
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
#if os(macOS) || os(iOS)
import os.log
#endif

// MARK: STUDENT's T

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Student's T distribution.
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func paraStudentT(degreesOfFreedom df: Double!) throws -> SSContProbDistParams {
    var result = SSContProbDistParams()
    if df < 0.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = 0.0
    if df > 2 {
        result.variance = df / (df - 2.0)
    }
    else {
        result.variance = 0.0
    }
    result.skewness = 0.0
    if df > 4 {
        result.kurtosis = 3.0 + 6.0 / (df - 4.0)
    }
    else {
        result.kurtosis = Double.nan
    }
    return result
}

/// Returns the pdf of Student's t-distribution
/// - Parameter t: t
/// - Parameter df: Degrees of freedom
/// - Parameter rlog: Return log(T_PDF(t, df))
/// - Throws: SSSwiftyStatsError if df <= 0
public func pdfStudentTDist(t: Double!, degreesOfFreedom df: Double!, rlog: Bool! = false) throws -> Double {
    if df < 0.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let lpdf = lgamma( 0.5 * ( df + 1.0 ) ) - 0.5 * log( df * Double.pi ) - lgamma( 0.5 * df ) - ( ( df + 1.0 ) / 2.0 * log( 1.0 + t * t / df ) )
    if rlog {
        return lpdf
    }
    else {
        return exp(lpdf)
    }
}

/// Returns the cdf of Student's t-distribution
/// - Parameter t: t
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func cdfStudentTDist(t: Double!, degreesOfFreedom df: Double!) throws -> Double {
    if df < 0.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var correctedDoF: Double
    var halfDoF: Double
    var constant: Double
    var result: Double
    halfDoF = df / 2.0
    correctedDoF = df / ( df + ( t * t ) )
    constant = 0.5
    let t1 = betaNormalized(x: 1.0, a: halfDoF, b: constant)
    let t2 = betaNormalized(x: correctedDoF, a: halfDoF, b: constant)
    result = 0.5 * (1.0 + (t1 - t2) * t.sgn)
    return result
}

/// Returns the quantile function of Student's t-distribution
///  adapted from: http://rapidq.phatcode.net/examples/Math
/// - Parameter p: p
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0 or/and p < 0 or p > 1.0
///
/// ### Note ###
/// Bisection
public func quantileStudentTDist(p: Double!, degreesOfFreedom df: Double!) throws -> Double {
    if df < 0.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0.0 || p > 1.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    /* adapted from: http://rapidq.phatcode.net/examples/Math/ProbDists.rqb
     * coded in C by Gary Perlman
     * coded in Basic by Michaek Zito 2003
     * coded in C# by Volker Thieme 2005
     */
    let eps: Double = 1E-15
    if fabs( p - 1.0 ) <= 1E-5  {
        return Double.infinity
    }
    if fabs(p) <= 1E-5 {
        return -Double.infinity
    }
    if fabs(p - 0.5) <= eps {
        return 0.0
    }
    var minT: Double
    var maxT: Double
    var result: Double
    var tVal: Double
    var b1: Bool = false
    var pp: Double
    var _p: Double
    if p < 0.5 {
        _p = 1.0 - p
        b1 = true
    }
    else {
        _p = p
    }
    minT = 0.0
    //        maxT = sqrt(params.variance) * 20
    maxT = 100000.0
    tVal = (maxT + minT) / 2.0
    while (maxT - minT > (4.0 * eps)) {
        do {
            pp = try cdfStudentTDist(t: tVal, degreesOfFreedom: df)
        }
        catch {
            return Double.nan
        }
        if pp > _p {
            maxT = tVal
        }
        else {
            minT = tVal
        }
        tVal = (maxT + minT) * 0.5
    }
    result = tVal
    if b1 {
        result = result * -1.0
    }
    return result
}


// MARK: NON-CENTRAL T-DISTRIBUTION

/*  Algorithm AS 243  Lenth,R.V. (1989). Appl. Statist., Vol.38, 185-189.
 *  ----------------
 *  Cumulative probability at t of the non-central t-distribution
 *  with df degrees of freedom (may be fractional) and non-centrality
 *  parameter delta.
 *
 *  NOTE
 *
 *    Requires the following auxiliary routines:
 *
 *    lgammafn(x)    - log gamma function
 *    pbeta(x, a, b)    - incomplete beta function
 *    pnorm(x)    - normal distribution function
 *
 *  CONSTANTS
 *
 *    M_SQRT_2dPI  = 1/ {gamma(1.5) * sqrt(2)} = sqrt(2 / pi)
 *    M_LN_SQRT_PI = ln(sqrt(pi)) = ln(pi)/2
 */

/// Returns the lower tail cdf of the non-central Student's t-distribution
/// - Parameter t: t
/// - Parameter nonCentralityPara: noncentrality parameter
/// - Parameter df: Degrees of freedom
/// - Parameter rlog: Return log(cdf)
/// - Throws: SSSwiftyStatsError if df <= 0
///
/// ### NOTE ###
/// This routine is based on a C-version of: Algorithm AS243 Lenth,R.V. (1989). Appl. Statist., Vol.38, 185-189.
/// For ncp > 37 the accuracy decreases. Use with caution. The same algorithm is used by R.
/// This algorithm suffers from limited accuracy in the (very) left tail and for ncp > 38.
public func cdfStudentTNonCentral(t: Double!, nonCentralityPara ncp: Double!, degreesOfFreedom df: Double!, rlog: Bool! = false) throws -> Double {
    let tail: SSCDFTail = .lower
    var albeta, a, b, del, errbd, lambda, rxb, tt, x: Double
    #if arch(arm) || arch(arm64)
    var geven, godd, p, q, s, tnc, xeven, xodd: Double
    #else
    var geven, godd, p, q, s, tnc, xeven, xodd: Float80
    #endif
    var it: Int
    var negdel: Bool
    
    let itrmax = 1000
    let errmax = 1E-12
    if df <= 0.0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if ncp.isZero {
        do {
            return try cdfStudentTDist(t: t, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
    }
    if t.isInfinite {
        if t < 0 {
            return r_dt_0(tail: tail, log_p: rlog)
        }
        else {
            return r_dt_1(tail: tail, log_p: rlog)
        }
    }
    if t >= 0.0 {
        negdel = false
        tt = t
        del = ncp
    }
    else {
        if ncp > 40 && (!rlog || tail == .upper) {
            return r_dt_0(tail: tail, log_p: rlog)
        }
        negdel = true
        tt = -t
        del = -ncp
    }
    if df > 4.0E5 || (del * del) > (2.0 * LOG2 * ( -(Double(Double.leastNormalMagnitude.exponent) + 1.0 ))) {
        /*-- 2nd part: if del > 37.62, then p=0 below
         FIXME: test should depend on `df', `tt' AND `del' ! */
        /* Approx. from     Abramowitz & Stegun 26.7.10 (p.949) */
        #if arch(arm) || arch(arm64)
        s = 1.0 / (4.0 * df)
        let x = tt * (1.0 - s)
        let s1 = 1.0 + tt * tt * 2.0 * s
        let sigma = sqrt(s1)
        #else
        s = 1.0 / (4.0 * Float80(df))
        let x = Float80(tt) * (1.0 - s)
        let s1 = 1.0 + Float80(tt) * Float80(tt) * 2.0 * s
        let sigma = sqrt(s1)
        #endif
        do {
            return try pdfNormalDist(x: Double(x), mean: del, standardDeviation: Double(sigma))
        }
        catch {
            throw error
        }
    }
    /* Guenther, J. (1978). Statist. Computn. Simuln. vol.6, 199. */
    x = t * t
    rxb = df / (x + df) /* := (1 - x) {x below} -- but more accurately */
    x = x / (x + df)    /* in [0,1) */
    if (x > 0.0) {
        lambda = del * del
        #if arch(arm) || arch(arm64)
        p = 0.5 * exp(-0.5 * lambda)
        #else
        p = 0.5 * Float80(exp(-0.5 * lambda))
        #endif
        if(p == 0.0) { /* underflow! */
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 10, *) {
            os_log("Error evaluating noncentral t distribution: non-centrality parameter too large", log: log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        #if arch(arm) || arch(arm64)
        q = SQRT2DIVPI * p * del
        s = 0.5 - p
        if(s < 1E-7) {
            s = -0.5 * expm1(-0.5 * lambda)
        }
        #else
        q = SQRT2DIVPIL * p * Float80(del)
        s = 0.5 - p
        if(s < 1e-7) {
            s = -0.5 * Float80(expm1(-0.5 * lambda))
        }
        #endif
        a = 0.5
        b = 0.5 * df;
        rxb = pow(rxb, b)
        albeta = LNSQRTPI + lgamma(b) - lgamma(0.5 + b)
        // FIXME: CHECK CORRECT TAIL
        #if arch(arm) || arch(arm64)
        do {
            xodd = try cdfBetaDist(x: x, shapeA: a, shapeB: b)
            godd = 2.0 * rxb * exp(a * log(x) - albeta)
            tnc = b * x;
            xeven = (tnc < Double.ulpOfOne) ? tnc : 1.0 - rxb
            geven = tnc * rxb
        }
        catch {
            throw error
        }
        #else
        do {
            xodd = Float80(try cdfBetaDist(x: x, shapeA: a, shapeB: b))
            godd = 2.0 * Float80(rxb) * Float80(exp(a * log(x) - albeta))
            tnc = Float80(b) * Float80(x)
            xeven = (tnc < Float80.ulpOfOne) ? tnc : 1.0 - Float80(rxb)
            geven = tnc * Float80(rxb)
        }
        catch {
            throw error
        }
        #endif
        tnc = p * xodd + q * xeven;
        /* repeat until convergence or iteration limit */
        it = 1
        for _ in stride(from: 1, through: itrmax, by: 1) {
            #if arch(arm) || arch(arm64)
            a += 1.0
            xodd  -= godd
            xeven -= geven
            godd  *= x * (a + b - 1.0) / a
            geven *= x * (a + b - 0.5) / (a + 0.5)
            p *= lambda / (2.0 * Double(it));
            q *= lambda / (2.0 * Double(it) + 1.0)
            tnc += p * xodd + q * xeven
            s -= p
            /* R 2.4.0 added test for rounding error here. */
            if(s < -1.0E-10) { /* happens e.g. for (t,df,ncp)=(40,10,38.5), after 799 it.*/
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("Error evaluating noncentral t distribution: non-convergence", log: log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if(s <= 0 && it > 1) {
                break
            }
            errbd = Double(2.0 * s * (xodd - godd))
            if(fabs(errbd) < errmax) { /*convergence*/
                break
            }
            #else
            a += 1.0
            xodd  -= godd
            xeven -= geven
            godd  *= Float80(x) * (Float80(a) + Float80(b) - 1.0) / Float80(a)
            geven *= Float80(x) * (Float80(a) + Float80(b) - 0.5) / (Float80(a) + 0.5)
            p *= Float80(lambda) / (2.0 * Float80(it));
            q *= Float80(lambda) / (2.0 * Float80(it) + 1.0)
            tnc += p * xodd + q * xeven
            s -= p
            /* R 2.4.0 added test for rounding error here. */
            if(s < -1.0E-10) { /* happens e.g. for (t,df,ncp)=(40,10,38.5), after 799 it.*/
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("Error evaluating noncentral t distribution: non-convergence", log: log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if(s <= 0 && it > 1) {
                break
            }
            errbd = Double(2.0 * s * (xodd - godd))
            if(fabs(errbd) < errmax) { /*convergence*/
                break
            }
            #endif
            it = it + 1
        }
        if it >= itrmax {
            /* non-convergence:*/
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 10, *) {
                os_log("Error evaluating noncentral t distribution: non-convergence", log: log_stat, type: .error)
            }
            #else
            print("Error evaluating noncentral t distribution: non-convergence")
            #endif
        }
    }
    else { /* x = t = 0 */
        tnc = 0.0
    }
    #if arch(arm) || arch(arm64)
    do {
        // FIXME: CHECK TAIL
        let r = try cdfNormalDist(x: -del, mean: 0.0, standardDeviation: 1.0)
        tnc = tnc + r
    }
    catch {
        throw error
    }
    #else
    do {
        // FIXME: CHECK TAIL
        let r = Float80(try cdfNormalDist(x: -del, mean: 0.0, standardDeviation: 1.0))
        tnc = tnc + r
    }
    catch {
        throw error
    }
    #endif
    var lower_tail: Bool = tail == .lower ? true : false
    lower_tail = lower_tail != negdel; /* xor */
    if(tnc > 1 - 1E-10 && lower_tail) {
//        ML_ERROR(ME_PRECISION, "pnt{final}");
        print("final!")
    }
    if tnc.isNaN {
        return Double.nan
    }
    else {
        return r_dt_val(x: fmin(Double(tnc), 1.0), tail: lower_tail ? .lower : .upper, log_p: rlog)
    }
}

/* ORIGINAL AUTHOR
 *    Claus Ekström, ekstrom@dina.kvl.dk
 *    July 15, 2003.
 * Swift Version:
 *    Volker Thieme
 *    June 21, 2018
 *
 *    Copyright (C) 2003-2015 The R Foundation
 *
 * DESCRIPTION
 *
 *    From Johnson, Kotz and Balakrishnan (1995) [2nd ed.; formula (31.15), p.516],
 *    the non-central t density is
 *
 *      f(x, df, ncp) =
 *
 *        exp(-.5*ncp^2) * gamma((df+1)/2) / (sqrt(pi*df)* gamma(df/2)) * (df/(df+x^2))^((df+1)/2) *
 *          sum_{j=0}^Inf  gamma((df+j+1)/2)/(factorial(j)* gamma((df+1)/2)) * (x*ncp*sqrt(2)/sqrt(df+x^2))^ j
 *
 *
 *    The functional relationship
 *
 *       f(x, df, ncp) = df/x *
 *                  (F(sqrt((df+2)/df)*x, df+2, ncp) - F(x, df, ncp))
 *
 *    is used to evaluate the density at x != 0 and
 *
 *       f(0, df, ncp) = exp(-.5*ncp^2) /
 *                (sqrt(pi)*sqrt(df)*gamma(df/2))*gamma((df+1)/2)
 *
 *    is used for x=0.
 *
 *    All calculations are done on log-scale to increase stability.
 *
 * FIXME: pnt() is known to be inaccurate in the (very) left tail and for ncp > 38
 *       ==> use a direct log-space summation formula in that case
 */

/// Returns the lower tail cdf of the non-central Student's t-distribution
/// - Parameter x: x
/// - Parameter nonCentralityPara: noncentrality parameter
/// - Parameter df: Degrees of freedom
/// - Parameter rlog: Return log(pdf)
/// - Throws: SSSwiftyStatsError if df <= 0
///
/// ### NOTE ###
/// This routine is based on a C-version of: Algorithm AS243 Lenth,R.V. (1989). Appl. Statist., Vol.38, 185-189.
/// For ncp > 37 the accuracy decreases. Use with caution. The same algorithm is used by R.
public func pdfStudentTNonCentral(x: Double!, nonCentralityPara ncp: Double!, degreesOfFreedom df: Double!, rlog: Bool! = false) throws -> Double {
    if df <= 0.0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var u: Double = 0.0
    if x.isNaN || df.isNaN || ncp.isNaN {
        return Double.nan
    }
    if ncp == 0 {
        do {
            return try pdfStudentTDist(t: x, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
    }
    if x.isInfinite {
        return 0
    }
    if df >= 1E8 || df.isInfinite {
        do {
            return try pdfNormalDist(x: x, mean: ncp, standardDeviation: 1.0)
        }
        catch {
            throw error
        }
    }
    
    if fabs(x) > sqrt(df * Double.ulpOfOne) {
        do {
            let p1 = try cdfStudentTNonCentral(t: x * sqrt((df + 2.0) / df), nonCentralityPara: ncp, degreesOfFreedom: df + 2.0)
            let p2 = try cdfStudentTNonCentral(t: x, nonCentralityPara: ncp, degreesOfFreedom: df)
            u = log(df) - log(fabs(x)) + log(fabs(p1 - p2))
        }
        catch {
            throw error
        }
    }
    else {
        u = lgamma((df + 1.0) / 2.0) - lgamma(df / 2.0) - (LNSQRTPI + 0.5 * (log(df) + ncp * ncp))
    }
    return (rlog ? u : exp(u))
}


/// Returns the quantile function of the noncentral Student's t-distribution
/// - Parameter p: p
/// - Parameter nonCentralityPara: noncentrality parameter
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0 or/and p < 0 or p > 1.0
public func quantileStudentTNonCentral(p: Double!, degreesOfFreedom df: Double!, nonCentralityPara ncp: Double!, rlog: Bool! = false) throws -> Double {
   let accu: Double = 1E-13
    let eps: Double = 1E-11
    var ux, lx, nx, pp: Double
    if df.isNaN || p.isNaN || ncp.isNaN {
        return Double.nan
    }
    if df <= 0.0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if ncp.isZero {
        do {
            return try quantileStudentTDist(p: p, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
    }
    if p < 0.0 || p > 1.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if let test = r_q_p01_boundaries(p: p, left: -Double.infinity, right: Double.infinity) {
        return test
    }
    if df.isInfinite {
        do {
            return try quantileNormalDist(p: p, mean: ncp, standardDeviation: 1.0)
        }
        catch {
            throw error
        }
    }
    let p0 = r_dt_qIv(x: p, tail: .lower, log_p: rlog)
    if p0 > (1.0 - Double.ulpOfOne) {
        return Double.infinity
    }
    if p0 < Double.leastNonzeroMagnitude {
        return -Double.infinity
    }
    func q(t:Double!, ncp: Double!, df:Double!) -> Double! {
        do {
            return try cdfStudentTNonCentral(t: t, nonCentralityPara: ncp, degreesOfFreedom: df)
        }
        catch {
            return Double.nan
        }
    }
    pp = fmin(1.0 - Double.ulpOfOne, p0 * (1.0 + eps))
    ux = fmax(1.0, ncp)
//    var q: Double = try cdfStudentTNonCentral(t: ux, nonCentralityPara: ncp, degreesOfFreedom: df)
    while (ux < Double.greatestFiniteMagnitude) && (q(t: ux, ncp: ncp, df: df) < pp) {
        ux = 2.0 * ux
    }

    pp = p0 * (1.0 - eps)

    lx = fmin(-1.0, -ncp)
    while ((lx > -Double.greatestFiniteMagnitude) && (q(t: lx, ncp: ncp, df: df) > pp)) {
        lx = 2.0 * lx
    }
    repeat {
        nx = 0.5 * (lx + ux)
        if try cdfStudentTNonCentral(t: nx, nonCentralityPara: ncp, degreesOfFreedom: df) > p {
            ux = nx
        }
        else {
            lx = nx
        }
    } while ((ux - lx) > accu * fmax(fabs(lx), fabs(ux)))
    return 0.5 * (lx + ux)
}

