//
//  SSSpecialFunctions.swift
//  SwiftyStats
//
//  Created by volker on 19.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//

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
