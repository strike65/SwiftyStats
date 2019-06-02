//
//  SSSpecialFunctions.swift
//  SwiftyStats
//
//  Created by strike65 on 19.07.17.
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
 References:
 DiDonato,  A.    R.   and  Morris,  A.  H.   (1993)  ``Algorithm  708:
 Significant  Digit   Computation  of  the   Incomplete  Beta  Function
 Ratios.''  ACM Trans.  Math.  Softw. 18, 360-373.

 DiDonato,  A.  R.   and Morris,  A.  H.  (1986)  ``Computation of  the
 incomplete gamma function ratios and their inverse.'' ACM Trans. Math.
 Softw. 12, 377-393.
 
 Cody,  W.D. (1993).  ``ALGORITHM  715: SPECFUN  -  A Portable  FORTRAN
 Package  of   Special  Function   Routines  and  Test   Drivers''  ACM
 Trans. Math.  Softw. 19, 22-32.

 */

import Foundation

/// Returns the beta function
/// adapted from the Cephes library with kind permission by Stephen L. Moshier
/// <img src="../img/Beta.png" alt="">
/// - Parameter a: a
/// - Parameter b: b
internal func betaFunction<T: SSFloatingPoint>(a: T, b: T) -> T {
    if b.isZero || a.isZero {
        return T.infinity
    }
    if a == 1 {
        return makeFP(1.0) / b
    }
    if b == 1 {
        return makeFP(1.0) / a
    }
    if a < 0 {
        if a == floor(a) {
            return T.infinity
        }
    }
    if b < 0 {
        if b == floor(b) {
            return T.infinity
        }
    }
//    #if arch(x86_64)
//    var g1: Float80 = tgammal(a)
//    var g2: Float80 = Float80(b).gammaValue
//    let sum: Float80 = Float80(a + b)
//    var g3: Float80 = sum.gammaValue
//    #else
    var g1 = tgamma1(a)
    var g2 = tgamma1(b)
    let sum = a + b
    var g3 = tgamma1(sum)
    var ans: T = 0
    //    #endif
    var sign:Int = 1
    if !(g1.isInfinite || g2.isInfinite || g3.isInfinite) && !(g1.isNaN || g2.isNaN || g2.isNaN) {
        if g3.isZero {
            return T.infinity
        }
        else {
            ans = g1 * g2 / g3
            return ans
        }
    }
    else {
        g1 = lgamma1(a)
        sign = Int(signgam)
        g2 = lgamma1(b)
        sign = sign * Int(signgam)
        g3 = lgamma1(a + b)
        sign = sign * Int(signgam)
        ans = makeFP(sign) * exp1(g1 + g2 - g3)
        return ans
    }
}


/// Returns the normalized beta function for at x for a and b. Using continued fractions.
/// <img src="../img/BetaRegularized.png" alt="">
internal func betaNormalized<T: SSFloatingPoint>(x: T, a: T, b: T) -> T {
    var result: T = T.nan
    var _a: T = T.nan
    var _b: T = T.nan
    var _x: T = T.nan
    if b < 0 {
        if b == floor(b) {
            return T.infinity
        }
        else {
            return 1
        }
    }
    _a = a
    _b = b
    _x = x
    // compt test value for else if
    if _a.isNaN || _b.isNaN || x.isNaN {
        return T.nan
    }
    let s1 = (a + 1)
    let s2 = (2 + b + a)
    let s3 = (b + 1)
    let s4 = (1 + b + a)
    //
    let cf: SSBetaRegularized<T> = SSBetaRegularized<T>.init()
    if (_x < 0) || (_x > 1) {
        return T.nan
    }
    else if ((x > s1 / s2 && ((1 - x) <= (s3 / s4 ) ) ) ) {
        result = 1 - betaNormalized(x: 1 - x, a: b, b: a)
    }
    else {
        cf.a = _a
        cf.b = _b
        var ok: Bool = false
        var it: Int = 0
        let cfresult = cf.compute(x: x, eps: T.ulpOfOne, maxIter: 5000, converged: &ok, iterations: &it)
        if !ok {
            return T.nan
        }
        else {
            let lb = log1(betaFunction(a: a, b: b))
            let expr1:T = (a * log1(x))
            let expr2:T  = (b * log1p1(-x))
            result = exp1(expr1 + expr2 - log1(a) - lb) * (1 / cfresult)
        }
    }
    return result
}

fileprivate func expSum<T: SSFloatingPoint>(n: T, z: T) -> T {
    var sum: T = 0
    var gk: T
    var lp: T
    var temp: T
    for k: Int in 0...(integerValue(n)) {
        lp = makeFP(k) * log1p1(z - 1)
        gk = lgamma1(makeFP(k) + 1)
        temp = lp - gk
        sum = sum + exp1(temp)
    }
    return sum
}

/// Returns the normalized (regularized) Gammma function P (http://mathworld.wolfram.com/RegularizedGammaFunction.html http://dlmf.nist.gov/8.2)
/// <img src="../img/GammaP.png" alt="">
internal func gammaNormalizedP<T: SSFloatingPoint>(x: T, a: T, converged: UnsafeMutablePointer<Bool>) -> T {
    var result: T
    var n: T
    var sn: T
    var sum: T
    if x.isZero {
        if a.isZero {
            converged.pointee = true
            return 1
        }
        else if a < 0 {
            converged.pointee = false
            return T.nan
        }
    }
    if a < 0 && integerPart(a) == a {
        return 1
    }
    if a == T.half && x > 0 {
        converged.pointee = true
        return 1 - erfc1(sqrt(x))
    }
    if a == -T.half && x > 0 {
        converged.pointee = true
        return 1 - (erfc1(sqrt(x)) - (exp1(-x) / (T.sqrtpi * sqrt(x))))
    }
    if a == 1 {
        converged.pointee = true
        return 1 - exp1(-x)
    }
//    if isInteger(a) && a > 0 {
////    if a == floor(a) && a > 0 {
//        let t: T = expSum(n: a - 1, z: x)
////        result = makeFP(1.0) - exp1(-x) * t
//        result = expm11(-x) * t
//        converged.pointee = true
//        return result
//    }
    var incg: (p: T, q: T, ierr: Int)
    if x < 0 || a <= 0 {
        return T.nan
    }
    else {
        n = 0
        sn = makeFP(1.0) / a
        sum = sn
        while abs(sn / sum) > T.ulpOfOne && n < 2000 && !sum.isInfinite {
            n = n + 1
            sn = sn * x / (a + n)
            sum = sum + sn
        }
        if n > 2000 {
            incg = incgam(a: a, x: x)
            if incg.ierr == 0 {
                converged.pointee = true
                return incg.p
            }
            else {
                converged.pointee = false
                return T.nan
            }
        }
        else if sum.isInfinite {
            incg = incgam(a: a, x: x)
            if incg.ierr == 0 {
                converged.pointee = true
                return incg.p
            }
            else {
                converged.pointee = false
                return T.nan
            }
        }
        else {
            converged.pointee = true
            result = exp1(-x + (a * log1(x)) - lgamma1(a)) * sum
            return result
        }
    }
}


/// Returns the normalized (regularized) Gammma function Q (http://mathworld.wolfram.com/RegularizedGammaFunction.html http://dlmf.nist.gov/8.2)
/// <img src="../img/GammaQ.png" alt="">
internal func gammaNormalizedQ<T: SSFloatingPoint>(x: T, a: T, converged: UnsafeMutablePointer<Bool>) -> T {
//    if a > 0 && x.isZero {
//        converged.pointee = true
//        return 1
//    }
    if a.isZero {
        converged.pointee = true
        return 0
    }
    if a == T.half && x > 0 {
        converged.pointee = true
        return erfc1(sqrt(x))
    }
    if x.isZero {
        if a.isZero {
            converged.pointee = true
            return 0
        }
        else if a < 0 {
            converged.pointee = false
            return T.nan
        }
    }
    if a < 0 && integerPart(a) == a {
        converged.pointee = true
        return 0
    }
    if a == -T.half && x > 0 {
        converged.pointee = true
        return erfc1(sqrt(x)) - (exp1(-x) / (T.sqrtpi * sqrt(x)))
    }
    if a == 1 {
        converged.pointee = true
        return exp1(-x)
    }
    var result: T
    var conv: Bool = false
    var it: Int = 0
    if x < 0 || a <= 0 {
        converged.pointee = false
        return T.nan
    }
    else if x == 0 {
        converged.pointee = true
        return 1
    }
//    else if a == floor(a) && a > 0 {
//        let t = expSum(n: a - 1, z: x)
//        result = exp1(-x) * t
//        converged.pointee = true
//        return result
//    }
    else if x < (a + 1) {
        result = 1 - gammaNormalizedP(x: x, a: a, converged: &conv)
        if !conv {
            converged.pointee = false
            return T.nan
        }
        else {
            converged.pointee = true
            return result
        }
    }
    else {
        let cf = SSGammaQ<T>()
        cf.a = a
        let temp: T = 1 / cf.compute(x: x, eps: T.ulpOfOne, maxIter: 5000, converged: &conv, iterations: &it)
        if !conv {
            converged.pointee = false
            return T.nan
        }
        else {
            converged.pointee = true
            return exp1(-x + (a * log1(x)) - lgamma1(a)) * temp
        }
    }
}


internal func gammaIncomplete<T: SSFloatingPoint>(x: T, a: T, type: SSIncompleteGammaFunction) -> T {
    var conv: Bool = false
    var r: T
    switch type {
    case .lower:
        r = gammaNormalizedP(x: x, a: a, converged: &conv)
        if conv {
            let temp1: T = r * tgamma1(a)
            return temp1
        }
        else {
            return T.nan
        }
    case .upper:
        r = gammaNormalizedQ(x: x, a: a, converged: &conv)
        if conv {
            return r * tgamma1(a)
        }
        else {
            return T.nan
        }
    }
}



internal func pochhammer<T: SSFloatingPoint>(x: T, n: T) -> T {
    let res: T = lgamma1(x + n) - lgamma1(x)
    return exp1(res)
}

internal func lpochhammer<T: SSFloatingPoint>(x: T, n: T) -> T {
    let res: T = lgamma1(x + n) - lgamma1(x)
    return res
}

