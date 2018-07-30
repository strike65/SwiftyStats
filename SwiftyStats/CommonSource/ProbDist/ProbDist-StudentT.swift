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
public func paraStudentTDist(degreesOfFreedom df: Double!) throws -> SSContProbDistParams {
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


/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the noncentral Student's T distribution.
/// - Parameter df: Degrees of freedom
/// - Parameter nonCentralityPara: noncentrality parameter
/// - Throws: SSSwiftyStatsError if df <= 0
public func paraStudentTDist(degreesOfFreedom df: Double!, nonCentralityPara lambda: Double!) throws -> SSContProbDistParams {
    var result = SSContProbDistParams()
    if df < 0.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if lambda.isZero {
        do {
            return try paraStudentTDist(degreesOfFreedom: df)
        }
        catch {
            throw error
        }
    }
    let df_half = df / 2.0
    let df_half_m1 = (df - 1.0) / 2.0
    let lg_df_half: Double = lgamma(df_half)
    let lg_df_half_m1: Double = lgamma(df_half_m1)
    let lambda_sq = lambda * lambda
    if df > 2 {
        result.variance = ((lambda_sq + 1.0) * df) / (df - 2.0) - (lambda_sq * df * exp(lg_df_half_m1 + lg_df_half_m1)) / (2.0 * exp(lg_df_half + lg_df_half))
    }
    else {
        result.variance = 0.0
    }
    result.mean = lambda * sqrt(df_half) * exp(lg_df_half_m1 - lg_df_half)
    if df > 3 {
        let a: Double = pow(lambda, 3) * pow(df, 1.5) * pow((0.5 * (-1.0 + df)).gammaValue, 3.0)
        let b: Double = SQRTTWO * pow(df_half.gammaValue, 3.0)
        let c: Double = 3.0 * lambda * (1 + pow(lambda, 2.0)) * pow(df, 1.5) * (0.5 * (-1.0 + df)).gammaValue
        let d: Double = 2.0 * SQRTTWO * (-1.0 + df_half) * df_half.gammaValue
        let e: Double = 3.0 * lambda * (pow(lambda, 2) / 3.0 + 1.0) * pow(df, 1.5) * pochhammer(a: df_half, b: -1.5)
        let f: Double = 2.0 * SQRTTWO
        let m3: Double = (a / b) - (c / d) + (e / f)
        result.skewness = m3 / pow(result.variance, 1.5)
    }
    else {
        result.skewness = Double.nan
    }
    if df > 4.0 {
        
        let g:Double = 0.25 * df * df
        let h: Double = 4.0 * (3.0 + 6 * pow(lambda,2) + pow(lambda, 4))
        let i: Double = 8 - 6 * df + df * df
        let j_1: Double = pow(4, -df)
        let j_2: Double = -3 * pow(4, df) * pow(lambda, 4.0) * pow(((-1.0 + df) / 2).gammaValue, 4)
        let j_3: Double = 64.0 * pow(lambda, 2) * (3.0 + pow(lambda, 2) * (-5.0 + df) - 3.0 * df) * Double.pi * (-3.0 + df).gammaValue * (-1 + df).gammaValue
        let j = j_1 * (j_2 + j_3)
        let k = pow(df_half.gammaValue, 4.0)
        let m4 = g * ((h / i) + (j / k))
        result.kurtosis = m4 / pow(result.variance, 2.0)
    }
    else {
        result.kurtosis = Double.nan
    }
    return result
}




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
public func cdfStudentTDist(t: Double!, degreesOfFreedom df: Double!, nonCentralityPara lambda: Double!, rlog: Bool! = false) throws -> Double {
    let tail: SSCDFTail = .lower
    var albeta, a, b, del, errbd, lambda1, rxb, tt, x: Double
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
    if lambda.isZero {
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
        del = lambda
    }
    else {
        if lambda > 40 && (!rlog || tail == .upper) {
            return r_dt_0(tail: tail, log_p: rlog)
        }
        negdel = true
        tt = -t
        del = -lambda
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
            return try cdfNormalDist(x: Double(x), mean: del, standardDeviation: Double(sigma))
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
        lambda1 = del * del
        #if arch(arm) || arch(arm64)
        p = 0.5 * exp(-0.5 * lambda1)
        #else
        p = 0.5 * Float80(exp(-0.5 * lambda1))
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
            s = -0.5 * expm1(-0.5 * lambda1)
        }
        #else
        q = SQRT2DIVPIL * p * Float80(del)
        s = 0.5 - p
        if(s < 1e-7) {
            s = -0.5 * Float80(expm1(-0.5 * lambda1))
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
            p *= lambda1 / (2.0 * Double(it));
            q *= lambda1 / (2.0 * Double(it) + 1.0)
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
            p *= Float80(lambda1) / (2.0 * Float80(it));
            q *= Float80(lambda1) / (2.0 * Float80(it) + 1.0)
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
            printError("Error evaluating noncentral t distribution: non-convergence")
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
        printError("final!")
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
public func pdfStudentTDist(x: Double!, degreesOfFreedom df: Double!, nonCentralityPara lambda: Double!, rlog: Bool! = false) throws -> Double {
    if df <= 0.0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var u: Double = 0.0
    if x.isNaN || df.isNaN || lambda.isNaN {
        return Double.nan
    }
    if lambda == 0 {
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
            return try pdfNormalDist(x: x, mean: lambda, standardDeviation: 1.0)
        }
        catch {
            throw error
        }
    }
    
    if fabs(x) > sqrt(df * Double.ulpOfOne) {
        do {
            let p1 = try cdfStudentTDist(t: x * sqrt((df + 2.0) / df), degreesOfFreedom: df + 2.0, nonCentralityPara: lambda)
            let p2 = try cdfStudentTDist(t: x, degreesOfFreedom: df, nonCentralityPara: lambda)
            u = log(df) - log(fabs(x)) + log(fabs(p1 - p2))
        }
        catch {
            throw error
        }
    }
    else {
        u = lgamma((df + 1.0) / 2.0) - lgamma(df / 2.0) - (LNSQRTPI + 0.5 * (log(df) + lambda * lambda))
    }
    return (rlog ? u : exp(u))
}


/// Returns the quantile function of the noncentral Student's t-distribution
/// - Parameter p: p
/// - Parameter nonCentralityPara: noncentrality parameter
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0 or/and p < 0 or p > 1.0
public func quantileStudentTDist(p: Double!, degreesOfFreedom df: Double!, nonCentralityPara lambda: Double!, rlog: Bool! = false) throws -> Double {
   let accu: Double = 1E-13
    let eps: Double = 1E-11
    var ux, lx, nx, pp: Double
    if df.isNaN || p.isNaN || lambda.isNaN {
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
    if lambda.isZero {
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
            return try quantileNormalDist(p: p, mean: lambda, standardDeviation: 1.0)
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
            return try cdfStudentTDist(t: t, degreesOfFreedom: df, nonCentralityPara: ncp)
        }
        catch {
            return Double.nan
        }
    }
    pp = fmin(1.0 - Double.ulpOfOne, p0 * (1.0 + eps))
    ux = fmax(1.0, lambda)
//    var q: Double = try cdfStudentTNonCentral(t: ux, nonCentralityPara: ncp, degreesOfFreedom: df)
    while (ux < Double.greatestFiniteMagnitude) && (q(t: ux, ncp: lambda, df: df) < pp) {
        ux = 2.0 * ux
    }

    pp = p0 * (1.0 - eps)

    lx = fmin(-1.0, -lambda)
    while ((lx > -Double.greatestFiniteMagnitude) && (q(t: lx, ncp: lambda, df: df) > pp)) {
        lx = 2.0 * lx
    }
    repeat {
        nx = 0.5 * (lx + ux)
        if try cdfStudentTDist(t: nx, degreesOfFreedom: df, nonCentralityPara: lambda) > p {
            ux = nx
        }
        else {
            lx = nx
        }
    } while ((ux - lx) > accu * fmax(fabs(lx), fabs(ux)))
    return 0.5 * (lx + ux)
}

