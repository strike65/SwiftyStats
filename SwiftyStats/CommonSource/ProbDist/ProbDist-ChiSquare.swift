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


// MARK: Chi Square
// MARK: Central

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Chi^2 distribution.
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func paraChiSquareDist<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT) throws -> SSContProbDistParams<FPT> {
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = df
    result.variance = 2 * df
    result.skewness = sqrt(8 / df)
    result.kurtosis = 3 + 12 / df
    return result
}


/// Returns the pdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func pdfChiSquareDist<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: FPT = 0
    if chi >= 0 {
        let a: FPT
        let b: FPT
        let c: FPT
        let d: FPT
        a = -df / 2 * FPT.ln2
        b = -chi / 2
        c = (-1 + df / 2) * log1(chi)
        d = lgamma1(df / 2)
        result = exp1(a + b + c - d)
    }
    else {
        result = 0
    }
    return result
}

/// Returns the cdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func cdfChiSquareDist<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, tail: SSCDFTail = .lower, rlog: Bool = false) throws -> FPT {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if chi <= 0 {
        return 0
    }
    var conv: Bool = false
    let cdf1: FPT = gammaNormalizedP(x: makeFP(1.0 / 2.0 ) * chi, a: makeFP(1.0 / 2.0 ) * df, converged: &conv)
    if cdf1 < 0 {
        if rlog {
            return -FPT.infinity
        }
        else {
            return 0
        }
    }
    else if ((cdf1 > 1) || cdf1.isNaN) {
        if rlog {
            return 0
        }
        else {
            return 1
        }
    }
    else {
        if rlog {
            return log1(cdf1)
        }
        else {
            return cdf1
        }
    }
}


/// Returns the p-quantile of the Chi^2 distribution.
/// - Parameter p: p
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func quantileChiSquareDist<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
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
    if p < FPT.leastNonzeroMagnitude {
        return 0
    }
    if (1 - p) < FPT.leastNonzeroMagnitude {
        return FPT.infinity
    }
    let eps: FPT = makeFP(1.0E-12)
    var minChi: FPT = 0
    var maxChi: FPT = 9999
    var result: FPT = 0
    var chiVal: FPT = df / sqrt(p)
    var test: FPT
    while (maxChi - minChi) > eps {
        do {
            test = try cdfChiSquareDist(chi: chiVal, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
        if test > p {
            maxChi = chiVal
        }
        else {
            minChi = chiVal
        }
        chiVal = (maxChi + minChi) / 2
    }
    result = chiVal
    return result
}

// MARK: noncentral


/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Chi^2 distribution.
/// - Parameter df: Degrees of freedom
/// - Parameter lambda: noncentrality parameter
/// - Throws: SSSwiftyStatsError if df <= 0
public func paraChiSquareDist<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT, lambda: FPT) throws -> SSContProbDistParams<FPT> {
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = df
    result.variance = 2 * df
    result.skewness = sqrt(8 / df)
    result.kurtosis = 3 + 12 / df
    return result
}


/// Returns the pdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func pdfChiSquareDist<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if lambda < 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lambda is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if lambda.isZero {
        do {
            return try pdfChiSquareDist(chi: chi, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
    }
    var result: FPT = 0
    if chi >= 0 {
        let bessel: FPT = besselI(order: df / 2 - 1, x: sqrt(lambda * chi))
        let a = makeFP(1.0 / 2.0 ) * exp1(-(chi + lambda) / 2)
        let b = pow1(chi / lambda, (df / 4) - makeFP(1.0 / 2.0 ))
        result = a * b * bessel
    }
    else {
        result = 0
    }
    return result
}


private func integrandChiSquared<FPT: SSFloatingPoint & Codable>(chi: FPT, df: FPT, lambda: FPT, p1: FPT, p2: FPT) -> FPT {
    return try! pdfChiSquareDist(chi: chi, degreesOfFreedom: df, lambda: lambda)
}

/// Returns the cdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func cdfChiSquareDist<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if lambda < 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lambda is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if lambda.isZero {
        do {
            return try cdfChiSquareDist(chi: chi, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
    }
    if chi <= 0 {
        return 0
    }
    
    var evals: Int = 0
    var error: FPT = 0

    let integral: FPT = integrate(integrand: integrandChiSquared, parameters: [df, lambda, 0, 0], leftLimit: 0, rightLimit: chi, maxAbsError: makeFP(1e-12), numberOfEvaluations: &evals, estimatedError: &error)
    return integral
//    do {
//        let ans = try cdfNoncentralChiSquare(chi: chi, degreesOfFreedom: df, noncentralityParameter: lambda)
//        return ans!
//    }
//    catch {
//        throw error
//    }
}




/// Returns the p-quantile of the Chi^2 distribution.
/// - Parameter p: p
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func quantileChiSquareDist<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
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
    if lambda < 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lambda is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if lambda.isZero {
        do {
            return try quantileChiSquareDist(p: p, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
    }
    if p < FPT.leastNonzeroMagnitude {
        return 0
    }
    if (1 - p) < FPT.leastNonzeroMagnitude {
        return FPT.infinity
    }
    let eps = (1.0E-12 as! FPT)
    var minChi: FPT = 0
    var maxChi: FPT = 10000
    var result: FPT = 0
    var chiVal: FPT = df / sqrt(p)
    var test: FPT
    while (maxChi - minChi) > eps {
        do {
            test = try cdfChiSquareDist(chi: chiVal, degreesOfFreedom: df, lambda: lambda)
        }
        catch {
            throw error
        }
        if test > p {
            maxChi = chiVal
        }
        else {
            minChi = chiVal
        }
        chiVal = (maxChi + minChi) / 2
    }
    result = chiVal
    return result
}

 
/*
// MARK: R

/*
 *  Algorithm AS 275 Appl.Statist. (1992), vol.41, no.2
 *  original  (C) 1992         Royal Statistical Society
 *
 *  Computes the noncentral chi-squared distribution function with
 *  positive real degrees of freedom df and nonnegative noncentrality
 *  parameter ncp.  pnchisq_raw is based on
 *
 *    Ding, C. G. (1992)
 *    Algorithm AS275: Computing the non-central chi-squared
 *    distribution function. Appl.Statist., 41, 478-482.
 
 *  Other parts
 *  Copyright (C) 2000-2015  The R Core Team
 *  Copyright (C) 2003-2015  The R Foundation
 */



//#include "nmath.h"
//#include "dpq.h"

/*----------- DEBUGGING -------------
 *
 *    make CFLAGS='-DDEBUG_pnch ....'
 (cd `R-devel RHOME`/src/nmath; gcc -I. -I../../src/include -I../../../R/src/include -I/usr/local/include -DHAVE_CONFIG_H -fopenmp -g -O0 -pedantic -Wall --std=gnu99 -DDEBUG_pnch -DDEBUG_q -Wcast-align -Wclobbered  -c ../../../R/src/nmath/pnchisq.c -o pnchisq.o )
 
 * -- Feb.6, 2000 (R pre0.99); M.Maechler:  still have
 * bad precision & non-convergence in some cases (x ~= f, both LARGE)
 */

//#ifdef HAVE_LONG_DOUBLE
//# define EXP expl
//# define FABS fabsl
//# define LOG logl
//#else
//# define EXP exp
//# define FABS fabs
//# define LOG log
//#endif

fileprivate let _dbl_min_exp = M_LN2 * Double((Double.leastNormalMagnitude.exponent + 1))

//static const double _dbl_min_exp = M_LN2 * DBL_MIN_EXP;
/*= -708.3964 for IEEE double precision */


fileprivate func cdfNoncentralChiSquare(chi: Double!, degreesOfFreedom df: Double!, noncentralityParameter ncp: Double!, tail: SSCDFTail = .lower, log_p: Bool = false) throws -> Double! {
//double pnchisq(double x, double df, double ncp, int lower_tail, int log_p)
//{
    var ans: Double
    if chi.isNaN || df.isNaN || ncp.isNaN {
        return Double.nan
    }
    if df.isInfinite || ncp.isInfinite {
        return Double.nan
    }
    do {
        ans = try pnchisq_raw(chi, df, ncp, 1e-12, 8 * Double.ulpOfOne, 1000000, tail, log_p)
    }
    catch {
        throw error
    }
    if(ncp >= 80) {
        if(tail == .lower) {
            ans = min(ans, r_d__1(log_p: log_p))   /* e.g., pchisq(555, 1.01, ncp = 80) */
        }
        else { /* !lower_tail */
            /* since we computed the other tail cancellation is likely */
//            let test = log_p ? (-10.0 * M_LN10) : (1e-10)
//            if(ans < test)
//                ML_ERROR(ME_PRECISION, "pnchisq");
            if(!log_p) {
                ans = max(ans, 0.0)
            }
        }
    }
    if (!log_p || ans < -1e-8) {
        return ans
    }
    else { // log_p  &&  ans > -1e-8
        // prob. = exp(ans) is near one: we can do better using the other tail
        // FIXME: (sum,sum2) will be the same (=> return them as well and reuse here ?)
        do {
            ans = try pnchisq_raw(chi, df, ncp, 1e-12, 8 * Double.ulpOfOne, 1000000, .upper, false)
            return log1p(-ans)
        }
        catch {
            throw error
        }
    }
}


fileprivate func pnchisq_raw(_ x: Double!, _ f: Double!, _ theta: Double!, _ errmax: Double!, _ reltol: Double!, _ itrmax: Int, _ tail: SSCDFTail = .lower, _ log_p: Bool = false) throws -> Double {
    var lam, x2, f2, term, bound, f_x_2n, f_2n: Double
    var l_lam = -1.0
    var l_x = -1.0
    var n: Int
    var lamSml, tSml, is_r, is_b, is_it: Bool
    #if (arch(arm) || arch(arm64))
    var ans, u, v, t, lt: Double
    var lu: Double = -1.0
    #else
    var ans, u, v, t, lt: Float80
    var lu: Float80 = -1.0
    #endif
    
    if (x <= 0.0) {
        if(x.isZero && f.isZero) {
            if tail == .lower {
                return rd_exp(x: -0.5 * theta, log_p: log_p)
            }
            else {
                if log_p {
                    return r_log1_exp(x: -0.5 * theta, log_p: log_p)
                }
                else {
                    return -expm1(-0.5 * theta)
                }
            }
        }
        /* x < 0  or {x==0, f > 0} */
        return r_dt_0(tail: tail, log_p: log_p)
    }
    if !x.isFinite {
        return r_dt_1(tail: tail, log_p: log_p)
    }
    
    /* This is principally for use from qnchisq */
    
    if(theta < 80) { /* use 110 for Inf, as ppois(110, 80/2, lower.tail=FALSE) is 2e-20 */
        #if (arch(arm) || arch(arm64))
        var ans: Double
        #else
        var ans: Float80
        #endif
        // Have  pgamma(x,s) < x^s / Gamma(s+1) (< and ~= for small x)
        // ==> pchisq(x, f) = pgamma(x, f/2, 2) = pgamma(x/2, f/2)
        //                  <  (x/2)^(f/2) / Gamma(f/2+1) < eps
        // <==>  f/2 * log(x/2) - log(Gamma(f/2+1)) < log(eps) ( ~= -708.3964 )
        // <==>        log(x/2) < 2/f*(log(Gamma(f/2+1)) + log(eps))
        // <==> log(x) < log(2) + 2/f*(log(Gamma(f/2+1)) + log(eps))
        let b1 = (tail == .lower) && (f > 0.0)
        let expr1 = (f / 2.0).lGammaValue + _dbl_min_exp
        let expr2 = 2.0 / f * expr1
        let b2 = log(x) < (M_LN2 + expr2)
        if( b1 && b2 ) {
            // all  pchisq(x, f+2*i, lower_tail, FALSE), i=0,...,110 would underflow to 0.
            // ==> work in log scale
            let lambda = 0.5 * theta
            var sum, sum2: Double
            let pr = -lambda
            sum = -Double.infinity
            sum2 = -Double.infinity
            /* we need to renormalize here: the result could be very close to 1 */
            //            for(i = 0; i < 110;  pr += log(lambda) - log(++i)) {
            var cdf_chi: Double = 0
            for i in stride(from: 0, to: 110, by: 1) {
                sum2 = logspace_add(sum2, pr)
                do {
                    cdf_chi = try cdfChiSquareDist(chi: x, degreesOfFreedom: f + 2.0 * Double(i), tail: tail, rlog: true)
                }
                catch {
                    throw error
                }
                sum = logspace_add(sum, pr + cdf_chi)
                if (sum2 >= -1e-15) { /*<=> EXP(sum2) >= 1-1e-15 */
                    break
                }
            }
            #if (arch(arm) || arch(arm64))
            ans = sum - sum2
            #else
            ans = Float80(sum) - Float80(sum2)
            #endif
            //            #ifdef DEBUG_pnch
            //            REprintf("pnchisq(x=%g, f=%g, th.=%g); th. < 80, logspace: i=%d, ans=(sum=%g)-(sum2=%g)\n",
            //            x,f,theta, i, (double)sum, (double)sum2);
            if log_p {
                return Double(ans)
            }
            else {
                return exp(Double(ans))
            }
        }
        else {
            #if (arch(arm) || arch(arm64))
            let lambda: Double = 0.5 * theta
            var sum: Double = 0.0
            var sum2 : Double = 0.0
            var pr: Double = exp(-lambda)
            #else
            let lambda: Float80 = Float80(0.5) * Float80(theta)
            var sum: Float80 = 0.0
            var sum2: Float80 = 0.0
            var pr: Float80 = Float80(exp(Double(-lambda)))
            #endif
            /* we need to renormalize here: the result could be very close to 1 */
            //            for(i = 0; i < 110;  pr *= lambda/++i) {
            var cdf_chi: Double
            for i in stride(from: 0, to: 110, by: 1) {
                // pr == exp(-lambda) lambda^i / i!  ==  dpois(i, lambda)
                sum2 += pr
                // pchisq(*, i, *) is  strictly decreasing to 0 for lower_tail=TRUE
                //                 and strictly increasing to 1 for lower_tail=FALSE
                do {
                    cdf_chi = try cdfChiSquareDist(chi: x, degreesOfFreedom: f + 2.0 * Double(i), tail: tail, rlog: false)
                }
                catch {
                    throw error
                }
                #if (arch(arm) || arch(arm64))
                sum += pr * cdf_chi
                #else
                sum += pr * Float80(cdf_chi)
                #endif
                if (sum2 >= (1.0 - 1e-15)) {
                    break
                }
            }
            ans = sum / sum2
            if log_p {
                return log(Double(ans))
            }
            else {
                return Double(ans)
            }
        }
    } // if(theta < 80)
        // else: theta == ncp >= 80 --------------------------------------------
        
        // Series expansion ------- FIXME: log_p=TRUE, lower_tail=FALSE only applied at end
        
    lam = 0.5 * theta
    lamSml = (-lam < _dbl_min_exp)
    if(lamSml) {
        /* MATHLIB_ERROR(
         "non centrality parameter (= %g) too large for current algorithm",
         theta) */
        u = 0
        #if (arch(arm) || arch(arm64))
        lu = -lam   /* == ln(u) */
        #else
        lu = Float80(-lam)   /* == ln(u) */
        #endif
        l_lam = log(lam)
    } else {
        #if (arch(arm) || arch(arm64))
        u = exp(-lam)
        #else
        u = Float80(exp(-lam))
        #endif
    }
    
    /* evaluate the first term */
    v = u
    x2 = 0.5 * x
    f2 = 0.5 * f
    f_x_2n = f - x
    #if (arch(arm) || arch(arm64))
    t = x2 - f2
    let sqrtUlpf2 = sqrt(Double.ulpOfOne) * f2
    #else
    t = Float80(x2 - f2)
    let sqrtUlpf2 = Float80(sqrt(Float80.ulpOfOne)) * Float80(f2)
    #endif
    if(f2 * Double.ulpOfOne > 0.125 && /* very large f and x ~= f: probably needs */
        fabs(t) <         /* another algorithm anyway */
        sqrtUlpf2) {
        /* evade cancellation error */
        /* t = exp((1 - t)*(2 - t/(f2 + 1))) / sqrt(2*M_PI*(f2 + 1));*/
        #if (arch(arm) || arch(arm64))
        let expr1 = 1.0 - t
        let expr2 = (2.0 - t / (f2 + 1))
        let expr3 = 0.5 * log(f2 + 1.0)
        lt = expr1 * expr2 - LNSQRT2PI - expr3
        #else
        let expr1 = 1.0 - t
        let expr2 = (2.0 - t / (Float80(f2 + 1)))
        let expr3 = 0.5 * log(f2 + 1.0)
        lt = expr1 * expr2 - Float80(LNSQRT2PI) - Float80(expr3)
        #endif
    }
    else {
        /* Usual case 2: careful not to overflow .. : */
        #if (arch(arm) || arch(arm64))
        lt = f2 * log(x2) - x2 - lgamma(f2 + 1)
        #else
        lt = Float80(f2) * Float80(log(x2)) - Float80(x2) - Float80(lgamma(Double(f2 + 1)))
        #endif
    }
    #if (arch(arm) || arch(arm64))
    tSml = (lt < _dbl_min_exp)
    #else
    tSml = (lt < Float80(_dbl_min_exp))
    #endif

    if(tSml) {
        let expr1 = f + theta
        let expr2 = 0.5 * sqrt(2.0 * f + 4.0 * theta)
        if (x > (expr1 + expr2)) {
//        if (x > f + theta +  5.0 * sqrt( 2 * (f + 2 * theta))) {
            /* x > E[X] + 5* sigma(X) */
            return r_dt_1(tail: tail, log_p: log_p) /* FIXME: could be more accurate than 0. */
        } /* else */
        l_x = log(x)
        ans = 0.0
        term = 0.0
        t = 0.0
    }
    else {
        #if (arch(arm) || arch(arm64))
        t = exp(lt)
        ans = Double(v * t)
        term = Double(v * t)
        #else
        t = Float80(exp(Double(lt)))
        ans = Float80(v * t)
        term = Double(v * t)
        #endif
    }
    n = 1
    n = n + 1
    f_2n = f + 2.0
    f_x_2n = f_x_2n + 2.0
    is_it = false
    is_r = false
    repeat {
//        for (n = 1, f_2n = f + 2., f_x_2n += 2.;  ; n++, f_2n += 2, f_x_2n += 2) {
        /* f_2n    === f + 2*n
         * f_x_2n  === f - x + 2*n   > 0  <==> (f+2n)  >   x */
        if (f_x_2n > 0) {
            /* find the error bound and check for convergence */
            #if (arch(arm) || arch(arm64))
            bound = Double(t * x / f_x_2n)
            #else
            bound = Double(t) * x / f_x_2n
            #endif
            is_it = (n > itrmax)
            is_b = (bound <= errmax)
            is_r = (term <= reltol * Double(ans))
            /* convergence only if BOTH absolute and relative error < 'bnd' */
            if ((is_b && is_r ) || is_it) {
                break /* out completely */
            }
        }
        
        /* evaluate the next term of the */
        /* expansion and then the partial sum */
        
        if(lamSml) {
            #if (arch(arm) || arch(arm64))
            lu += l_lam - log(Double(n)) /* u = u* lam / n */
            let test = (lu >= _dbl_min_exp)
            #else
            lu += Float80(l_lam) - Float80(log(Double(n))) /* u = u* lam / n */
            let test = (lu >= Float80(_dbl_min_exp))
            #endif
            if test {
                /* no underflow anymore ==> change regime */
                #if (arch(arm) || arch(arm64))
                v = exp(lu)
                u = exp(lu) /* the first non-0 'u' */
                #else
                v = Float80(exp(Double(lu)))
                u = Float80(exp(Double(lu))) /* the first non-0 'u' */
                #endif
                lamSml = false
            }
        } else {
            #if (arch(arm) || arch(arm64))
            u *= lam / Double(n)
            v += u
            #else
            u *= Float80(lam) / Float80(n)
            v += u
            #endif
        }
        if(tSml) {
            #if (arch(arm) || arch(arm64))
            lt += l_x - log(f_2n)       /* t <- t * (x / f2n) */
            let test = (lt >= _dbl_min_exp)
            #else
            lt += Float80(l_x) - Float80(log(f_2n))       /* t <- t * (x / f2n) */
            let test = (lt >= Float80(_dbl_min_exp))
            #endif
            if(test) {
                /* no underflow anymore ==> change regime */
                #if (arch(arm) || arch(arm64))
                t = exp(lt) /* the first non-0 't' */
                #else
                t = Float80(exp(Double(lt))) /* the first non-0 't' */
                #endif
                tSml = false
            }
        } else {
            #if (arch(arm) || arch(arm64))
            t *= x / f_2n
            #else
            t *= Float80(x) / Float80(f_2n)
            #endif
        }
        if(!lamSml && !tSml) {
            #if (arch(arm) || arch(arm64))
            term = v * t
            ans += term
            #else
            term = Double(v * t)
            ans += Float80(term)
            #endif
        }
        n = n + 1
        f_2n = f + 2.0
        f_x_2n = f_x_2n + 2.0
    } while (true) /* for(n ...) */
    
    if (is_it) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("series expansion did not converge are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        throw SSSwiftyStatsError.init(type: .maxNumberOfIterationReached, file: #file, line: #line, function: #function)

    }
    return r_dt_val(x: Double(ans), tail: tail, log_p: log_p)
 }



*/






