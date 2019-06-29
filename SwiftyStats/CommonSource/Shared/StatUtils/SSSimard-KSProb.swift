//
//  SSSimard-KSProb.swift
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

//  Swift version created by strike65 on 23.07.17.
//  Original copyright see below
//

import Foundation
//
//  Simard.c
//  VTStatistics
//
//  Created by strike65 on 20/10/15.
//
//

/********************************************************************
 
 File:          KolmogorovSmirnovDist.c
 Environment:   ISO C99 or ANSI C89
 Author:        Richard Simard
 Organization:  DIRO, UniversitÃ© de MontrÃ©al
 Date:          1 February 2012
 Version        1.1

 
 
 Copyright 1 march 2010 by UniversitÃ© de MontrÃ©al,
 Richard Simard and Pierre L'Ecuyer
 =====================================================================
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 =====================================================================*/


//#include "Simard.h"
//#include <math.h>
//#include <stdlib.h>


extension Helpers {
    
    internal static func KSfbar<FPT: SSFloatingPoint & Codable>(n: Int, x: FPT) -> FPT {
        let w: FPT =  Helpers.makeFP(n) * x * x
        let v: FPT = fbarSpecial(n, x)
        if (v >= 0) {
            return v
        }
        
        if (n <= NEXACT) {
            if (w < 4) {
                return 1 - KScdf(n: n, x: x)
            }
            else {
                return 2 * KSPlusbarUpper(n, x)
            }
        }
        
        if (w >=  Helpers.makeFP(2.65)) {
            return 2 * KSPlusbarUpper(n, x)
        }
        
        return 1 - KScdf(n: n, x: x)
    }
    
    /// Computes the cdf of the Kolmogorov-Smirnov distribution (Author: Richard Simard)
    /// (Double precision)
    internal static func KScdf<FPT: SSFloatingPoint & Codable>(n: Int, x: FPT) -> FPT {
        let w =  Helpers.makeFP(n) * x * x
        let u = cdfSpecial(n, x)
        if (u >= 0) {
            return u
        }
        
        if (n <= NEXACT) {
            if (w <  Helpers.makeFP(0.754693 )) {
                return DurbinMatrix(n, x)
            }
            if (w < 4) {
                return Pomeranz (n, x)
            }
            return  Helpers.makeFP(1.0 ) - Helpers.KSfbar(n: n, x: x)
        }
        
        if ((w * x *  Helpers.makeFP(n) <= 7) && (n <= NKOLMO)) {
            return DurbinMatrix (n, x)
        }
        return Pelz(n, x)
    }
}
/* For x close to 0 or 1, we use the exact formulae of Ruben-Gambino in all
 cases. For n <= NEXACT, we use exact algorithms: the Durbin matrix and
 the Pomeranz algorithms. For n > NEXACT, we use asymptotic methods
 except for x close to 0 where we still use the method of Durbin
 for n <= NKOLMO. For n > NKOLMO, we use asymptotic methods only and
 so the precision is less for x close to 0.
 We could increase the limit NKOLMO to 10^6 to get better precision
 for x close to 0, but at the price of a slower speed. */
fileprivate let NEXACT: Int = 500
fileprivate let NKOLMO: Int = 100000

/* The Durbin matrix algorithm for the Kolmogorov-Smirnov distribution */

fileprivate func rapfac<FPT: SSFloatingPoint & Codable>(_ n: Int) -> FPT {
    /* Computes n! / n^n */
    var res: FPT = 1 / ( Helpers.makeFP(n))
    for i:Int in 2...n {
        res *=  Helpers.makeFP(i) /  Helpers.makeFP(n)
    }
    return res
}

fileprivate func createMatrixD<FPT: SSFloatingPoint & Codable>(_ N: Int, _ M: Int) -> Array<Array<FPT>> {
    return Array<Array<FPT>>.init(repeating: Array<FPT>.init(repeating:  Helpers.makeFP(0.0), count: M), count: N)
}

fileprivate func DeleteMatrixD<FPT: SSFloatingPoint & Codable>(_ T: inout Array<Array<FPT>>) {
    T.removeAll()
}

fileprivate func KSPlusbarAsymp<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    /* Compute the probability of the KS+ distribution using an asymptotic
     formula */
    let t: FPT = (6 * ( Helpers.makeFP(n)) * x + 1)
    let z: FPT = t * t / (18 * ( Helpers.makeFP(n)))
    let ex1: FPT = (2 * z * z)
    let ex2: FPT = ex1 - 4 * z - 1
    var v: FPT = 1 - ex2 / (18 * ( Helpers.makeFP(n)))
    if (v <= 0) {
        return 0
    }
    v = v * SSMath.exp1(-z)
    if (v >= 1) {
        return 1
    }
    return v
}

fileprivate func KSPlusbarUpper<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    /* Compute the probability of the KS+ distribution in the upper tail using
     Smirnov's stable formula */
    let EPSILON: FPT =  Helpers.makeFP(1.0E-12)
    var q:FPT
    var Sum:FPT = 0
    var term:FPT
    var t:FPT
    var LogCom:FPT
    var LOGJMAX:FPT
    var j: Int
    var jdiv: Int
    var jmax: Int = Helpers.integerValue(( Helpers.makeFP(n)) * (1 - x))
    if n > 200000 {
        return KSPlusbarAsymp(n, x)
    }
    
    /* Avoid log(0) for j = jmax and q ~ 1.0 */
    var ex1: FPT
    var ex2: FPT
    var ex3: FPT
    ex1 =  Helpers.makeFP(jmax) /  Helpers.makeFP(n)
    ex2 = x - ex1
    ex3 = FPT.one - ex2
    if (ex3 <= 0) {
        jmax = jmax - 1
    }
    
    if (n > 3000) {
        jdiv = 2
    }
    else {
        jdiv = 3
    }
    
    j = jmax / jdiv + 1
    LogCom = SSMath.logFactorial(n) - SSMath.logFactorial(j) - SSMath.logFactorial(n - j)
    LOGJMAX = LogCom
    
    while (j <= jmax) {
        q =  Helpers.makeFP(j) /  Helpers.makeFP(n) + x
        ex1 =  Helpers.makeFP(n - j) * SSMath.log1p1(-q)
        ex2 =  Helpers.makeFP(j - 1) * SSMath.log1(q)
        ex3 = LogCom + ex2
        term = ex3 + ex1
        t = SSMath.exp1(term)
        Sum = Sum + t
        ex1 = Helpers.makeFP(j + 1)
        ex2 = Helpers.makeFP(n - j)
        ex3 = ex2 / ex1
        LogCom += SSMath.log1(ex3)
        if t <= Sum * EPSILON {
            break
        }
        j = j + 1
    }
    
    j = jmax / jdiv
    LogCom = LOGJMAX + SSMath.log1( Helpers.makeFP(j + 1) /  Helpers.makeFP(n - j))
    
    while (j > 0) {
        q =  Helpers.makeFP(j) /  Helpers.makeFP(n) + x
        ex1 =  Helpers.makeFP(n - j) * SSMath.log1p1(-q)
        ex2 =  Helpers.makeFP(j - 1) * SSMath.log1(q)
        ex3 = LogCom + ex2
        term = ex3 + ex1
        t = SSMath.exp1(term)
        Sum += t
        LogCom += SSMath.log1( Helpers.makeFP(j) /  Helpers.makeFP(n - j + 1))
        if (t <= Sum * EPSILON) {
            break
        }
        j = j - 1
    }
    
    Sum *= x
    /* add the term j = 0 */
    Sum += SSMath.exp1( Helpers.makeFP(n) * SSMath.log1p1(-x))
    return Sum
}


fileprivate func Pelz<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    /* Approximating the Lower Tail-Areas of the Kolmogorov-Smirnov One-Sample
     Statistic,
     Wolfgang Pelz and I. J. Good,
     Journal of the Royal Statistical Society, Series B.
     Vol. 38, No. 2 (1976), pp. 152-156
     */
    
    let JMAX: Int = 20
    let EPS: FPT =  Helpers.makeFP(1.0e-10)
    let C: FPT = FPT.sqrt2pi
    let C2: FPT = FPT.sqrtpihalf
    let PI2: FPT =  FPT.pisquared
    let PI4: FPT = PI2 * PI2
    let RACN: FPT = sqrt( Helpers.makeFP(n))
    let z: FPT = RACN * x
    let z2: FPT = z * z
    let z4: FPT = z2 * z2
    let z6: FPT = z4 * z2
    let w: FPT = PI2 / (2 * z * z)
    var ti: FPT
    var term: FPT
    var tom: FPT
    var sum: FPT
    var j: Int
    var ex1: FPT
    var ex2: FPT
    var ex3: FPT
    var ex4: FPT
    var ex5: FPT
    var ex6: FPT
    var ex7: FPT
    var ex8: FPT
    var ex9: FPT
    term = 1
    j = 0
    sum = 0
    while (j <= JMAX && term > EPS * sum) {
        ti =  Helpers.makeFP(j) + FPT.half
        term = SSMath.exp1(-ti * ti * w)
        sum += term
        j = j + 1
    }
    sum *= C / z
    
    term = 1
    tom = 0
    j = 0
    while (j <= JMAX && abs(term) > EPS * abs(tom)) {
        ti =  Helpers.makeFP(j) + FPT.half
        ex1 = ti * ti - z2
        ex2 = -ti * ti * w
        term = (PI2 * ex1) * SSMath.exp1(ex2)
        tom += term
        j = j + 1
    }
    ex1 = RACN * 3 * z4
    ex2 = C2 / ex1
    sum += tom * ex2
    
    term = 1
    tom = 0
    j = 0
    while (j <= JMAX && abs (term) > EPS * abs (tom)) {
        ti =  Helpers.makeFP(j) +  Helpers.makeFP(0.5 )
        ex1 = 6 * z6 + 2 * z4
        ex2 = 2 * z4 - 5 * z2
        ex3 = 1 - 2 * z2
        ex4 = ti * ti * ti * ti  /* use SSMath.pow1(ti, 4) ? */
        ex5 = ti * ti
        ex6 = PI2 * ex2
        let ex7: FPT = ex1 + ex6 * ex5
        let ex8: FPT = PI4 * ex3 * ex4
        term = ex7 + ex8
        term *= SSMath.exp1(-ti * ti * w)
        tom += term
        j = j + 1
    }
    ex1 =  Helpers.makeFP(36) * z
    ex2 = ex1 * z6
    ex3 =  Helpers.makeFP(n) * ex2
    ex4 = C2 / ex3
    sum = sum + (tom * ex4)
    term = 1
    tom = 0
    j = 1
    while (j <= JMAX && term > EPS * tom) {
        ti =  Helpers.makeFP(j)
        ex1 = ti * ti
        ex2 = -ex1 * w
        ex4 = PI2 * ex1
        term = ex4 * SSMath.exp1(ex2)
        tom += term
        j = j + 1
    }
    ex1 =  Helpers.makeFP(18) * z
    ex2 = ex1 * z2
    ex3 =  Helpers.makeFP(n) * ex2
    ex4 = C2 / ex3
    sum = sum - (tom * ex4)
    term = 1
    tom = 0
    j = 0
    while (j <= JMAX && abs(term) > EPS * abs(tom)) {
        ti =  Helpers.makeFP(j) +  Helpers.makeFP(0.5 )
        ti = ti * ti
        ex1 = -30 * z6 - 90 * z6 * z2
        ex2 = (135 * z4 - 96 * z6)
        ex3 = (212 * z4 - 60 * z2)
        ex4 = PI2 * PI4 * ti * ti * ti
        ex5 = (5 - 30 * z2)
        ex6 = PI4 * ex3
        ex7 = ex6 * ti
        ex8 = ex7 * ti
        ex9 = ex8 + (ex4 * ex5)
        term = ex1 + PI2 * ex2 * ti + ex9
        term *= SSMath.exp1(-ti * w)
        tom += term
        j = j + 1
    }
    ex1 =  Helpers.makeFP(3240) * z4
    ex2 = ex1 * z6
    ex3 =  Helpers.makeFP(n) * ex2
    ex4 = RACN * ex3
    ex5 = C2 / ex4
    sum = sum + (tom * ex5)
    term = 1
    tom = 0
    j = 1
    while (j <= JMAX && abs (term) > EPS * abs(tom)) {
        ti =  Helpers.makeFP(j * j)
        ex1 = 3 * PI2 * ti * z2
        ex2 = PI4 * ti * ti
        ex3 = -ti * w
        term = (ex1 - ex2) * SSMath.exp1(ex3)
        tom += term
        j = j + 1
    }
    ex1 = RACN *  Helpers.makeFP(n)
    ex2 = ex1 * 108 * z6
    ex3 = C2 / ex2
    ex4 = tom * ex3
    sum = sum + ex4
    return sum
}


/*=========================================================================*/

fileprivate func CalcFloorCeil<FPT: SSFloatingPoint & Codable> (
    _ n: Int,                         /* sample size */
    _ t: FPT,                      /* = nx */
    _ A: inout Array<FPT>,                     /* A_i */
    _ Atflo: inout Array<FPT>,                 /* floor (A_i - t) */
    _ Atcei: inout Array<FPT>                  /* ceiling (A_i + t) */
)
{
    /* Precompute A_i, floors, and ceilings for limits of sums in the Pomeranz
     algorithm */
    let ell: Int = Helpers.integerValue(t)             /* floor (t) */
    var z: FPT = t - ( Helpers.makeFP(ell))             /* t - floor (t) */
    let w = ceil(t) - t
    var i: Int
    var ii: FPT
    if (z >  Helpers.makeFP(0.5 )) {
        i = 2
        while i <= 2 * n + 2 {
            Atflo[i] =  Helpers.makeFP(i / 2) - 2 -  Helpers.makeFP(ell)
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            Atflo[i] =  Helpers.makeFP(i / 2) - 1 -  Helpers.makeFP(ell)
            i = i + 2
        }
        i = 2
        while i <= 2 * n + 2 {
            ii =  Helpers.makeFP(i)
            Atcei[i] = ( Helpers.makeFP(ii / 2) +  Helpers.makeFP(ell))
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            ii =  Helpers.makeFP(i)
            Atcei[i] = ( Helpers.makeFP(ii / 2) + 1 +  Helpers.makeFP(ell))
            i = i + 2
        }
        
    } else if (z > 0) {
        i = 1
        while i <= 2 * n + 2 {
            ii =  Helpers.makeFP(i)
            Atflo[i] = ( Helpers.makeFP(ii / 2) - 1 -  Helpers.makeFP(ell))
            i = i + 1
        }
        
        i = 2
        while i <= 2 * n + 2 {
            ii =  Helpers.makeFP(i)
            Atcei[i] = ( Helpers.makeFP(ii / 2) +  Helpers.makeFP(ell))
            i = i + 1
        }
        Atcei[1] = (1 +  Helpers.makeFP(ell))
        
    } else {                       /* z == 0 */
        i = 2
        while i <= 2 * n + 2 {
            ii =  Helpers.makeFP(i)
            Atflo[i] = ( Helpers.makeFP(ii / 2) - 1 -  Helpers.makeFP(ell))
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            ii =  Helpers.makeFP(i)
            Atflo[i] = ( Helpers.makeFP(ii / 2) -  Helpers.makeFP(ell))
            i = i + 2
        }
        i = 2
        while i <= 2 * n + 2 {
            ii =  Helpers.makeFP(i)
            Atcei[i] = ( Helpers.makeFP(ii / 2) - 1 +  Helpers.makeFP(ell))
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            ii =  Helpers.makeFP(i)
            Atcei[i] = ( Helpers.makeFP(ii / 2) +  Helpers.makeFP(ell))
            i = i + 2
        }
    }
    if (w < z) {
        z = w
    }
    A[0] = 0
    A[1] = 0
    A[2] = z
    A[3] = 1 - A[2]
    i = 4
    while i <= 2 * n + 1 {
        A[i] = A[i - 2] + 1
        i += 1
    }
    A[2 * n + 2] =  Helpers.makeFP(n)
}

fileprivate func Pomeranz<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    /* The Pomeranz algorithm to compute the KS distribution */
    let EPS: FPT =  Helpers.makeFP(1.0e-15)
    let ENO = 350
    let RENO: FPT = scalbn(1, ENO); /* for renormalization of V */
    var coreno: Int                    /* counter: how many renormalizations */
    let t =  Helpers.makeFP(n) * x
    var w:FPT
    var sum:FPT
    var minsum:FPT
    var s: Int
    var r1: Int
    var r2: Int
    var jlow: Int
    var jup: Int
    var klow: Int
    var kup: Int
    var kup0: Int
    var A: Array<FPT> = Array<FPT>.init(repeating:  Helpers.makeFP(0.0), count: 2 * n + 3)
    var Atflo: Array<FPT> = Array<FPT>.init(repeating:  Helpers.makeFP(0.0), count: 2 * n + 3)
    var Atcei: Array<FPT> = Array<FPT>.init(repeating:  Helpers.makeFP(0.0), count: 2 * n + 3)
    var V: Array<Array<FPT>>
    var H: Array<Array<FPT>> /* = pow(w, j) / Factorial(j) */
    var i: Int
    var j: Int
    var ex1: FPT
    var ex2: FPT
    var ex3: FPT
    V = createMatrixD(2, n + 2)
    H = createMatrixD(4, n + 2)
    
    CalcFloorCeil(n, t, &A, &Atflo, &Atcei)
    j = 1
    while j <= n + 1 {
        V[0][j] = 0
        j += 1
    }
    j = 2
    while j <= n + 1 {
        V[1][j] = 0
        j += 1
    }
    V[1][1] = RENO
    coreno = 1
    
    /* Precompute H[][] = (A[j] - A[j-1]^k / k! for speed */
    H[0][0] = 1
    w = 2 * A[2] /  Helpers.makeFP(n)
    j = 1
    while j <= n + 1 {
        H[0][j] = w * H[0][j - 1] /  Helpers.makeFP(j)
        j += 1
    }
    
    H[1][0] = 1
    w = (1 - 2 * A[2]) /  Helpers.makeFP(n)
    j = 1
    while j <= n + 1 {
        H[1][j] = w * H[1][j - 1] /  Helpers.makeFP(j)
        j += 1
    }
    
    H[2][0] = 1
    w = A[2] /  Helpers.makeFP(n)
    j = 1
    while j <= n + 1 {
        H[2][j] = w * H[2][j - 1] /  Helpers.makeFP(j)
        j += 1
    }
    
    H[3][0] = 1
    j = 1
    while j <= n + 1 {
        H[3][j] = 0
        j += 1
    }
    
    r1 = 0
    r2 = 1
    i = 2
    while (i <= 2 * n + 2) {
        jlow = 2 + Helpers.integerValue(Atflo[i])
        if (jlow < 1) {
            jlow = 1
        }
        jup = Helpers.integerValue(Atcei[i])
        if (jup > n + 1) {
            jup = n + 1
        }
        
        klow = 2 + Helpers.integerValue(Atflo[i - 1])
        if (klow < 1) {
            klow = 1
        }
        kup0 = Helpers.integerValue(Atcei[i - 1])
        
        /* Find to which case it corresponds */
        w = (A[i] - A[i - 1]) /  Helpers.makeFP(n)
        s = -1
        j = 0
        while j <= 3 {
            if (abs(w - H[j][1]) <= EPS) {
                s = j
                break
            }
            j += 1
        }
        /* assert (s >= 0, "Pomeranz: s < 0"); */
        
        minsum = RENO
        r1 = (r1 + 1) & 1          /* i - 1 */
        r2 = (r2 + 1) & 1          /* i */
        j = jlow
        while j <= jup {
            kup = kup0
            if (kup > j) {
                kup = j
            }
            sum = 0
            var k = kup
            while k >= klow {
                sum += V[r1][k] * H[s][j - k]
                k -= 1
            }
            V[r2][j] = sum
            if (sum < minsum) {
                minsum = sum
            }
            j += 1
        }
        
        if (minsum <  Helpers.makeFP(1.0e-280)) {
            /* V is too small: renormalize to avoid underflow of probabilities */
            j = jlow
            while j <= jup {
                V[r2][j] *= RENO
                j += 1
            }
            coreno = coreno + 1                /* keep track of log of RENO */
        }
        i += 1
    }
    
    sum = V[r2][n + 1]
    A.removeAll()
    Atflo.removeAll()
    Atcei.removeAll()
    DeleteMatrixD(&H)
    DeleteMatrixD(&V)
    ex1 = Helpers.makeFP(coreno) *  Helpers.makeFP(ENO)
    ex2 = ex1 * FPT.ln2
    ex3 = SSMath.logFactorial(n) - ex2
    w = ex3 + SSMath.log1(sum)
    if (w >= 0) {
        return 1
    }
    return SSMath.exp1(w)
}

fileprivate func cdfSpecial<FPT: SSFloatingPoint & Codable> (_ n: Int, _ x: FPT) -> FPT {
    /* The KS distribution is known exactly for these cases */
    
    /* For nx^2 > 18, KSfbar(n, x) is smaller than 5e-16 */
    if (( Helpers.makeFP(n) * x * x >= 18) || (x >= 1)) {
        return 1
    }
    
    if (x <=  Helpers.makeFP(0.5 ) /  Helpers.makeFP(n)) {
        return 0
    }
    
    if (n == 1) {
        return 2 * x - 1
    }

    if (x <= 1 /  Helpers.makeFP(n)) {
        let t: FPT = 2 * x *  Helpers.makeFP(n) - 1
        var w: FPT
        if (n <= NEXACT) {
            w = rapfac(n)
            return w * SSMath.pow1(t,  Helpers.makeFP(n))
        }
        w = SSMath.logFactorial(n) +  Helpers.makeFP(n) * SSMath.log1(t /  Helpers.makeFP(n))
        return SSMath.exp1(w)
    }
    
    if (x >=  Helpers.makeFP(1.0 ) -  Helpers.makeFP(1.0 ) /  Helpers.makeFP(n)) {
        return 1 - 2 * SSMath.pow1(1 - x,  Helpers.makeFP(n))
    }
    return -1
}

fileprivate func fbarSpecial<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    let w =  Helpers.makeFP(n) * x * x
    
    if ((w >= 370) || (x >= 1)) {
        return 0
    }
    if ((w <=  Helpers.makeFP(0.0274 )) || (x <=  Helpers.makeFP(0.5 ) /  Helpers.makeFP(n))) {
        return 1
    }
    if (n == 1) {
        return  Helpers.makeFP(2.0 ) - 2 * x
    }
    
    if (x <= 1 /  Helpers.makeFP(n)) {
        var z:FPT
        let t = 2 * x *  Helpers.makeFP(n) - 1
        if (n <= NEXACT) {
            z = rapfac(n)
            return 1 - z * SSMath.pow1(t,  Helpers.makeFP(n))
        }
        z = SSMath.logFactorial(n) +  Helpers.makeFP(n) * SSMath.log1(t /  Helpers.makeFP(n))
        return  Helpers.makeFP(1.0 ) - SSMath.exp1(z)
    }
    
    if (x >=  Helpers.makeFP(1.0 ) - 1 /  Helpers.makeFP(n)) {
        return 2 * SSMath.pow1(1 - x,  Helpers.makeFP(n))
    }
    return -1
}

/*=========================================================================
 
 The following implements the Durbin matrix algorithm and was programmed by
 G. Marsaglia, Wai Wan Tsang and Jingbo Wong.
 
 I have made small modifications in their program. (Richard Simard)
 Adapted to Generic FP Type
 
 
 =========================================================================*/

/*
 The C program to compute Kolmogorov's distribution
 
 K(n,d) = Prob(D_n < d),         where
 
 D_n = max(x_1-0/n,x_2-1/n...,x_n-(n-1)/n,1/n-x_1,2/n-x_2,...,n/n-x_n)
 
 with  x_1<x_2,...<x_n  a purported set of n independent uniform [0,1)
 random variables sorted into increasing order.
 See G. Marsaglia, Wai Wan Tsang and Jingbo Wong,
 J.Stat.Software, 8, 18, pp 1--4, (2003).
 */

fileprivate func DurbinMatrix<FPT: SSFloatingPoint & Codable>(_ n: Int, _ d: FPT) -> FPT {
    let NORM: FPT =  Helpers.makeFP(1.0e140)
    let INORM: FPT =  Helpers.makeFP(1.0e-140)
    let LOGNORM = 140
    var k: Int
    var m: Int
    var eH: Int
    var eQ: Int = 0
    var h: FPT
    var s: FPT
    var H: Array<FPT>
    var Q: Array<FPT>
    /* OMIT NEXT TWO LINES IF YOU REQUIRE >7 DIGIT ACCURACY IN THE RIGHT TAIL */
//    #if 0
//        s = d * d * n;
//        if (s > 7.24 || (s > 3.76 && n > 99))
//        return 1 - 2 * exp (-(2.000071 + .331 / sqrt (n) + 1.409 / n) * s);
//    #endif
    k = Helpers.integerValue( Helpers.makeFP(n) * d + 1)
    m = 2 * k - 1
    h =  Helpers.makeFP(k) -  Helpers.makeFP(n) * d
    H = Array<FPT>.init(repeating:  Helpers.makeFP(0.0), count: m * m)
    Q = Array<FPT>.init(repeating:  Helpers.makeFP(0.0), count: m * m)
    for i in 0...m - 1 {
        for j in 0...m - 1 {
            if (i - j + 1 < 0) {
                H[i * m + j] = 0
            }
            else {
                H[i * m + j] = 1
            }
        }
    }
    for i in 0...m - 1 {
        H[i * m] -= SSMath.pow1(h,  Helpers.makeFP(i + 1))
        H[(m - 1) * m + i] -= SSMath.pow1(h,  Helpers.makeFP(m - i))
    }
    let test: FPT = 2 * h - 1
    if test > 0 {
        H[(m - 1) * m] += SSMath.pow1(2 * h - 1,  Helpers.makeFP(m))
    }
    else {
        H[(m - 1) * m] += 0
    }
    for i in 0...m - 1 {
        for j in 0...m - 1 {
            if (i - j + 1 > 0) {
                for g in 1...i - j + 1 {
                    H[i * m + j] /=  Helpers.makeFP(g)
                }
            }
        }
    }
    eH = 0
    mPower(H, eH, &Q, &eQ, m, n);
    s = Q[(k - 1) * m + k - 1]
    for i in 1...n {
        s = s *  Helpers.makeFP(i) /  Helpers.makeFP(n)
        if (s < INORM) {
            s *= NORM
            eQ -= LOGNORM
        }
    }
    s *= SSMath.pow1(10,  Helpers.makeFP(eQ))
    H.removeAll()
    Q.removeAll()
    return s
}


/* Matrix product */
fileprivate func mMultiply<FPT: SSFloatingPoint & Codable>(_ A: Array<FPT>, _ B: Array<FPT>, _ C: inout Array<FPT>, _ m: Int) {
    var s: FPT
    for i in 0...m - 1 {
        for j in 0...m - 1 {
        s = 0
            for k in 0...m - 1 {
                s += A[i * m + k] * B[k * m + j]
            }
            C[i * m + j] = s
        }
    }
}


fileprivate func renormalize<FPT: SSFloatingPoint & Codable>(_ V: inout Array<FPT>, _ m: Int, _ p: UnsafeMutablePointer<Int>) {
    let INORM: FPT =  Helpers.makeFP(1.0e-140)
    let LOGNORM = 140
    for i in 0...m * m - 1 {
        V[i] *= INORM
    }
    p.pointee += LOGNORM
}


fileprivate func mPower<FPT: SSFloatingPoint & Codable>(_ A: Array<FPT>, _ eA: Int, _ V: inout Array<FPT>, _ eV: UnsafeMutablePointer<Int>, _ m: Int, _ n: Int) {
    var B: Array<FPT>
    let NORM: FPT =  Helpers.makeFP(1.0e140)
    if (n == 1) {
        for i in 0...m * m - 1 {
            V[i] = A[i]
        }
        eV.pointee = eA
        return
    }
    mPower(A, eA, &V, eV, m, n / 2)
    B = Array<FPT>.init(repeating:  Helpers.makeFP(0.0), count: m * m)
    mMultiply(V, V, &B, m)
    var eB: Int = 2 * eV.pointee
    if (B[(m / 2) * m + (m / 2)] > NORM) {
        renormalize(&B, m, &eB)
    }
    
    if (n % 2 == 0) {
        for i in 0...m * m - 1 {
            V[i] = B[i]
        }
        eV.pointee = eB
    } else {
        mMultiply(A, B, &V,  m)
        eV.pointee = eA + eB
    }
    
    if (V[(m / 2) * m + (m / 2)] > NORM) {
        renormalize(&V, m, eV)
    }
    B.removeAll()
}


