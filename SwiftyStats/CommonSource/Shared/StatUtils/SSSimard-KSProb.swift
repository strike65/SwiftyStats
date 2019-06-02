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
fileprivate let NEXACT: Int = 500
fileprivate let NKOLMO: Int = 100000
//fileprivate let num_Ln2 = 0.69314718055994530941

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
/*
fileprivate let MFACT = 120
/* The natural logarithm of factorial n! for  0 <= n <= MFACT */
fileprivate let LnFactorial: Array<Double> = [
0,0,0.693147180559945309417,1.79175946922805500081,3.17805383034794561965,4.78749174278204599425,6.57925121201010099506,8.52516136106541430017,10.6046029027452502284,12.8018274800814696112,15.1044125730755152952,17.5023078458738858393,19.9872144956618861495,22.5521638531234228856,25.1912211827386815001,27.8992713838408915661,30.6718601060806728038,33.5050734501368888840,36.3954452080330535762,39.3398841871994940362,42.3356164607534850297,45.3801388984769080262,48.4711813518352238796,51.6066755677643735704,54.7847293981123191901,58.0036052229805199393,61.2617017610020019848,64.5575386270063310590,67.8897431371815349829,71.2570389671680090101,74.6582363488301643855,78.0922235533153106314,81.5579594561150371785,85.0544670175815174140,88.5808275421976788036,92.1361756036870924833,95.7196945421432024850,99.3306124547874269293,102.968198614513812699,106.631760260643459126,110.320639714757395429,114.034211781461703233,117.771881399745071539,121.533081515438633962,125.317271149356895125,129.123933639127214883,132.952575035616309883,136.802722637326368470,140.673923648234259399,144.565743946344886009,148.477766951773032068,152.409592584497357839,156.360836303078785194,160.331128216630907028,164.320112263195181412,168.327445448427652330,172.352797139162801564,176.395848406997351715,180.456291417543771052,184.533828861449490502,188.628173423671591187,192.739047287844902436,196.866181672889993991,201.009316399281526679,205.168199482641198536,209.342586752536835646,213.532241494563261191,217.736934113954227251,221.956441819130333950,226.190548323727593332,230.439043565776952321,234.701723442818267743,238.978389561834323054,243.268849002982714183,247.572914096186883937,251.890402209723194377,256.221135550009525456,260.564940971863209305,264.921649798552801042,269.291097651019822536,273.673124285693704149,278.067573440366142914,282.474292687630396027,286.893133295426993951,291.323950094270307566,295.766601350760624021,300.220948647014131754,304.686856765668715473,309.164193580146921945,313.652829949879061783,318.152639620209326850,322.663499126726176891,327.185287703775217201,331.717887196928473138,336.261181979198477034,340.815058870799017869,345.379407062266854107,349.954118040770236930,354.539085519440808849,359.134205369575398776,363.739375555563490144,368.354496072404749595,372.979468885689020676,377.614197873918656447,382.258588773060029111,386.912549123217552482,391.575988217329619626,396.248817051791525799,400.930948278915745492,405.622296161144889192,410.322776526937305421,415.032306728249639556,419.750805599544734099,424.478193418257074668,429.214391866651570128,433.959323995014820194,438.712914186121184840,443.475088120918940959,448.245772745384605719,453.024896238496135104,457.812387981278181098]

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
*/
/*------------------------------------------------------------------------*/

fileprivate func rapfac<FPT: SSFloatingPoint & Codable>(_ n: Int) -> FPT {
    /* Computes n! / n^n */
    var res: FPT = 1 / (makeFP(n))
    for i:Int in 2...n {
        res *= makeFP(i) / makeFP(n)
    }
    return res
}


/*========================================================================*/


// static double **CreateMatrixD (int N, int M)

fileprivate func createMatrixD<FPT: SSFloatingPoint & Codable>(_ N: Int, _ M: Int) -> Array<Array<FPT>> {
    return Array<Array<FPT>>.init(repeating: Array<FPT>.init(repeating: makeFP(0.0), count: M), count: N)
}


fileprivate func DeleteMatrixD<FPT: SSFloatingPoint & Codable>(_ T: inout Array<Array<FPT>>) {
    T.removeAll()
}


/*========================================================================*/

fileprivate func KSPlusbarAsymp<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    /* Compute the probability of the KS+ distribution using an asymptotic
     formula */
    let t: FPT = (6 * (makeFP(n)) * x + 1)
    let z: FPT = t * t / (18 * (makeFP(n)))
    let ex1: FPT = (2 * z * z)
    let ex2: FPT = ex1 - 4 * z - 1
    var v: FPT = 1 - ex2 / (18 * (makeFP(n)))
    if (v <= 0) {
        return 0
    }
    v = v * exp1(-z)
    if (v >= 1) {
        return 1
    }
    return v
}


/*-------------------------------------------------------------------------*/

fileprivate func KSPlusbarUpper<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    /* Compute the probability of the KS+ distribution in the upper tail using
     Smirnov's stable formula */
    let EPSILON: FPT = makeFP(1.0E-12)
    var q:FPT
    var Sum:FPT = 0
    var term:FPT
    var t:FPT
    var LogCom:FPT
    var LOGJMAX:FPT
    var j: Int
    var jdiv: Int
    var jmax: Int = integerValue((makeFP(n)) * (1 - x))
    if n > 200000 {
        return KSPlusbarAsymp(n, x)
    }
    
    /* Avoid log(0) for j = jmax and q ~ 1.0 */
    if (1 - x - makeFP(jmax) / makeFP(n) <= 0) {
        jmax = jmax - 1
    }
    
    if (n > 3000) {
        jdiv = 2
    }
    else {
        jdiv = 3
    }
    
    j = jmax / jdiv + 1
    LogCom = logFactorial(n) - logFactorial(j) - logFactorial(n - j)
    LOGJMAX = LogCom
    
    while (j <= jmax) {
        q = makeFP(j) / makeFP(n) + x
        term = LogCom + makeFP(j - 1) * log1(q) + makeFP(n - j) * log1p1(-q)
        t = exp1(term)
        Sum = Sum + t
        LogCom += LogCom + log1(makeFP(n - j) / makeFP(j + 1))
        if t <= Sum * EPSILON {
            break
        }
        j = j + 1
    }
    
    j = jmax / jdiv
    LogCom = LOGJMAX + log1(makeFP(j + 1) / makeFP(n - j))
    
    while (j > 0) {
        q = makeFP(j) / makeFP(n) + x
        term = LogCom + makeFP(j - 1) * log1(q) + makeFP(n - j) * log1p1(-q)
        t = exp1(term)
        Sum += t
        LogCom += log1(makeFP(j) / makeFP(n - j + 1))
        if (t <= Sum * EPSILON) {
            break
        }
        j = j - 1
    }
    
    Sum *= x
    /* add the term j = 0 */
    Sum += exp1(makeFP(n) * log1p1(-x))
    return Sum
}


/*========================================================================*/

fileprivate func Pelz<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    /* Approximating the Lower Tail-Areas of the Kolmogorov-Smirnov One-Sample
     Statistic,
     Wolfgang Pelz and I. J. Good,
     Journal of the Royal Statistical Society, Series B.
     Vol. 38, No. 2 (1976), pp. 152-156
     */
    
    let JMAX: Int = 20
    let EPS: FPT = makeFP(1.0e-10)
    let C: FPT = FPT.sqrt2pi   /* 2.506628274631001        sqrt(2*Pi) */
    let C2: FPT = FPT.sqrtpihalf              /* 1.2533141373155001      sqrt(Pi/2) */
    let PI2: FPT =  FPT.pisquared
    let PI4: FPT = PI2 * PI2
    let RACN: FPT = sqrt(makeFP(n))
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
    term = 1
    j = 0
    sum = 0
    while (j <= JMAX && term > EPS * sum) {
        ti = makeFP(j) + FPT.half
        term = exp1(-ti * ti * w)
        sum += term
        j = j + 1
    }
    sum *= C / z
    
    term = 1
    tom = 0
    j = 0
    var ex1, ex2, ex3, ex4, ex5, ex6: FPT
    while (j <= JMAX && abs(term) > EPS * abs(tom)) {
        ti = makeFP(j) + FPT.half
        ex1 = ti * ti - z2
        ex2 = -ti * ti * w
        term = (PI2 * ex1) * exp1(ex2)
        tom += term
        j = j + 1
    }
    sum += tom * C2 / (RACN * 3 * z4)
    
    term = 1
    tom = 0
    j = 0
    while (j <= JMAX && abs (term) > EPS * abs (tom)) {
        ti = makeFP(j) + makeFP(0.5 )
        ex1 = 6 * z6 + 2 * z4
        ex2 = 2 * z4 - 5 * z2
        ex3 = 1 - 2 * z2
        ex4 = ti * ti * ti * ti  /* use pow1(ti, 4) ? */
        ex5 = ti * ti
        ex6 = PI2 * ex2
        let ex7: FPT = ex1 + ex6 * ex5
        let ex8: FPT = PI4 * ex3 * ex4
        term = ex7 + ex8
//        term = ex1 + PI2 * ex2 * ti * ti + PI4 * ex3 * ex4
        term *= exp1(-ti * ti * w)
        tom += term
        j = j + 1
    }
    sum += tom * C2 / (makeFP(n) * 36 * z * z6)
    
    term = 1
    tom = 0
    j = 1
    while (j <= JMAX && term > EPS * tom) {
        ti = makeFP(j)
        term = PI2 * ti * ti * exp1(-ti * ti * w)
        tom += term
        j = j + 1
    }
    sum -= tom * C2 / (makeFP(n) * 18 * z * z2)
    
    term = 1
    tom = 0
    j = 0
    while (j <= JMAX && abs(term) > EPS * abs(tom)) {
        ti = makeFP(j) + makeFP(0.5 )
        ti = ti * ti
        ex1 = -30 * z6 - 90 * z6 * z2
        ex2 = (135 * z4 - 96 * z6)
        ex3 = (212 * z4 - 60 * z2)
        ex4 = PI2 * PI4 * ti * ti * ti
        ex5 = (5 - 30 * z2)
        ex6 = PI4 * ex3 * ti * ti + ex4 * ex5
        term = ex1 + PI2 * ex2 * ti + ex6
        term *= exp1(-ti * w)
        tom += term
        j = j + 1
    }
    sum += tom * C2 / (RACN * makeFP(n) * 3240 * z4 * z6)
    
    term = 1
    tom = 0
    j = 1
    while (j <= JMAX && abs (term) > EPS * abs(tom)) {
        ti = makeFP(j * j)
        ex1 = 3 * PI2 * ti * z2
        ex2 = PI4 * ti * ti
        ex3 = -ti * w
        term = (ex1 - ex2) * exp1(ex3)
//        term = (3 * PI2 * ti * z2 - PI4 * ti * ti) * exp1(-ti * w)
        tom += term
        j = j + 1
    }
    sum += tom * C2 / (RACN * makeFP(n) * 108 * z6)
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
    let ell: Int = integerValue(t)             /* floor (t) */
    var z: FPT = t - (makeFP(ell))             /* t - floor (t) */
    let w = ceil(t) - t
    var i: Int
    var ii: FPT
    if (z > makeFP(0.5 )) {
        i = 2
        while i <= 2 * n + 2 {
            Atflo[i] = makeFP(i / 2) - 2 - makeFP(ell)
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            Atflo[i] = makeFP(i / 2) - 1 - makeFP(ell)
            i = i + 2
        }
        i = 2
        while i <= 2 * n + 2 {
            ii = makeFP(i)
            Atcei[i] = (makeFP(ii / 2) + makeFP(ell))
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            ii = makeFP(i)
            Atcei[i] = (makeFP(ii / 2) + 1 + makeFP(ell))
            i = i + 2
        }
        
    } else if (z > 0) {
        i = 1
        while i <= 2 * n + 2 {
            ii = makeFP(i)
            Atflo[i] = (makeFP(ii / 2) - 1 - makeFP(ell))
            i = i + 1
        }
        
        i = 2
        while i <= 2 * n + 2 {
            ii = makeFP(i)
            Atcei[i] = (makeFP(ii / 2) + makeFP(ell))
            i = i + 1
        }
        Atcei[1] = (1 + makeFP(ell))
        
    } else {                       /* z == 0 */
        i = 2
        while i <= 2 * n + 2 {
            ii = makeFP(i)
            Atflo[i] = (makeFP(ii / 2) - 1 - makeFP(ell))
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            ii = makeFP(i)
            Atflo[i] = (makeFP(ii / 2) - makeFP(ell))
            i = i + 2
        }
        i = 2
        while i <= 2 * n + 2 {
            ii = makeFP(i)
            Atcei[i] = (makeFP(ii / 2) - 1 + makeFP(ell))
            i = i + 2
        }
        i = 1
        while i <= 2 * n + 2 {
            ii = makeFP(i)
            Atcei[i] = (makeFP(ii / 2) + makeFP(ell))
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
    A[2 * n + 2] = makeFP(n)
}


/*========================================================================*/

fileprivate func Pomeranz<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    /* The Pomeranz algorithm to compute the KS distribution */
    let EPS: FPT = makeFP(1.0e-15)
    let ENO = 350
    let RENO: FPT = scalbn(1, ENO); /* for renormalization of V */
    var coreno: Int                    /* counter: how many renormalizations */
    let t = makeFP(n) * x
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
    var A: Array<FPT> = Array<FPT>.init(repeating: makeFP(0.0), count: 2 * n + 3)
    var Atflo: Array<FPT> = Array<FPT>.init(repeating: makeFP(0.0), count: 2 * n + 3)
    var Atcei: Array<FPT> = Array<FPT>.init(repeating: makeFP(0.0), count: 2 * n + 3)
    var V: Array<Array<FPT>>
    var H: Array<Array<FPT>> /* = pow(w, j) / Factorial(j) */
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
    w = 2 * A[2] / makeFP(n)
    j = 1
    while j <= n + 1 {
        H[0][j] = w * H[0][j - 1] / makeFP(j)
        j += 1
    }
    
    H[1][0] = 1
    w = (1 - 2 * A[2]) / makeFP(n)
    j = 1
    while j <= n + 1 {
        H[1][j] = w * H[1][j - 1] / makeFP(j)
        j += 1
    }
    
    H[2][0] = 1
    w = A[2] / makeFP(n)
    j = 1
    while j <= n + 1 {
        H[2][j] = w * H[2][j - 1] / makeFP(j)
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
        jlow = 2 + integerValue(Atflo[i])
        if (jlow < 1) {
            jlow = 1
        }
        jup = integerValue(Atcei[i])
        if (jup > n + 1) {
            jup = n + 1
        }
        
        klow = 2 + integerValue(Atflo[i - 1])
        if (klow < 1) {
            klow = 1
        }
        kup0 = integerValue(Atcei[i - 1])
        
        /* Find to which case it corresponds */
        w = (A[i] - A[i - 1]) / makeFP(n)
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
        
        if (minsum < makeFP(1.0e-280)) {
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
    w = logFactorial(n) - makeFP(coreno) * makeFP(ENO) * FPT.ln2 + log1(sum)
    if (w >= 0) {
        return 1
    }
    return exp1(w)
}


/*========================================================================*/

fileprivate func cdfSpecial<FPT: SSFloatingPoint & Codable> (_ n: Int, _ x: FPT) -> FPT {
    /* The KS distribution is known exactly for these cases */
    
    /* For nx^2 > 18, KSfbar(n, x) is smaller than 5e-16 */
    if ((makeFP(n) * x * x >= 18) || (x >= 1)) {
        return 1
    }
    
    if (x <= makeFP(0.5 ) / makeFP(n)) {
        return 0
    }
    
    if (n == 1) {
        return 2 * x - 1
    }

    if (x <= 1 / makeFP(n)) {
        let t: FPT = 2 * x * makeFP(n) - 1
        var w: FPT
        if (n <= NEXACT) {
            w = rapfac(n)
            return w * pow1(t, makeFP(n))
        }
        w = logFactorial(n) + makeFP(n) * log1(t / makeFP(n))
        return exp1(w)
    }
    
    if (x >= makeFP(1.0 ) - makeFP(1.0 ) / makeFP(n)) {
        return 1 - 2 * pow1(1 - x, makeFP(n))
    }
    return -1
}


/*========================================================================*/

/// Computes the cdf of the Kolmogorov-Smirnov distribution (Author: Richard Simard)
/// (Double precision)
internal func KScdf<FPT: SSFloatingPoint & Codable>(n: Int, x: FPT) -> FPT {
    let w = makeFP(n) * x * x
    let u = cdfSpecial(n, x)
   if (u >= 0) {
        return u
    }
    
    if (n <= NEXACT) {
        if (w < makeFP(0.754693 )) {
            return DurbinMatrix(n, x)
        }
        if (w < 4) {
            return Pomeranz (n, x)
        }
        return makeFP(1.0 ) - KSfbar(n: n, x: x)
    }
    
    if ((w * x * makeFP(n) <= 7) && (n <= NKOLMO)) {
        return DurbinMatrix (n, x)
    }
    return Pelz(n, x)
}


/*=========================================================================*/

fileprivate func fbarSpecial<FPT: SSFloatingPoint & Codable>(_ n: Int, _ x: FPT) -> FPT {
    let w = makeFP(n) * x * x
    
    if ((w >= 370) || (x >= 1)) {
        return 0
    }
    if ((w <= makeFP(0.0274 )) || (x <= makeFP(0.5 ) / makeFP(n))) {
        return 1
    }
    if (n == 1) {
        return makeFP(2.0 ) - 2 * x
    }
    
    if (x <= 1 / makeFP(n)) {
        var z:FPT
        let t = 2 * x * makeFP(n) - 1
        if (n <= NEXACT) {
            z = rapfac(n)
            return 1 - z * pow1(t, makeFP(n))
        }
        z = logFactorial(n) + makeFP(n) * log1(t / makeFP(n))
        return makeFP(1.0 ) - exp1(z)
    }
    
    if (x >= makeFP(1.0 ) - 1 / makeFP(n)) {
        return 2 * pow1(1 - x, makeFP(n))
    }
    return -1
}


/*========================================================================*/

internal func KSfbar<FPT: SSFloatingPoint & Codable>(n: Int, x: FPT) -> FPT {
    let w: FPT = makeFP(n) * x * x
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
    
    if (w >= makeFP(2.65)) {
        return 2 * KSPlusbarUpper(n, x)
    }
    
    return 1 - KScdf(n: n, x: x)
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

//fileprivate let NORM = 1.0e140
//fileprivate let INORM = 1.0e-140
//fileprivate let LOGNORM = 140

fileprivate func DurbinMatrix<FPT: SSFloatingPoint & Codable>(_ n: Int, _ d: FPT) -> FPT {
    let NORM: FPT = makeFP(1.0e140)
    let INORM: FPT = makeFP(1.0e-140)
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
    k = integerValue(makeFP(n) * d + 1)
    m = 2 * k - 1
    h = makeFP(k) - makeFP(n) * d
    H = Array<FPT>.init(repeating: makeFP(0.0), count: m * m)
    Q = Array<FPT>.init(repeating: makeFP(0.0), count: m * m)
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
        H[i * m] -= pow1(h, makeFP(i + 1))
        H[(m - 1) * m + i] -= pow1(h, makeFP(m - i))
    }
    let test: FPT = 2 * h - 1
    if test > 0 {
        H[(m - 1) * m] += pow1(2 * h - 1, makeFP(m))
    }
    else {
        H[(m - 1) * m] += 0
    }
//    H[(m - 1) * m] += (2 * h - 1 > 0 ? pow1(2 * h - 1, makeFP(m)) : 0)
    for i in 0...m - 1 {
        for j in 0...m - 1 {
            if (i - j + 1 > 0) {
                for g in 1...i - j + 1 {
                    H[i * m + j] /= makeFP(g)
                }
            }
        }
    }
    eH = 0
    mPower(H, eH, &Q, &eQ, m, n);
    s = Q[(k - 1) * m + k - 1]
    for i in 1...n {
        s = s * makeFP(i) / makeFP(n)
        if (s < INORM) {
            s *= NORM
            eQ -= LOGNORM
        }
    }
    s *= pow1(10, makeFP(eQ))
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
//    int i;
    let INORM: FPT = makeFP(1.0e-140)
    let LOGNORM = 140
    for i in 0...m * m - 1 {
        V[i] *= INORM
    }
    p.pointee += LOGNORM
}


fileprivate func mPower<FPT: SSFloatingPoint & Codable>(_ A: Array<FPT>, _ eA: Int, _ V: inout Array<FPT>, _ eV: UnsafeMutablePointer<Int>, _ m: Int, _ n: Int) {
    var B: Array<FPT>
    let NORM: FPT = makeFP(1.0e140)
//    int eB, i;
    if (n == 1) {
        for i in 0...m * m - 1 {
            V[i] = A[i]
        }
        eV.pointee = eA
        return
    }
    mPower(A, eA, &V, eV, m, n / 2)
    B = Array<FPT>.init(repeating: makeFP(0.0), count: m * m)
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


