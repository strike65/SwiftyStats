//
//  SSUtils.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 03.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//
/*
 MIT License
 
 Copyright (c) 2017 Volker Thieme
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

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
/// - Paramter value: A value of Type T
func isNumeric<T>(_ value: T) -> Bool {
    if (value is Int || value is UInt || value is Double || value is Int8 || value is Int16 || value is Int32 || value is Int64 || value is UInt8 || value is UInt16 || value is UInt32 || value is UInt64 || value is Float32 || value is Float80 || value is NSNumber || value is NSDecimalNumber ) {
        return true
    }
    else {
        return false
    }
}

func maximum<T>(t1: T, t2: T) -> T where T:Comparable {
    if t1 > t2 {
        return t1
    }
    else {
        return t2
    }
}
//
//extension Comparable where Self: SignedNumber {
//    var sign: Int {
//        guard self != -self else {
//            return 0
//        }
//        return self > -self ? 1 : -1
//    }
//}


/// Adds the function sgn()
extension Double {
    func sgn() -> Int {
        let result = (self < Double(0) ? -1 : 1)
        return result
    }
}
