//
//  SSTukey.swift
//  SwiftyStats
//
//  Created by strike65 on 03.07.17.
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
/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998       Ross Ihaka
 *  Copyright (C) 2000--2007 The R Core Team
 *  Copyright (C( 1017 strike65 (Swift port)
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 *
 *  SYNOPSIS
 *
 *    #include <Rmath.h>
 *    double ptukey(q, rr, cc, df, lower_tail, log_p);
 *
 *  DESCRIPTION
 *
 *    Computes the probability that the maximum of rr studentized
 *    ranges, each based on cc means and with df degrees of freedom
 *    for the standard error, is less than q.
 *
 *    The algorithm is based on that of the reference.
 *
 *  REFERENCE
 *
 *    Copenhaver, Margaret Diponzio & Holland, Burt S.
 *    Multiple comparisons of simple effects in
 *    the two-way analysis of variance with fixed effects.
 *    Journal of Statistical Computation and Simulation,
 *    Vol.30, pp.1-15, 1988.
 */

import Foundation
#if os(macOS) || os(iOS)
import os.log
#endif


extension Helpers {
    
    /// This a translation from the R function ptukey to Swift. See Remarks below
    /// q = value of studentized range
    /// rr = no. of rows or groups
    /// cc = no. of columns or treatments
    /// df = degrees of freedom of error term
    /// ir[0] = error flag = 1 if wprob probability > 1
    /// ir[1] = error flag = 1 if qprob probability > 1
    ///
    /// qprob = returned probability integral over [0, q]
    ///
    /// The program will not terminate if ir[0] or ir[1] are raised.
    ///
    /// All references in wprob to Abramowitz and Stegun
    /// are from the following reference:
    ///
    /// Abramowitz, Milton and Stegun, Irene A.
    /// Handbook of Mathematical Functions.
    /// New York:  Dover publications, Inc. (1970).
    ///
    /// All constants taken from this text are
    /// given to 25 significant digits.
    ///
    /// nlegq = order of legendre quadrature
    /// ihalfq = int ((nlegq + 1) / 2)
    /// eps = max. allowable value of integral
    /// eps1 & eps2 = values below which there is
    /// no contribution to integral.
    ///
    /// d.f. <= dhaf:    integral is divided into ulen1 length intervals.  else
    /// d.f. <= dquar:    integral is divided into ulen2 length intervals.  else
    /// d.f. <= deigh:    integral is divided into ulen3 length intervals.  else
    /// d.f. <= dlarg:    integral is divided into ulen4 length intervals.
    ///
    /// d.f. > dlarg:    the range is used to calculate integral.
    ///
    /// M_LN2 = log(2)
    ///
    /// xlegq = legendre 16-point nodes
    /// alegq = legendre 16-point coefficients
    ///
    /// The coefficients and nodes for the legendre quadrature used in
    /// qprob and wprob were calculated using the algorithms found in:
    ///
    /// Stroud, A. H. and Secrest, D.
    /// Gaussian Quadrature Formulas.
    /// Englewood Cliffs,
    /// New Jersey:  Prentice-Hall, Inc, 1966.
    ///
    /// All values matched the tables (provided in same reference)
    /// to 30 significant digits.
    ///
    /// f(x) = .5 + erf(x / sqrt(2)) / 2      for x > 0
    ///
    /// f(x) = erfc( -x / sqrt(2)) / 2          for x < 0
    ///
    /// where f(x) is standard normal c. d. f.
    ///
    /// if degrees of freedom large, approximate integral
    /// with range distribution.
    internal static func ptukey(q: Double, nranges: Double, numberOfMeans: Double, df: Double, tail: SSCDFTail, returnLogP: Bool) throws -> Double {
        /*  function ptukey() [was qprob() ]:
         
         q = value of studentized range
         rr = no. of rows or groups
         cc = no. of columns or treatments
         df = degrees of freedom of error term
         ir[0] = error flag = 1 if wprob probability > 1
         ir[1] = error flag = 1 if qprob probability > 1
         
         qprob = returned probability integral over [0, q]
         
         The program will not terminate if ir[0] or ir[1] are raised.
         
         All references in wprob to Abramowitz and Stegun
         are from the following reference:
         
         Abramowitz, Milton and Stegun, Irene A.
         Handbook of Mathematical Functions.
         New York:  Dover publications, Inc. (1970).
         
         All constants taken from this text are
         given to 25 significant digits.
         
         nlegq = order of legendre quadrature
         ihalfq = int ((nlegq + 1) / 2)
         eps = max. allowable value of integral
         eps1 & eps2 = values below which there is
         no contribution to integral.
         
         d.f. <= dhaf:    integral is divided into ulen1 length intervals.  else
         d.f. <= dquar:    integral is divided into ulen2 length intervals.  else
         d.f. <= deigh:    integral is divided into ulen3 length intervals.  else
         d.f. <= dlarg:    integral is divided into ulen4 length intervals.
         
         d.f. > dlarg:    the range is used to calculate integral.
         
         M_LN2 = log(2)
         
         xlegq = legendre 16-point nodes
         alegq = legendre 16-point coefficients
         
         The coefficients and nodes for the legendre quadrature used in
         qprob and wprob were calculated using the algorithms found in:
         
         Stroud, A. H. and Secrest, D.
         Gaussian Quadrature Formulas.
         Englewood Cliffs,
         New Jersey:  Prentice-Hall, Inc, 1966.
         
         All values matched the tables (provided in same reference)
         to 30 significant digits.
         
         f(x) = .5 + erf(x / sqrt(2)) / 2      for x > 0
         
         f(x) = erfc( -x / sqrt(2)) / 2          for x < 0
         
         where f(x) is standard normal c. d. f.
         
         if degrees of freedom large, approximate integral
         with range distribution.
         */
        let nlegq = 16
        let ihalfq = 8
        /*  const double eps = 1.0; not used if = 1 */
        let eps1 = -30.0
        let eps2 = 1.0e-14
        let dhaf  = 100.0
        let dquar = 800.0
        let deigh = 5000.0
        let dlarg = 25000.0
        let ulen1 = 1.0
        let ulen2 = 0.5
        let ulen3 = 0.25
        let ulen4 = 0.125
        let xlegq = [
            0.989400934991649932596154173450,
            0.944575023073232576077988415535,
            0.865631202387831743880467897712,
            0.755404408355003033895101194847,
            0.617876244402643748446671764049,
            0.458016777657227386342419442984,
            0.281603550779258913230460501460,
            0.950125098376374401853193354250e-1]
        let alegq = [
            0.271524594117540948517805724560e-1,
            0.622535239386478928628438369944e-1,
            0.951585116824927848099251076022e-1,
            0.124628971255533872052476282192,
            0.149595988816576732081501730547,
            0.169156519395002538189312079030,
            0.182603415044923588866763667969,
            0.189450610455068496285396723208]
        var ans: Double
        var f2: Double
        var f21: Double
        var f2lf: Double
        var ff4: Double
        var otsum: Double
        var qsqz: Double
        var rotsum: Double
        var t1: Double
        var twa1: Double
        var ulen: Double
        var wprb: Double
        var i: Int
        var j: Int
        var jj: Int
        if q.isNaN || nranges.isNaN || numberOfMeans.isNaN || df.isNaN {
            return Double.nan
        }
        
        
        if (q <= 0) {
            return Helpers.r_dt_0(tail: tail, log_p: returnLogP)
        }
        
        /* df must be > 1 */
        /* there must be at least two values */
        
        if (df < 2 || nranges < 1 || numberOfMeans < 2) {
            return Double.nan
        }
        
        if !q.isFinite {
            return Helpers.r_dt_1(tail: tail, log_p: returnLogP)
        }
        
        if (df > dlarg) {
            do {
                return Helpers.r_dt_val(x: try wprob(w: q, rr: nranges, cc: numberOfMeans), tail: tail, log_p: returnLogP)
            }
            catch {
                throw error
            }
        }
        f2 = df * 0.5
        /* lgammafn(u) = log(gamma(u)) */
        f2lf = ((f2 * log(df)) - (df * Double.ln2)) - lgamma(f2)
        f21 = f2 - 1.0
        
        /* integral is divided into unit, half-unit, quarter-unit, or */
        /* eighth-unit length intervals depending on the value of the */
        /* degrees of freedom. */
        
        ff4 = df * 0.25;
        if        (df <= dhaf) { ulen = ulen1 }
        else if (df <= dquar) { ulen = ulen2 }
        else if (df <= deigh) { ulen = ulen3 }
        else { ulen = ulen4 }
        
        f2lf += log(ulen)
        
        /* integrate over each subinterval */
        
        ans = 0.0
        i = 1
        otsum = 0.0
        while i <= 50 {
            otsum = 0.0
            
            twa1 = 2.0 * Double(i) - 1.0 * ulen
            jj = 1
            while jj <= nlegq {
                if (ihalfq < jj) {
                    j = jj - ihalfq - 1
                    t1 = (f2lf + (f21 * log(twa1 + (xlegq[j] * ulen)))) - (((xlegq[j] * ulen) + twa1) * ff4)
                } else {
                    j = jj - 1
                    t1 = (f2lf + (f21 * log(twa1 - (xlegq[j] * ulen)))) + (((xlegq[j] * ulen) - twa1) * ff4)
                }
                
                /* if exp(t1) < 9e-14, then doesn't contribute to integral */
                if (t1 >= eps1) {
                    if (ihalfq < jj) {
                        qsqz = q * sqrt(((xlegq[j] * ulen) + twa1) * 0.5)
                    } else {
                        qsqz = q * sqrt(((-(xlegq[j] * ulen)) + twa1) * 0.5)
                    }
                    
                    /* call wprob to find integral of range portion */
                    do {
                        wprb = try wprob(w: qsqz, rr: nranges, cc: numberOfMeans)
                    }
                    catch {
                        throw error
                    }
                    rotsum = (wprb * alegq[j]) * exp(t1)
                    otsum += rotsum
                }
                /* end legendre integral for interval i */
                /* L200: */
                jj += 1
            }
            if Double(i) * ulen > 1.0 && otsum <= eps2 {
                break
            }
            ans += otsum
            i += 1
        }
        if otsum > eps2 {
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if ans > 1.0 {
            ans = 1.0
        }
        return Helpers.r_dt_val(x: ans, tail: tail, log_p: returnLogP)
    }
    
    
    
    
    /*
     *  Copenhaver, Margaret Diponzio & Holland, Burt S.
     *  Multiple comparisons of simple effects in
     *  the two-way analysis of variance with fixed effects.
     *  Journal of Statistical Computation and Simulation,
     *  Vol.30, pp.1-15, 1988.
     *
     *  Uses the secant method to find critical values.
     *
     *  p = confidence level (1 - alpha)
     *  rr = no. of rows or groups
     *  cc = no. of columns or treatments
     *  df = degrees of freedom of error term
     *
     *  ir(1) = error flag = 1 if wprob probability > 1
     *  ir(2) = error flag = 1 if ptukey probability > 1
     *  ir(3) = error flag = 1 if convergence not reached in 50 iterations
     *               = 2 if df < 2
     *
     *  qtukey = returned critical value
     *
     *  If the difference between successive iterates is less than eps,
     *  the search is terminated
     */
    
    
    /// In R, the function is called as follows:
    /// qtukey <- function(p, nmeans, df, nranges=1, lower.tail = TRUE, log.p = FALSE)
    ///
    ///  .Call(C_qtukey, p, nranges, nmeans, df, lower.tail, log.p)
    internal static func qtukey(p: Double, nranges: Double /*nranges*/, numberOfMeans: Double/*nmeans*/, df: Double, tail: SSCDFTail, log_p: Bool) throws -> Double {
        let eps = 0.0001
        let maxiter = 50
        
        var ans = 0.0
        var valx0: Double
        var valx1: Double
        var x0: Double
        var x1: Double
        var xabs: Double
        var iter: Int
        var pp: Double
        if (p.isNaN || nranges.isNaN || numberOfMeans.isNaN || df.isNaN) {
            return p + nranges + numberOfMeans + df;
        }
        
        /* df must be > 1 ; there must be at least two values */
        if (df < 2 || nranges < 1 || numberOfMeans < 2) {
            return Double.nan
        }
        if log_p {
            if p > 0 {
                return Double.nan
            }
            if p == 0.0 {
                return (tail == .lower) ? 0 : Double.infinity
            }
            if p == -Double.infinity {
                return (tail == .lower) ? Double.infinity : 0
            }
        }
        else {
            if p < 0 || p > 1 {
                return Double.nan
            }
            if p == 0.0 {
                return (tail == .lower) ? Double.infinity : 0
            }
            if p == 1.0 {
                return (tail == .lower) ? 0 : Double.infinity
            }
        }
        
        pp = Helpers.r_dt_qIv(x: p, tail: tail, log_p: log_p) /* lower_tail,non-log "p" */
        
        /* Initial value */
        
        x0 = qinv(p: pp, c: numberOfMeans, v: df);
        
        /* Find prob(value < x0) */
        do {
            valx0 = try ptukey(q: x0, nranges: nranges, numberOfMeans: numberOfMeans, df: df, tail: .lower, /*LOG_P*/returnLogP: false) - pp
        }
        catch {
            throw error
        }
        
        /* Find the second iterate and prob(value < x1). */
        /* If the first iterate has probability value */
        /* exceeding p then second iterate is 1 less than */
        /* first iterate; otherwise it is 1 greater. */
        
        if (valx0 > 0.0) {
            x1 = max(0.0, x0 - 1.0)
        }
        else {
            x1 = x0 + 1.0
        }
        do {
            valx1 = try ptukey(q: x1, nranges: nranges, numberOfMeans: numberOfMeans, df: df, /*LOWER*/tail: .lower, /*LOG_P*/returnLogP: false) - pp
        }
        catch {
            throw error
        }
        
        /* Find new iterate */
        iter = 1
        while iter < maxiter {
            ans = x1 - ((valx1 * (x1 - x0)) / (valx1 - valx0))
            valx0 = valx1
            
            /* New iterate must be >= 0 */
            
            x0 = x1
            if (ans < 0.0) {
                ans = 0.0
                valx1 = -pp
            }
            /* Find prob(value < new iterate) */
            do {
                valx1 = try ptukey(q: ans, nranges: nranges, numberOfMeans: numberOfMeans, df: df, tail: .lower, returnLogP: false) - pp
            }
            catch {
                throw error
            }
            x1 = ans
            
            /* If the difference between two successive */
            /* iterates is less than eps, stop */
            
            xabs = fabs(x1 - x0)
            if (xabs < eps) {
                return ans
            }
            iter += 1
        }
        /* The process did not converge in 'maxiter' iterations */
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 13, *) {
            os_log("qtukey didn't converge", log: .log_stat, type: .info)
        }
        
        #endif
        
        return ans
    }
    
    
    
}

fileprivate func wprob(w: Double, rr: Double, cc: Double) throws -> Double {
    /*  wprob() :
     
     This function calculates probability integral of Hartley's
     form of the range.
     
     w     = value of range
     rr    = no. of rows or groups
     cc    = no. of columns or treatments
     ir    = error flag = 1 if pr_w probability > 1
     pr_w = returned probability integral from (0, w)
     
     program will not terminate if ir is raised.
     
     bb = upper limit of legendre integration
     iMax = maximum acceptable value of integral
     nleg = order of legendre quadrature
     ihalf = int ((nleg + 1) / 2)
     wlar = value of range above which wincr1 intervals are used to
     calculate second part of integral,
     else wincr2 intervals are used.
     C1, C2, C3 = values which are used as cutoffs for terminating
     or modifying a calculation.
     
     M_1_SQRT_2PI = 1 / sqrt(2 * pi);  from abramowitz & stegun, p. 3.
     M_SQRT2 = sqrt(2)
     xleg = legendre 12-point nodes
     aleg = legendre 12-point coefficients
     */
    let nleg = 12
    let ihalf = 6
    let C1 = -30.0
    let C2 = -50.0
    let C3 = 60.0
    let bb   = 8.0
    let wlar = 3.0
    let wincr1 = 2.0
    let wincr2 = 3.0
    let xleg = [
        0.981560634246719250690549090149,
        0.904117256370474856678465866119,
        0.769902674194304687036893833213,
        0.587317954286617447296702418941,
        0.367831498998180193752691536644,
        0.125233408511468915472441369464]
    let aleg = [
        0.047175336386511827194615961485,
        0.106939325995318430960254718194,
        0.160078328543346226334652529543,
        0.203167426723065921749064455810,
        0.233492536538354808760849898925,
        0.249147045813402785000562436043]
    var a: Double
    var ac: Double
    var pr_w: Double
    var b: Double
    var binc: Double
    var c: Double
    var cc1: Double
    var pminus: Double
    var pplus: Double
    var qexpo: Double
    var qsqz: Double
    var rinsum: Double
    var wi: Double
    var wincr: Double
    var xx: Double
    #if (arch(arm) || arch(arm64))
    var blb: Double
    var bub: Double
    var einsum: Double
    var elsum: Double
    #else
    var blb: Float80
    var bub: Float80
    var einsum: Float80
    var elsum: Float80
    #endif
    var j: Int
    var jj: Int
    qsqz = w * 0.5
    /* if w >= 16 then the integral lower bound (occurs for c=20) */
    /* is 0.99999999999995 so return a value of 1. */
    if qsqz >= bb {
        return 1.0
    }
    
    /* find (f(w/2) - 1) ^ cc */
    /* (first term in integral of hartley's form). */
    pr_w = 2.0 * SSProbDist.StandardNormal.cdf(u: qsqz) - 1.0 /* erf(qsqz / M_SQRT2) */
    
    /* if pr_w ^ cc < 2e-22 then set pr_w = 0 */
    if pr_w >= exp(C2 / cc) {
        pr_w = pow(pr_w, cc)
    }
    else {
        pr_w = 0.0
    }
    
    /* if w is large then the second component of the */
    /* integral is small, so fewer intervals are needed. */
    
    if (w > wlar) {
        wincr = wincr1
    }
    else {
        wincr = wincr2
    }
    
    /* find the integral of second term of hartley's form */
    /* for the integral of the range for equal-length */
    /* intervals using legendre quadrature.  limits of */
    /* integration are from (w/2, 8).  two or three */
    /* equal-length intervals are used. */
    
    /* blb and bub are lower and upper limits of integration. */
    #if (arch(arm) || arch(arm64))
    blb = qsqz
    #else
    blb = Float80(qsqz)
    #endif
    binc = (bb - qsqz) / wincr
    #if (arch(arm) || arch(arm64))
    bub = blb + binc
    #else
    bub = blb + Float80(binc)
    #endif
    einsum = 0.0
    /* integrate over each interval */
    
    cc1 = cc - 1.0
    wi = 1.0
    while wi <= wincr {
        elsum = 0.0;
        #if (arch(arm) || arch(arm64))
        a = Double(0.5 * (bub + blb))
        #else
        a = Double(0.5 * (bub + blb))
        #endif
        /* legendre quadrature with order = nleg */
        
        #if (arch(arm) || arch(arm64))
        b = Double(0.5 * (bub - blb))
        #else
        b = Double(0.5 * (bub - blb))
        #endif
        jj = 1
        while jj <= nleg {
            if (ihalf < jj) {
                j = (nleg - jj) + 1;
                xx = xleg[j-1];
            } else {
                j = jj;
                xx = -xleg[j-1];
            }
            c = b * xx;
            ac = a + c;
            
            /* if exp(-qexpo/2) < 9e-14, */
            /* then doesn't contribute to integral */
            
            qexpo = ac * ac;
            if (qexpo > C3) {
                break
            }
            do {
                pplus = try SSProbDist.Gaussian.cdf(x: ac, mean: 0, variance: 1) * 2.0 // Standard.cdf(u: ac)
                pminus = try SSProbDist.Gaussian.cdf(x: ac, mean: w, variance: 1) * 2.0  // pnorm(ac, w,  1., 1,0)
            }
            catch {
                throw error
            }
            
            /* if rinsum ^ (cc-1) < 9e-14, */
            /* then doesn't contribute to integral */
            
            rinsum = (pplus * 0.5) - (pminus * 0.5);
            if rinsum >= exp(C1 / cc1) {
                rinsum = (aleg[j-1] * exp(-(0.5 * qexpo))) * pow(rinsum, cc1)
                #if arch(arm) || arch(arm64)
                elsum += rinsum
                #else
                elsum += Float80(rinsum)
                #endif
            }
            jj += 1
        }
        #if arch(arm) || arch(arm64)
        elsum *= (((2.0 * b) * cc) * Double.sqrt2piinv)
        #else
        elsum *= (((Float80(2.0) * Float80(b)) * Float80(cc)) * Float80.sqrt2piinv)
        #endif
        einsum += elsum
        blb = bub
        #if arch(arm) || arch(arm64)
        bub += binc
        #else
        bub += Float80(binc)
        #endif
        wi += 1.0
    }
    /* if pr_w ^ rr < 9e-14, then return 0 */
    pr_w += Double(einsum)
    if pr_w <= exp(C1 / rr) {
        return 0.0
    }
    
    pr_w = pow(pr_w, rr)
    if (pr_w >= 1.0) { /* 1 was iMax was eps */
        return 1.0
    }
    return pr_w
}



/* qinv() :
 *	this function finds percentage point of the studentized range
 *	which is used as initial estimate for the secant method.
 *	function is adapted from portion of algorithm as 70
 *	from applied statistics (1974) ,vol. 23, no. 1
 *	by odeh, r. e. and evans, j. o.
 *
 *	  p = percentage point
 *	  c = no. of columns or treatments
 *	  v = degrees of freedom
 *	  qinv = returned initial estimate
 *
 *	vmax is cutoff above which degrees of freedom
 *	is treated as infinity.
 */
fileprivate func qinv(p: Double, c: Double, v: Double) -> Double {
    let p0 = 0.322232421088
    let q0 = 0.993484626060e-01
    let p1 = -1.0
    let q1 = 0.588581570495
    let p2 = -0.342242088547
    let q2 = 0.531103462366
    let p3 = -0.204231210125
    let q3 = 0.103537752850
    let p4 = -0.453642210148e-04
    let q4 = 0.38560700634e-02
    let c1 = 0.8832
    let c2 = 0.2368
    let c3 = 1.214
    let c4 = 1.208
    let c5 = 1.4142
    let vmax = 120.0
    var ps: Double
    var q: Double
    var t: Double
    var yi: Double
    ps = 0.5 - 0.5 * p
    yi = sqrt (log (1.0 / (ps * ps)))
    t = yi + (((( yi * p4 + p3) * yi + p2) * yi + p1) * yi + p0) / (((( yi * q4 + q3) * yi + q2) * yi + q1) * yi + q0)
    if (v < vmax) {
        t += (t * t * t + t) / v / 4.0
    }
    q = c1 - c2 * t
    if (v < vmax) {
        q += -c3 / v + c4 * t / v
    }
    return t * (q * log (c - 1.0) + c5);
}

