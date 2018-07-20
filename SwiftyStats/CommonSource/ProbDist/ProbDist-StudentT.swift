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
    let lpdf = exp( lgamma( 0.5 * ( df + 1.0 ) ) - 0.5 * log( df * Double.pi ) - lgamma( 0.5 * df ) - ( ( df + 1.0 ) / 2.0 * log( 1.0 + t * t / df ) ) )
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


public func cdfStudentTNonCentral(t: Double!, degreesOfFreedom df: Double!, rlog: Double!) throws -> Double {
    return 0.0
}






public func pdfStudentTNonCentral(t: Double!, nonCentralityPara ncp: Double!, degreesOfFreedom df: Double!) throws -> Double {
    if df < 0.0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var u: Double = 0.0
    if t.isNaN || df.isNaN || ncp.isNaN {
        return Double.nan
    }
    if ncp == 0 {
        do {
            return try pdfStudentTDist(t: t, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
    }
    if t.isInfinite {
        return 0
    }
    if df >= 1E9 || df.isInfinite {
        do {
            return try pdfNormalDist(x: t, mean: ncp, standardDeviation: 1.0)
        }
        catch {
            throw error
        }
    }
    return 0.0
}
/*
 double dnt(double x, double df, double ncp, int give_log)
 {
 double u;
 #ifdef IEEE_754
 if (ISNAN(x) || ISNAN(df))
 return x + df;
 #endif
 
 /* If non-positive df then error */
 if (df <= 0.0) ML_ERR_return_NAN;
 
 if(ncp == 0.0) return dt(x, df, give_log);
 
 /* If x is infinite then return 0 */
 if(!R_FINITE(x))
 return R_D__0;
 
 /* If infinite df then the density is identical to a
 normal distribution with mean = ncp.  However, the formula
 loses a lot of accuracy around df=1e9
 */
 if(!R_FINITE(df) || df > 1e8)
 return dnorm(x, ncp, 1., give_log);
 
 /* Do calculations on log scale to stabilize */
 
 /* Consider two cases: x ~= 0 or not */
 if (fabs(x) > sqrt(df * DBL_EPSILON)) {
 u = log(df) - log(fabs(x)) +
 log(fabs(pnt(x*sqrt((df+2)/df), df+2, ncp, 1, 0) -
 pnt(x, df, ncp, 1, 0)));
 /* FIXME: the above still suffers from cancellation (but not horribly) */
 }
 else {  /* x ~= 0 : -> same value as for  x = 0 */
 u = lgammafn((df+1)/2) - lgammafn(df/2)
 - (M_LN_SQRT_PI + .5*(log(df) + ncp*ncp));
 }
 
 return (give_log ? u : exp(u));
 }
 
 */


/*
 /**********************************************************************
 
 void cumtnc(double *t,double *df,double *pnonc,double *cum,
 double *ccum)
 
 CUMulative Non-Central T-distribution
 
 
 Function
 
 
 Computes the integral from -infinity to T of the non-central
 t-density.
 
 
 Arguments
 
 
 T --> Upper limit of integration of the non-central t-density.
 
 DF --> Degrees of freedom of the non-central t-distribution.
 
 PNONC --> Non-centrality parameter of the non-central t distibutio
 
 CUM <-- Cumulative t-distribution.
 
 CCUM <-- Compliment of Cumulative t-distribution.
 
 
 Method
 
 Upper tail    of  the  cumulative  noncentral t   using
 formulae from page 532  of Johnson, Kotz,  Balakrishnan, Coninuous
 Univariate Distributions, Vol 2, 2nd Edition.  Wiley (1995)
 
 This implementation starts the calculation at i = lambda,
 which is near the largest Di.  It then sums forward and backward.
 **********************************************************************/
 {
 #define one 1.0e0
 #define zero 0.0e0
 #define half 0.5e0
 #define two 2.0e0
 #define onep5 1.5e0
 #define conv 1.0e-7
 #define tiny 1.0e-10
 static double alghdf,b,bb,bbcent,bcent,cent,d,dcent,dpnonc,dum1,dum2,e,ecent,
 halfdf,lambda,lnomx,lnx,omx,pnonc2,s,scent,ss,sscent,t2,term,tt,twoi,x,xi,
 xlnd,xlne;
 static int ierr;
 static unsigned long qrevs;
 static double T1,T2,T3,T4,T5,T6,T7,T8,T9,T10;
 /*
 ..
 .. Executable Statements ..
 */
 /*
 Case pnonc essentially zero
 */
 if(fabs(*pnonc) <= tiny) {
 cumt(t,df,cum,ccum);
 return;
 }
 qrevs = *t < zero;
 if(qrevs) {
 tt = -*t;
 dpnonc = -*pnonc;
 }
 else  {
 tt = *t;
 dpnonc = *pnonc;
 }
 pnonc2 = dpnonc * dpnonc;
 t2 = tt * tt;
 if(fabs(tt) <= tiny) {
 T1 = -*pnonc;
 cumnor(&T1,cum,ccum);
 return;
 }
 lambda = half * pnonc2;
 x = *df / (*df + t2);
 omx = one - x;
 lnx = log(x);
 lnomx = log(omx);
 halfdf = half * *df;
 alghdf = gamln(&halfdf);
 /*
 ******************** Case i = lambda
 */
 cent = fifidint(lambda);
 if(cent < one) cent = one;
 /*
 Compute d=T(2i) in log space and offset by exp(-lambda)
 */
 T2 = cent + one;
 xlnd = cent * log(lambda) - gamln(&T2) - lambda;
 dcent = exp(xlnd);
 /*
 Compute e=t(2i+1) in log space offset by exp(-lambda)
 */
 T3 = cent + onep5;
 xlne = (cent + half) * log(lambda) - gamln(&T3) - lambda;
 ecent = exp(xlne);
 if(dpnonc < zero) ecent = -ecent;
 /*
 Compute bcent=B(2*cent)
 */
 T4 = cent + half;
 bratio(&halfdf,&T4,&x,&omx,&bcent,&dum1,&ierr);
 /*
 compute bbcent=B(2*cent+1)
 */
 T5 = cent + one;
 bratio(&halfdf,&T5,&x,&omx,&bbcent,&dum2,&ierr);
 /*
 Case bcent and bbcent are essentially zero
 Thus t is effectively infinite
 */
 if(bcent + bbcent < tiny) {
 if(qrevs) {
 *cum = zero;
 *ccum = one;
 }
 else  {
 *cum = one;
 *ccum = zero;
 }
 return;
 }
 /*
 Case bcent and bbcent are essentially one
 Thus t is effectively zero
 */
 if(dum1 + dum2 < tiny) {
 T6 = -*pnonc;
 cumnor(&T6,cum,ccum);
 return;
 }
 /*
 First term in ccum is D*B + E*BB
 */
 *ccum = dcent * bcent + ecent * bbcent;
 /*
 compute s(cent) = B(2*(cent+1)) - B(2*cent))
 */
 T7 = halfdf + cent + half;
 T8 = cent + onep5;
 scent = gamln(&T7) - gamln(&T8) - alghdf + halfdf * lnx + (cent + half) *
 lnomx;
 scent = exp(scent);
 /*
 compute ss(cent) = B(2*cent+3) - B(2*cent+1)
 */
 T9 = halfdf + cent + one;
 T10 = cent + two;
 sscent = gamln(&T9) - gamln(&T10) - alghdf + halfdf * lnx + (cent + one) *
 lnomx;
 sscent = exp(sscent);
 /*
 ******************** Sum Forward
 */
 xi = cent + one;
 twoi = two * xi;
 d = dcent;
 e = ecent;
 b = bcent;
 bb = bbcent;
 s = scent;
 ss = sscent;
 S10:
 b += s;
 bb += ss;
 d = lambda / xi * d;
 e = lambda / (xi + half) * e;
 term = d * b + e * bb;
 *ccum += term;
 s = s * omx * (*df + twoi - one) / (twoi + one);
 ss = ss * omx * (*df + twoi) / (twoi + two);
 xi += one;
 twoi = two * xi;
 if(fabs(term) > conv * *ccum) goto S10;
 /*
 ******************** Sum Backward
 */
 xi = cent;
 twoi = two * xi;
 d = dcent;
 e = ecent;
 b = bcent;
 bb = bbcent;
 s = scent * (one + twoi) / ((*df + twoi - one) * omx);
 ss = sscent * (two + twoi) / ((*df + twoi) * omx);
 S20:
 b -= s;
 bb -= ss;
 d *= (xi / lambda);
 e *= ((xi + half) / lambda);
 term = d * b + e * bb;
 *ccum += term;
 xi -= one;
 if(xi < half) goto S30;
 twoi = two * xi;
 s = s * (one + twoi) / ((*df + twoi - one) * omx);
 ss = ss * (two + twoi) / ((*df + twoi) * omx);
 if(fabs(term) > conv * *ccum) goto S20;
 S30:
 if(qrevs) {
 *cum = half * *ccum;
 *ccum = one - *cum;
 }
 else  {
 *ccum = half * *ccum;
 *cum = one - *ccum;
 }
 /*
 Due to roundoff error the answer may not lie between zero and one
 Force it to do so
 */
 *cum = fifdmax1(fifdmin1(*cum,one),zero);
 *ccum = fifdmax1(fifdmin1(*ccum,one),zero);
 return;
 #undef one
 #undef zero
 #undef half
 #undef two
 #undef onep5
 #undef conv
 #undef tiny
 }
 
 
 */


