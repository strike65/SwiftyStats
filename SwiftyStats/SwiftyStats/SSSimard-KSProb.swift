//
//  SSSimard-KSProb.swift
//  SwiftyStats
//
//  Swift version created by Volker Thieme on 23.07.17.
//  Original copyright see below
//

import Foundation
//
//  Simard.c
//  VTStatistics
//
//  Created by Volker Thieme on 20/10/15.
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

//#define num_Pi     3.14159265358979323846 /* PI */
//#define num_Ln2    0.69314718055994530941 /* log(2) */

/* For x close to 0 or 1, we use the exact formulae of Ruben-Gambino in all
 cases. For n <= NEXACT, we use exact algorithms: the Durbin matrix and
 the Pomeranz algorithms. For n > NEXACT, we use asymptotic methods
 except for x close to 0 where we still use the method of Durbin
 for n <= NKOLMO. For n > NKOLMO, we use asymptotic methods only and
 so the precision is less for x close to 0.
 We could increase the limit NKOLMO to 10^6 to get better precision
 for x close to 0, but at the price of a slower speed. */
fileprivate let NEXACT = 500
fileprivate let NKOLMO = 100000
fileprivate let num_Ln2 = 0.69314718055994530941

/* The Durbin matrix algorithm for the Kolmogorov-Smirnov distribution */
//static double DurbinMatrix (int n, double d);


/*========================================================================*/
//#if 0
//    
//    /* For ANSI C89 only, not for ISO C99 */
//    #define MAXI 50
//    #define EPSILON 1.0e-15
//    
//    double log1p (double x)
//{
//    /* returns a value equivalent to log(1 + x) accurate also for small x. */
//    if (fabs (x) > 0.1) {
//        return log (1.0 + x);
//    } else {
//        double term = x;
//        double sum = x;
//        int s = 2;
//        while ((fabs (term) > EPSILON * fabs (sum)) && (s < MAXI)) {
//            term *= -x;
//            sum += term / s;
//            s++;
//        }
//        return sum;
//    }
//}
//    
//    #undef MAXI
//    #undef EPSILON
//    
//#endif
//
/*========================================================================*/
fileprivate let MFACT = 30

/* The natural logarithm of factorial n! for  0 <= n <= MFACT */
fileprivate let LnFactorial: Array<Double> = [
    0,
    0,
    0.6931471805599453,
    1.791759469228055,
    3.178053830347946,
    4.787491742782046,
    6.579251212010101,
    8.525161361065415,
    10.60460290274525,
    12.80182748008147,
    15.10441257307552,
    17.50230784587389,
    19.98721449566188,
    22.55216385312342,
    25.19122118273868,
    27.89927138384088,
    30.67186010608066,
    33.50507345013688,
    36.39544520803305,
    39.33988418719949,
    42.33561646075348,
    45.3801388984769,
    48.47118135183522,
    51.60667556776437,
    54.7847293981123,
    58.00360522298051,
    61.26170176100199,
    64.55753862700632,
    67.88974313718154,
    71.257038967168,
    74.65823634883016]

/*------------------------------------------------------------------------*/

/// Returns the logarithm of n!
fileprivate func getLogFactorial(_ n: Int) -> Double {
    /* Returns the natural logarithm of factorial n! */
    if (n <= MFACT) {
        return LnFactorial[n]
        
    } else {
        let x = Double(n + 1)
        let y = 1.0 / (x * x)
        var z = ((-(5.95238095238E-4 * y) + 7.936500793651E-4) * y - 2.7777777777778E-3) * y + 8.3333333333333E-2
        z = ((x - 0.5) * log(x) - x) + 9.1893853320467E-1 + z / x
        return z
    }
}

/*------------------------------------------------------------------------*/

fileprivate func rapfac(_ n: Int) -> Double {
    /* Computes n! / n^n */
    var res = 1.0 / Double(n)
    for i:Int in 2...n {
        res *= Double(i) / Double(n)
    }
    return res
}


/*========================================================================*/


// static double **CreateMatrixD (int N, int M)

fileprivate func createMatrixD(_ N: Int, _ M: Int) -> Array<Array<Double>> {
    return Array<Array<Double>>.init(repeating: Array<Double>.init(repeating: 0.0, count: M), count: N)
}


fileprivate func DeleteMatrixD(_ T: inout Array<Array<Double>>) {
    T.removeAll()
}


/*========================================================================*/

fileprivate func KSPlusbarAsymp(_ n: Int, _ x: Double) -> Double {
    /* Compute the probability of the KS+ distribution using an asymptotic
     formula */
    let t = (6.0 * Double(n) * x + 1)
    let z = t * t / (18.0 * Double(n))
    var v = 1.0 - (2.0 * z * z - 4.0 * z - 1.0) / (18.0 * Double(n))
    if (v <= 0.0) {
        return 0.0
    }
    v = v * exp(-z)
    if (v >= 1.0) {
        return 1.0
    }
    return v
}


/*-------------------------------------------------------------------------*/

fileprivate func KSPlusbarUpper(_ n: Int, _ x: Double) -> Double {
    /* Compute the probability of the KS+ distribution in the upper tail using
     Smirnov's stable formula */
    let EPSILON = 1.0E-12
    var q:Double
    var Sum:Double = 0.0
    var term:Double
    var t:Double
    var LogCom:Double
    var LOGJMAX:Double
    var j: Int
    var jdiv: Int
    var jmax: Int = Int(Double(n) * (1.0 - x))
    if n > 200000 {
        return KSPlusbarAsymp(n, x)
    }
    
    /* Avoid log(0) for j = jmax and q ~ 1.0 */
    if (1.0 - x - Double(jmax) / Double(n) <= 0.0) {
        jmax = jmax - 1
    }
    
    if (n > 3000) {
        jdiv = 2
    }
    else {
        jdiv = 3
    }
    
    j = jmax / jdiv + 1
    LogCom = getLogFactorial(n) - getLogFactorial(j) - getLogFactorial(n - j)
    LOGJMAX = LogCom
    
    while (j <= jmax) {
        q = Double(j) / Double(n) + x
        term = LogCom + Double(j - 1) * log(q) + Double(n - j) * log1p(-q)
        t = exp(term)
        Sum = Sum + t
        LogCom += LogCom + log(Double(n - j) / Double(j + 1))
        if t <= Sum * EPSILON {
            break
        }
        j = j + 1
    }
    
    j = jmax / jdiv
    LogCom = LOGJMAX + log (Double(j + 1) / Double(n - j))
    
    while (j > 0) {
        q = Double(j) / Double(n) + x
        term = LogCom + Double(j - 1) * log(q) + Double(n - j) * log1p(-q)
        t = exp(term)
        Sum += t
        LogCom += log(Double(j) / Double(n - j + 1))
        if (t <= Sum * EPSILON) {
            break
        }
        j = j - 1
    }
    
    Sum *= x
    /* add the term j = 0 */
    Sum += exp(Double(n) * log1p(-x))
    return Sum
}


/*========================================================================*/

fileprivate func Pelz(_ n: Int, _ x: Double) -> Double {
    /* Approximating the Lower Tail-Areas of the Kolmogorov-Smirnov One-Sample
     Statistic,
     Wolfgang Pelz and I. J. Good,
     Journal of the Royal Statistical Society, Series B.
     Vol. 38, No. 2 (1976), pp. 152-156
     */
    
    let JMAX = 20
    let EPS = 1.0e-10
    let C = 2.506628274631001        /* sqrt(2*Pi) */
    let C2 = 1.2533141373155001       /* sqrt(Pi/2) */
    let PI2 = Double.pi * Double.pi
    let PI4 = PI2 * PI2
    let RACN = sqrt(Double(n))
    let z = RACN * x
    let z2 = z * z
    let z4 = z2 * z2
    let z6 = z4 * z2
    let w = PI2 / (2.0 * z * z)
    var ti: Double
    var term: Double
    var tom: Double
    var sum: Double
    var j: Int
    term = 1
    j = 0
    sum = 0
    while (j <= JMAX && term > EPS * sum) {
        ti = Double(j) + 0.5
        term = exp(-ti * ti * w)
        sum += term
        j = j + 1
    }
    sum *= C / z
    
    term = 1
    tom = 0
    j = 0
    while (j <= JMAX && fabs (term) > EPS * fabs (tom)) {
        ti = Double(j) + 0.5
        term = (PI2 * ti * ti - z2) * exp(-ti * ti * w)
        tom += term
        j = j + 1
    }
    sum += tom * C2 / (RACN * 3.0 * z4)
    
    term = 1
    tom = 0
    j = 0
    while (j <= JMAX && fabs (term) > EPS * fabs (tom)) {
        ti = Double(j) + 0.5
        term = 6 * z6 + 2 * z4 + PI2 * (2 * z4 - 5 * z2) * ti * ti +
            PI4 * (1 - 2 * z2) * ti * ti * ti * ti
        term *= exp(-ti * ti * w)
        tom += term
        j = j + 1
    }
    sum += tom * C2 / (Double(n) * 36.0 * z * z6)
    
    term = 1
    tom = 0
    j = 1
    while (j <= JMAX && term > EPS * tom) {
        ti = Double(j)
        term = PI2 * ti * ti * exp(-ti * ti * w)
        tom += term
        j = j + 1
    }
    sum -= tom * C2 / (Double(n) * 18.0 * z * z2)
    
    term = 1
    tom = 0
    j = 0
    while (j <= JMAX && fabs (term) > EPS * fabs (tom)) {
        ti = Double(j) + 0.5
        ti = ti * ti
        term = -30 * z6 - 90 * z6 * z2 + PI2 * (135 * z4 - 96 * z6) * ti +
            PI4 * (212 * z4 - 60 * z2) * ti * ti + PI2 * PI4 * ti * ti * ti * (5 -
                30 * z2)
        term *= exp(-ti * w)
        tom += term
        j = j + 1
    }
    sum += tom * C2 / (RACN * Double(n) * 3240.0 * z4 * z6)
    
    term = 1
    tom = 0
    j = 1
    while (j <= JMAX && fabs (term) > EPS * fabs (tom)) {
        ti = Double(j * j)
        term = (3.0 * PI2 * ti * z2 - PI4 * ti * ti) * exp(-ti * w)
        tom += term
        j = j + 1
    }
    sum += tom * C2 / (RACN * Double(n) * 108.0 * z6)
    return sum
}


/*=========================================================================*/

fileprivate func CalcFloorCeil (
    _ n: Int,                         /* sample size */
    _ t: Double,                      /* = nx */
    _ A: inout Array<Double>,                     /* A_i */
    _ Atflo: inout Array<Double>,                 /* floor (A_i - t) */
    _ Atcei: inout Array<Double>                  /* ceiling (A_i + t) */
)
{
    /* Precompute A_i, floors, and ceilings for limits of sums in the Pomeranz
     algorithm */
    let ell = Int(t)             /* floor (t) */
    var z: Double = t - Double(ell)            /* t - floor (t) */
    let w = ceil(t) - t
    var i: Int
    if (z > 0.5) {
        i = 2
        while i <= 2 * n + 2 {
            Atflo[i] = Double(i / 2) - 2.0 - Double(ell)
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            Atflo[i] = Double(i / 2) - 1.0 - Double(ell)
            i = i + 2
        }
        i = 2
        while i <= 2 * n + 2 {
            Atcei[i] = Double(i / 2) + Double(ell)
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            Atcei[i] = Double(i / 2) + 1 + Double(ell)
            i = i + 2
        }
        
    } else if (z > 0.0) {
        i = 1
        while i <= 2 * n + 2 {
            Atflo[i] = Double(i / 2) - 1 - Double(ell)
            i = i + 1
        }
        
        i = 2
        while i <= 2 * n + 2 {
            Atcei[i] = Double(i / 2) + Double(ell)
            i = i + 1
        }
        Atcei[1] = 1.0 + Double(ell)
        
    } else {                       /* z == 0 */
        i = 2
        while i <= 2 * n + 2 {
            Atflo[i] = Double(i / 2) - 1 - Double(ell)
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            Atflo[i] = Double(i / 2) - Double(ell)
            i = i + 2
        }
        i = 2
        while i <= 2 * n + 2 {
            Atcei[i] = Double(i / 2) - 1 + Double(ell)
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            Atcei[i] = Double(i / 2) + Double(ell)
            i = i + 2
        }
    }
    if (w < z) {
        z = w
    }
    A[0] = 0.0
    A[1] = 0.0
    A[2] = z
    A[3] = 1 - A[2]
    i = 4
    while i <= 2 * n + 1 {
        A[i] = A[i - 2] + 1.0
        i += 1
    }
    A[2 * n + 2] = Double(n)
}


/*========================================================================*/

fileprivate func Pomeranz(_ n: Int, _ x: Double) -> Double {
    /* The Pomeranz algorithm to compute the KS distribution */
    let EPS = 1.0e-15
    let ENO = 350
    let RENO = ldexp(1.0, ENO); /* for renormalization of V */
    var coreno: Int                    /* counter: how many renormalizations */
    let t = Double(n) * x
    var w:Double
    var sum:Double
    var minsum:Double
    var s: Int
    var r1: Int
    var r2: Int
    var jlow: Int
    var jup: Int
    var klow: Int
    var kup: Int
    var kup0: Int
    var A: Array<Double> = Array<Double>.init(repeating: 0.0, count: 2 * n + 3)
    var Atflo: Array<Double> = Array<Double>.init(repeating: 0.0, count: 2 * n + 3)
    var Atcei: Array<Double> = Array<Double>.init(repeating: 0.0, count: 2 * n + 3)
    var V: Array<Array<Double>>
    var H: Array<Array<Double>> /* = pow(w, j) / Factorial(j) */
    var i: Int
    var j: Int
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
    w = 2.0 * A[2] / Double(n)
    j = 1
    while j <= n + 1 {
        H[0][j] = w * H[0][j - 1] / Double(j)
        j += 1
    }
    
    H[1][0] = 1
    w = (1.0 - 2.0 * A[2]) / Double(n)
    j = 1
    while j <= n + 1 {
        H[1][j] = w * H[1][j - 1] / Double(j)
        j += 1
    }
    
    H[2][0] = 1
    w = A[2] / Double(n)
    j = 1
    while j <= n + 1 {
        H[2][j] = w * H[2][j - 1] / Double(j)
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
        jlow = 2 + Int(Atflo[i])
        if (jlow < 1) {
            jlow = 1
        }
        jup = Int(Atcei[i])
        if (jup > n + 1) {
            jup = n + 1
        }
        
        klow = 2 + Int(Atflo[i - 1])
        if (klow < 1) {
            klow = 1
        }
        kup0 = Int(Atcei[i - 1])
        
        /* Find to which case it corresponds */
        w = (A[i] - A[i - 1]) / Double(n)
        s = -1
        j = 0
        while j <= 3 {
            if (fabs(w - H[j][1]) <= EPS) {
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
        
        if (minsum < 1.0e-280) {
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
    w = getLogFactorial(n) - Double(coreno) * Double(ENO) * num_Ln2 + log(sum)
    if (w >= 0.0) {
        return 1.0
    }
    return exp(w)
}


/*========================================================================*/

fileprivate func cdfSpecial (_ n: Int, _ x: Double) -> Double {
    /* The KS distribution is known exactly for these cases */
    
    /* For nx^2 > 18, KSfbar(n, x) is smaller than 5e-16 */
    if ((Double(n) * x * x >= 18.0) || (x >= 1.0)) {
        return 1.0
    }
    
    if (x <= 0.5 / Double(n)) {
        return 0.0
    }
    
    if (n == 1) {
        return 2.0 * x - 1.0
    }

    if (x <= 1.0 / Double(n)) {
        let t = 2.0 * x * Double(n) - 1.0
        var w: Double
        if (n <= NEXACT) {
            w = rapfac(n)
            return w * pow(t, Double(n))
        }
        w = getLogFactorial(n) + Double(n) * log(t / Double(n))
        return exp(w)
    }
    
    if (x >= 1.0 - 1.0 / Double(n)) {
        return 1.0 - 2.0 * pow (1.0 - x, Double(n))
    }
    
    return -1.0
}


/*========================================================================*/

/// Computes the cdf of the Kolmogorov-Smirnov distribution (Author: Richard Simard)
public func KScdf(n: Int, x: Double) -> Double {
    let w = Double(n) * x * x
    let u = cdfSpecial(n, x)
   if (u >= 0.0) {
        return u
    }
    
    if (n <= NEXACT) {
        if (w < 0.754693) {
            return DurbinMatrix(n, x)
        }
        if (w < 4.0) {
            return Pomeranz (n, x)
        }
        return 1.0 - KSfbar(n: n, x: x)
    }
    
    if ((w * x * Double(n) <= 7.0) && (n <= NKOLMO)) {
        return DurbinMatrix (n, x)
    }
    
    return Pelz(n, x)
}


/*=========================================================================*/

fileprivate func fbarSpecial(_ n: Int, _ x: Double) -> Double {
    let w = Double(n) * x * x
    
    if ((w >= 370.0) || (x >= 1.0)) {
        return 0.0
    }
    if ((w <= 0.0274) || (x <= 0.5 / Double(n))) {
        return 1.0
    }
    if (n == 1) {
        return 2.0 - 2.0 * x
    }
    
    if (x <= 1.0 / Double(n)) {
        var z:Double
        let t = 2.0 * x * Double(n) - 1.0
        if (n <= NEXACT) {
            z = rapfac(n)
            return 1.0 - z * pow (t, Double(n))
        }
        z = getLogFactorial(n) + Double(n) * log(t / Double(n))
        return 1.0 - exp(z)
    }
    
    if (x >= 1.0 - 1.0 / Double(n)) {
        return 2.0 * pow (1.0 - x, Double(n))
    }
    return -1.0
}


/*========================================================================*/

public func KSfbar(n: Int, x: Double) -> Double {
    let w = Double(n) * x * x
    let v = fbarSpecial(n, x)
    if (v >= 0.0) {
        return v
    }
    
    if (n <= NEXACT) {
        if (w < 4.0) {
            return 1.0 - KScdf(n: n, x: x)
        }
        else {
            return 2.0 * KSPlusbarUpper(n, x)
        }
    }
    
    if (w >= 2.65) {
        return 2.0 * KSPlusbarUpper(n, x)
    }
    
    return 1.0 - KScdf(n: n, x: x)
}


/*=========================================================================
 
 The following implements the Durbin matrix algorithm and was programmed by
 G. Marsaglia, Wai Wan Tsang and Jingbo Wong.
 
 I have made small modifications in their program. (Richard Simard)
 
 
 
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

fileprivate let NORM = 1.0e140
fileprivate let INORM = 1.0e-140
fileprivate let LOGNORM = 140

fileprivate func DurbinMatrix(_ n: Int, _ d: Double) -> Double {
    var k: Int
    var m: Int
    var eH: Int
    var eQ: Int = 0
    var h: Double
    var s: Double
    var H: Array<Double>
    var Q: Array<Double>
    /* OMIT NEXT TWO LINES IF YOU REQUIRE >7 DIGIT ACCURACY IN THE RIGHT TAIL */
//    #if 0
//        s = d * d * n;
//        if (s > 7.24 || (s > 3.76 && n > 99))
//        return 1 - 2 * exp (-(2.000071 + .331 / sqrt (n) + 1.409 / n) * s);
//    #endif
    k = Int(Double(n) * d + 1.0)
    m = 2 * k - 1
    h = Double(k) - Double(n) * d
    H = Array<Double>.init(repeating: 0, count: m * m)
    Q = Array<Double>.init(repeating: 0, count: m * m)
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
        H[i * m] -= pow (h, Double(i + 1))
        H[(m - 1) * m + i] -= pow (h, Double(m - i))
    }
    H[(m - 1) * m] += (2 * h - 1 > 0 ? pow (2 * h - 1, Double(m)) : 0)
    for i in 0...m - 1 {
        for j in 0...m - 1 {
            if (i - j + 1 > 0) {
                for g in 1...i - j + 1 {
                    H[i * m + j] /= Double(g)
                }
            }
        }
    }
    eH = 0
    mPower(H, eH, &Q, &eQ, m, n);
    s = Q[(k - 1) * m + k - 1]
    for i in 1...n {
        s = s * Double(i) / Double(n)
        if (s < INORM) {
            s *= NORM
            eQ -= LOGNORM
        }
    }
    s *= pow(10.0, Double(eQ))
    H.removeAll()
    Q.removeAll()
    return s
}


/* Matrix product */
fileprivate func mMultiply(_ A: Array<Double>, _ B: Array<Double>, _ C: inout Array<Double>, _ m: Int) {
    var s: Double
    for i in 0...m - 1 {
        for j in 0...m - 1 {
        s = 0.0
            for k in 0...m - 1 {
                s += A[i * m + k] * B[k * m + j]
            }
            C[i * m + j] = s
        }
    }
}


fileprivate func renormalize(_ V: inout Array<Double>, _ m: Int, _ p: UnsafeMutablePointer<Int>) {
//    int i;
    for i in 0...m * m - 1 {
        V[i] *= INORM
    }
    p.pointee += LOGNORM
}


fileprivate func mPower(_ A: Array<Double>, _ eA: Int, _ V: inout Array<Double>, _ eV: UnsafeMutablePointer<Int>, _ m: Int, _ n: Int) {
    var B: Array<Double>
//    int eB, i;
    if (n == 1) {
        for i in 0...m * m - 1 {
            V[i] = A[i]
        }
        eV.pointee = eA
        return
    }
    mPower(A, eA, &V, eV, m, n / 2)
    B = Array<Double>.init(repeating: 0.0, count: m * m)
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


