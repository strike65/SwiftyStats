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
public func paraStudentTDist<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT) throws -> SSContProbDistParams<FPT> {
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    if df < 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = 0
    if df > 2 {
        result.variance = df / (df - 2)
    }
    else {
        result.variance = 0
    }
    result.skewness = 0
    if df > 4 {
        result.kurtosis = 3 + 6 / (df - 4)
    }
    else {
        result.kurtosis = FPT.nan
    }
    return result
}


/// Returns the pdf of Student's t-distribution
/// - Parameter t: t
/// - Parameter df: Degrees of freedom
/// - Parameter rlog: Return log(T_PDF(t, df))
/// - Throws: SSSwiftyStatsError if df <= 0
public func pdfStudentTDist<FPT: SSFloatingPoint & Codable>(t: FPT, degreesOfFreedom df: FPT, rlog: Bool! = false) throws -> FPT {
    if df < 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let half: FPT = FPT.half
    let expr: FPT = ( ( df + 1 ) / 2 * log1( 1 + t * t / df ) )
    let lpdf:FPT = lgamma1( half * ( df + 1 ) ) - half * log1( df * FPT.pi ) - lgamma1( half * df )  - expr
    if rlog {
        return lpdf
    }
    else {
        return exp1(lpdf)
    }
}

/// Returns the cdf of Student's t-distribution
/// - Parameter t: t
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func cdfStudentTDist<FPT: SSFloatingPoint & Codable>(t: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    if df < 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let half: FPT = FPT.half

    var correctedDoF: FPT
    var halfDoF: FPT
    var constant: FPT
    var result: FPT
    halfDoF = df / 2
    correctedDoF = df / ( df + ( t * t ) )
    constant = half
    let t1: FPT = betaNormalized(x: 1, a: halfDoF, b: constant)
    let t2: FPT = betaNormalized(x: correctedDoF, a: halfDoF, b: constant)
    result = half * (1 + (t1 - t2) * sign1(t))
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
public func quantileStudentTDist<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    if df < 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0 || p > 1 {
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
//    let eps: Double = 1E-15
    let half: FPT = FPT.half
    let eps: FPT = FPT.ulpOfOne
//    if fabs( p - 1.0 ) <= 1E-5  {
//        return FPT.infinity
//    }
//    if fabs(p) <= 1E-5 {
//        return -FPT.infinity
//    }
    if abs( p - 1 ) <= eps  {
        return FPT.infinity
    }
    if abs(p) <= eps {
        return -FPT.infinity
    }

    if abs(p - half) <= eps {
        return 0
    }
    var minT: FPT
    var maxT: FPT
    var result: FPT
    var tVal: FPT
    var b1: Bool = false
    var pp: FPT
    var _p: FPT
    if p < half {
        _p = 1 - p
        b1 = true
    }
    else {
        _p = p
    }
    minT = 0
    //        maxT = sqrt(params.variance) * 20
    maxT = 100000
    tVal = (maxT + minT) / 2
    while (maxT - minT > (4 * eps)) {
        do {
            pp = try cdfStudentTDist(t: tVal, degreesOfFreedom: df)
        }
        catch {
            return FPT.nan
        }
        if pp > _p {
            maxT = tVal
        }
        else {
            minT = tVal
        }
        tVal = (maxT + minT) * half
    }
    result = tVal
    if b1 {
        result = result * -1
    }
    return result
}


#if arch(i386) || arch(x86_64)

// MARK: NON-CENTRAL T-DISTRIBUTION


/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the noncentral Student's T distribution.
/// - Parameter df: Degrees of freedom
/// - Parameter nonCentralityPara: noncentrality parameter
/// - Throws: SSSwiftyStatsError if df <= 0
public func paraStudentTDist<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT, nonCentralityPara lambda: FPT) throws -> SSContProbDistParams<FPT> {

    var result:SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    if df < 0 {
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
    let half: FPT = FPT.half
    let one: FPT = 1
    let two: FPT = 2
    let three: FPT = 3
    let four: FPT = 4

    let df_half: FPT = df / two
    let df_half_m1: FPT = (df - one) / two
    let lg_df_half: FPT = lgamma1(df_half)
    let lg_df_half_m1: FPT = lgamma1(df_half_m1)
    let lambda_sq: FPT = lambda * lambda
    if df > 2 {
        let a: FPT = ((lambda_sq + one) * df)
        let b: FPT = (lambda_sq * df * exp1(lg_df_half_m1 + lg_df_half_m1))
        let c: FPT = (two * exp1(lg_df_half + lg_df_half))
        result.variance = a / (df - two) - b / c
    }
    else {
        result.variance = 0
    }
    result.mean = lambda * df_half.squareRoot() * exp1(lg_df_half_m1 - lg_df_half)
    if df > 3 {
        let a: FPT = pow1(lambda, three) * pow1(df, three * half) * pow1(tgamma1(half * (-1 + df)), three)
        let b: FPT = two.squareRoot() * pow1(tgamma1(df_half), three)
        let c: FPT = three * lambda * (one + pow1(lambda, two)) * pow1(df, three * half) * tgamma1(half * (-1 + df))
        let d: FPT = two * two.squareRoot() * (-1 + df_half) * tgamma1(df_half)
        let e: FPT = three * lambda * (pow1(lambda, two) / three + one) * pow1(df, three * half) * pochhammer(x: df_half, n: -3 * half)
        let f: FPT = two * two.squareRoot()
        let m3: FPT = (a / b) - (c / d) + (e / f)
        result.skewness = m3 / pow1(result.variance, three * half)
    }
    else {
        result.skewness = FPT.nan
    }
    if df > 4 {
        let quarter: FPT = makeFP(0.25)
        let g:FPT = quarter * df * df
        let h: FPT = four * (three + 6 * pow1(lambda, two) + pow1(lambda, four))
        let i: FPT = 8 - 6 * df + df * df
        let j_1: FPT = pow1(four, -df)
        let j_2: FPT = -3 * pow1(four, df) * pow1(lambda, four) * pow1(tgamma1((-1 + df) / two), four)
        let j3_1: FPT = (three + pow1(lambda, two) * (-5 + df) - three * df)
        let j3_2: FPT = FPT.pi * tgamma1(-3 + df) * tgamma1(-1 + df)
        let j_3: FPT = 64 * pow1(lambda, two) * j3_1 * j3_2
        let j = j_1 * (j_2 + j_3)
        let k = pow1(tgamma1(df_half), four)
        let m4 = g * ((h / i) + (j / k))
        result.kurtosis = m4 / pow1(result.variance, two)
    }
    else {
        result.kurtosis = FPT.nan
    }
    return result
}

private func integrand<FPT: SSFloatingPoint & Codable>(t: FPT, df: FPT, ncp: FPT, p0: FPT, p1: FPT) -> FPT {
    return try! pdfStudentTDist(x: t, degreesOfFreedom: df, nonCentralityPara: ncp )
}



internal func infSum<FPT: SSFloatingPoint & Codable>(x: FPT, df: FPT, lambda: FPT, epsilon: FPT = FPT.ulpOfOne, maxiter: Int = 1000) -> FPT {
    var xx: Float80 = makeFP(x)
    var dff: Float80 = makeFP(df)
    var sum: Float80 = 0
    var del: Float80 = makeFP(lambda)
    var eps: Float80 = makeFP(epsilon)
    if xx < 0 {
        del = -del
    }
    let y: Float80 = pow1(xx,2) / (pow1(xx,2) + dff)
    let la_sq_div_2: Float80 = pow1(del, 2) / 2
    let f1: Float80 = exp1(-la_sq_div_2)
    
    func p(j: Int) -> Float80 {
        let f: Float80 = -logFactorial(j) - la_sq_div_2 + makeFP(j) * log1(la_sq_div_2)
        return exp1(f)
    }
    func q(j: Int) -> Float80 {
        let f: Float80 = del / (Float80.sqrt2 * tgamma1(makeFP(j) + 1.5))
        let f2: Float80 = exp1(-la_sq_div_2) * pow1(la_sq_div_2, makeFP(j))
        return f * f2
    }
    var iBeta1: Float80 = 0
    var iBeta2: Float80 = 0
    var s1: Float80 = 0
    var s2: Float80 = 0
    var j: Int = 0
    var a1: Float80 = 0
    var a2: Float80 = 0
    let df_half: Float80 = dff / 2
    var jf: Float80
    var temp: Float80 = 0
    var pp: Float80 = 0
    var qq: Float80 = 0
    while (j <= maxiter) {
        jf = makeFP(j)
        a1 = jf + 0.5
        a2 = jf + 1
        iBeta1 = betaNormalized(x: y, a: a1, b: df_half)
        pp = p(j: j)
        s1 = pp * iBeta1
        iBeta2 = betaNormalized(x: y, a: a2, b: df_half)
        qq = q(j: j)
        s2 = qq * iBeta2
        temp = s1 + s2
        if temp <= eps && j > 20 || temp.isNaN{
            break
        }
        sum += temp
        j += 1
    }
    let u: Float80 = cdfStandardNormalDist(u: -del)
    let result: Float80 = u + 0.5 * sum
    if xx < 0 {
        return makeFP(1 - result)
    }
    else {
        return makeFP(result)
    }
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

/// Returns the cdf of the noncentral Student t distribution.
/// - Parameter x: x
/// - Parameter df: degrees of freedom
/// - Parameter ncp: noncentrality parameter
/// - Parameter tail: tail
/// - Parameter nSubIntervals: Number of subintervals. Possible values: 32,16,12,10,8,6,4,2. Default is set to 16.
/// - Returns: The tuple (cdf:, error:)
///
/// ### NOTE ###
/// This functions uses an algorithm supposed by Viktor Witkovsky (witkovsky@savba.sk):
/// Witkovsky V. (2013). A Note on Computing Extreme Tail</p>
/// Probabilities of the Noncentral T Distribution with Large</p>
/// Noncentrality Parameter. Working Paper, Institute of Measurement</p>
/// Science, Slovak Academy of Sciences, Bratislava.
///
/// The algorithm uses a Gauss-Kronrod quadrature with an error less than 1e-12 over a wide range of parameters. To reduce the
/// error (in case of extreme parameters) the number of subintervals can be adjusted.
/// Swift Version (C) Volker Thieme 2018
public func cdfStudentTDist<T: SSFloatingPoint & Codable>(t: T, degreesOfFreedom df: T, nonCentralityPara lambda: T, rlog: Bool! = false) throws -> T {

    var result: (cdf: T, error: T)
    do {
        result = try cdfNonCentralTVW(x: t, df: df, ncp: lambda, tail: .lower, nSubIntervals: 16)
        return result.cdf
    }
    catch {
        throw error
    }
    
    
}

/// Returns the pdf of the non-central Student's t-distribution
/// <img src="../img/nctpdf.png" alt="">
/// where H is the Hermite polynomial
/// - Parameter x: x
/// - Parameter nonCentralityPara: noncentrality parameter
/// - Parameter df: Degrees of freedom
/// - Parameter rlog: Return log(pdf)
/// - Throws: SSSwiftyStatsError if df <= 0
public func pdfStudentTDist<FPT: SSFloatingPoint & Codable>(x: FPT, degreesOfFreedom df: FPT, nonCentralityPara lambda: FPT, rlog: Bool! = false) throws -> FPT {
    /* using Hermite */
    let xx: Float80 = makeFP(x)
    let dff: Float80 = makeFP(df)
    let lambdaf: Float80 = makeFP(lambda)
    
    /* Mathematica */
    let hermite: Float80 = hermiteH(ny: -1 - dff, z: -(lambdaf * xx) / (Float80.sqrt2 * sqrt(dff + pow1(xx, 2))))
    let gamma: Float80 = tgammal((1.0 + dff) / 2)
    let p1: Float80 =  powl(dff + xx * xx, 0.5 * (-1 - dff))
    let e1: Float80 = expl(-powl(lambdaf, 2) / 2)
    let p2: Float80 = powl(dff, (1 + dff / 2))
    let p3: Float80 = powl(2, dff)
    let f: Float80 = (hermite * gamma * p1 * p2 * p3 * e1) / Float80.pi
    let result: Float80 = f
    return makeFP(result)
}

/// Returns the quantile function of the noncentral Student's t-distribution
/// - Parameter p: p
/// - Parameter nonCentralityPara: noncentrality parameter
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0 or/and p < 0 or p > 1.0
public func quantileStudentTDist<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT, nonCentralityPara lambda: FPT, rlog: Bool! = false) throws -> FPT {
   let accu: FPT = makeFP(1E-13)
    let eps: FPT = 10 * FPT.ulpOfOne
    var ux, lx, nx, pp: FPT
    if df.isNaN || p.isNaN || lambda.isNaN {
        return FPT.nan
    }
    if df <= 0 {
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
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if let test = r_q_p01_boundaries(p: p, left: -FPT.infinity, right: FPT.infinity) {
        return test
    }
    if df.isInfinite {
        do {
            return try quantileNormalDist(p: p, mean: lambda, standardDeviation: 1)
        }
        catch {
            throw error
        }
    }
    let p0 = r_dt_qIv(x: p, tail: .lower, log_p: rlog)
    if p0 > (1 - FPT.ulpOfOne) {
        return FPT.infinity
    }
    if p0 < FPT.leastNonzeroMagnitude {
        return -FPT.infinity
    }
    func q(t:FPT, ncp: FPT, df:FPT) -> FPT {
        do {
            let res: FPT = try makeFP(cdfStudentTDist(t: t, degreesOfFreedom: df, nonCentralityPara: ncp))
            return res
        }
        catch {
            return FPT.nan
        }
    }
    pp = min(1 - FPT.ulpOfOne, p0 * (1 + eps))
    ux = max(1, lambda)
//    var q: Double = try cdfStudentTNonCentral(t: ux, nonCentralityPara: ncp, degreesOfFreedom: df)
    while (ux < FPT.greatestFiniteMagnitude) && (q(t: ux, ncp: lambda, df: df) < pp) {
        ux = 2 * ux
    }

    pp = p0 * (1 - eps)

    lx = min(-1, -lambda)
    while ((lx > -FPT.greatestFiniteMagnitude) && (q(t: lx, ncp: lambda, df: df) > pp)) {
        lx = 2 * lx
    }
    repeat {
        nx = makeFP(1.0 / 2.0 ) * (lx + ux)
        if try makeFP(cdfStudentTDist(t: nx, degreesOfFreedom: df, nonCentralityPara: lambda)) > p {
            ux = nx
        }
        else {
            lx = nx
        }
    } while ((ux - lx) > accu * max(abs(lx), abs(ux)))
    return makeFP(1.0 / 2.0 ) * (lx + ux)
}

#endif
