//
//  SSUtils.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 03.07.17.
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


func makeDouble<T>(_ value: T) -> Double {
    if isNumber(value) {
        if T.self is Int.Type {
            return Double(value as! Int)
        }
        else {
            return value as! Double
        }
    }
    else {
        return Double.nan
    }
}


/// Binomial
public func binomial2(_ n: Double!, _ k: Double!) -> Double {
    if k == 0.0 {
        return 1.0
    }
    let num: Double = lgamma(n + 1.0)
    let den: Double = lgamma(n - k + 1.0) + lgamma(k + 1.0)
    let q: Double = num - den
    return exp(q)
}


/// Tests, if a value is integer.
/// - Paramter value: A double-value.
func isInteger(_ value: Double) -> Bool {
    return value.truncatingRemainder(dividingBy: 1) == 0
}

/// Tests, if a value is odd.
/// - Paramter value: A double-value.
func isOdd(_ value: Double) -> Bool {
    var frac: Double
    var intp: Double = 0.0
    frac = modf(value, &intp)
    if !frac.isZero {
        return false;
    }
    else if intp.truncatingRemainder(dividingBy: 2) == 0 {
        return false
    }
    else {
        return true
    }
}

/// Returns the fractional part of a double-value
/// - Paramter value: A double-value.
func fractionalPart(_ value: Double) -> Double {
    var intpart: Double = 0.0
    let result: Double = modf(value, &intpart)
    return result
}

/// Tests, if a value is numeric
/// - Paramter value: A value of type T
func isNumber<T>(_ value: T) -> Bool {
    if (value is Int || value is UInt || value is Double || value is Int8 || value is Int16 || value is Int32 || value is Int64 || value is UInt8 || value is UInt16 || value is UInt32 || value is UInt64 || value is Float32 || value is Float80 || value is NSNumber || value is NSDecimalNumber ) {
        return true
    }
    else {
        return false
    }
}

/// Returns the maximum of two comparable values
func maximum<T>(_ t1: T, _ t2: T) -> T where T:Comparable {
    if t1 > t2 {
        return t1
    }
    else {
        return t2
    }
}

/// Returns the minimum of two comparable values
func minimum<T>(_ t1: T, _ t2: T) -> T where T:Comparable {
    if t1 < t2 {
        return t1
    }
    else {
        return t2
    }
}


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
func logFactorial(_ n: Int) -> Double {
    /* Returns the natural logarithm of factorial n! */
    if (n <= 30) {
        return LnFactorial[n]
        
    } else {
        let x = Double(n + 1)
        let y = 1.0 / (x * x)
        var z = ((-(5.95238095238E-4 * y) + 7.936500793651E-4) * y - 2.7777777777778E-3) * y + 8.3333333333333E-2
        z = ((x - 0.5) * log(x) - x) + 9.1893853320467E-1 + z / x
        return z
    }
}


extension Double {
    /// Adds the function sgn().
    /// - Returns: -1.0 if the receiver is < 0.0, +1.0 otherwise
    public var sgn: Double {
        get {
            if self.sign == .minus {
                return -1.0
            }
            else {
                return 1.0
            }
        }
    }
    
//    func sgn() -> Double {
//        if self.sign == .minus {
//            return -1.0
//        }
//        else {
//            return 1.0
//        }
//    }
}

/// Returns a SSExamine object of length one and count "count"
/// - Parameter value: Value
/// - Parameter count: Number of values
func replicateExamine<T>(value: T!, count: Int!) -> SSExamine<T> where T: Comparable, T: Hashable {
    let array = Array<T>.init(repeating: value, count: count)
    let res = SSExamine<T>.init(withArray: array, name: nil, characterSet: nil)
    return res
}
















