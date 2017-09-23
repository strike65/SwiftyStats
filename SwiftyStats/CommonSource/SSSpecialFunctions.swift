//
//  SSSpecialFunctions.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 19.07.17.
//
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

/// Returns the beta function
/// adapted from the Cephes library with kind permission by Stephen L. Moshier
/// - Parameter a: a
/// - Parameter b: b
public func betaFunction(a: Double!, b: Double!) -> Double {
    if b.isZero || a.isZero {
        return Double.infinity
    }
    if a == 1.0 {
        return 1.0 / b
    }
    if b == 1.0 {
        return 1.0 / a
    }
    if a < 0.0 {
        if a == floor(a) {
            return Double.infinity
        }
    }
    if b < 0.0 {
        if b == floor(b) {
            return Double.infinity
        }
    }
    var g1: Double = tgamma(a)
    var g2: Double = tgamma(b)
    var g3: Double = tgamma(a + b)
    var sign:Int = 1
    if !(g1.isInfinite || g2.isInfinite || g3.isInfinite) && !(g1.isNaN || g2.isNaN || g2.isNaN) {
        if g3.isZero {
            return Double.infinity
        }
        else {
            return g1 * g2 / g3
        }
    }
    else {
        g1 = lgamma(a)
        sign = Int(signgam)
        g2 = lgamma(b)
        sign = sign * Int(signgam)
        g3 = lgamma(a + b)
        sign = sign * Int(signgam)
        return Double(sign) * exp(g1 + g2 - g3)
    }
}


/// Returns the normalized beta function for at x for a and b. Using continued fractions.
public func betaNormalized(x: Double!, a: Double!, b: Double!) -> Double {
    var result: Double = Double.nan
    var _a: Double = Double.nan
    var _b: Double = Double.nan
    var _x: Double = Double.nan
    if b < 0 {
        if b == floor(b) {
            return Double.infinity
        }
        else {
            return 1.0
        }
    }
    _a = a
    _b = b
    _x = x
    if _a.isNaN || _b.isNaN || x.isNaN {
        return Double.nan
    }
    else if (_x < 0) || (_x > 1) {
        return Double.nan
    }
    else if ((x > (a + 1) / (2.0 + b + a) && ((1 - x) <= ((b + 1) / (2 + b + a) ) ) ) ) {
        result = 1.0 - betaNormalized(x: 1.0 - x, a: b, b: a)
    }
    else {
        let cf = SSBetaRegularized()
        cf.a = _a
        cf.b = _b
        var ok: Bool = false
        var it: Int = 0
        let cfresult = cf.compute(x: x, eps: 1E-14, maxIter: 3000, converged: &ok, iterations: &it)
        if !ok {
            return Double.nan
        }
        else {
            let lb = log(betaFunction(a: a, b: b))
            result = exp((a * log(x)) + (b * log1p(-x)) - log(a) - lb) * 1.0 / cfresult
        }
    }
    return result
}

fileprivate func expSum(n: Double!, z: Double) -> Double {
    var sum: Double = 0
    var gk: Double
    var lp: Double
    var temp: Double
    for k: Int in 0...Int(n) {
        lp = Double(k) * log1p(z - 1.0)
        gk = lgamma(Double(k) + 1.0)
        temp = lp - gk
        sum = sum + exp(temp)
    }
    return sum
}

/// Returns the normalized (regularized) Gammma function P (http://mathworld.wolfram.com/RegularizedGammaFunction.html http://dlmf.nist.gov/8.2)
public func gammaNormalizedP(x: Double!, a: Double!, converged: UnsafeMutablePointer<Bool>) -> Double {
    var result: Double
    var n: Double
    var sn: Double
    var sum: Double
    if x == 0.0 {
        converged.pointee = true
        return 0.0
    }
    if a == floor(a) && a > 0 {
        let t = expSum(n: a - 1, z: x)
        result = 1.0 - exp(-x) * t
        return result
    }
    if x < 0.0 || a <= 0.0 {
        return Double.nan
    }
    else {
        n = 0.0
        sn = 1.0 / a
        sum = sn
        while fabs(sn / sum) > 1E-16 && n < 2000 && !sum.isInfinite {
            n = n + 1.0
            sn = sn * x / (a + n)
            sum = sum + sn
        }
        if n > 2000 {
            converged.pointee = false
            return Double.nan
        }
        else if sum.isInfinite {
            converged.pointee = true
            return 1.0
        }
        else {
            converged.pointee = true
            result = exp(-x + (a * log(x)) - lgamma(a)) * sum
            return result
        }
    }
}

/// Returns the normalized (regularized) Gammma function Q (http://mathworld.wolfram.com/RegularizedGammaFunction.html http://dlmf.nist.gov/8.2)
public func gammaNormalizedQ(x: Double!, a: Double!, converged: UnsafeMutablePointer<Bool>) -> Double {
    if a > 0 && x == 0.0 {
        converged.pointee = true
        return 1.0
    }
    var result: Double
    var conv: Bool = false
    var it: Int = 0
    if a == 0.0 {
        converged.pointee = true
        return 0.0
    }
    if x < 0.0 || a <= 0.0 {
        converged.pointee = false
        return Double.nan
    }
    else if x == 0.0 {
        converged.pointee = true
        return 1.0
    }
    else if a == floor(a) && a > 0 {
        let t = expSum(n: a - 1, z: x)
        result = exp(-x) * t
        converged.pointee = true
        return result
    }
    else if x < (a + 1) {
        result = 1.0 - gammaNormalizedP(x: x, a: a, converged: &conv)
        if !conv {
            converged.pointee = false
            return Double.nan
        }
        else {
            converged.pointee = true
            return result
        }
    }
    else {
        let cf = SSGammaQ()
        cf.a = a
        let temp: Double = 1.0 / cf.compute(x: x, eps: 1E-12, maxIter: 5000, converged: &conv, iterations: &it)
        if !conv {
            converged.pointee = false
            return Double.nan
        }
        else {
            converged.pointee = true
            return exp(-x + (a * log(x)) - lgamma(a)) * temp
        }
    }
    
}

