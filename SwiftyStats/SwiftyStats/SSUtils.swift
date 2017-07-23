//
//  SSUtils.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 03.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
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

/// Returns the maximum of two comparable values
func maximum<T>(t1: T, t2: T) -> T where T:Comparable {
    if t1 > t2 {
        return t1
    }
    else {
        return t2
    }
}

/// Adds the function sgn()
extension Double {
    func sgn() -> Double {
        if self.sign == .minus {
            return -1.0
        }
        else {
            return 1.0
        }
    }
}
