//
//  Created by VT on 20.07.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
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

#if os(macOS) || os(iOS)
import os.log
#endif

// MARK: TRIANGULAR

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Triangular distribution.
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Parameter c: Mode
/// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
public func paraTriangularDist(lowerBound a: Double!, upperBound b: Double!, mode c: Double!) throws -> SSContProbDistParams {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= a) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result = SSContProbDistParams()
    result.mean = (a + b + c) / 3.0
    result.kurtosis = 2.4
    let a2 = a * a
    let a3 = a2 * a
    let b2 = b * b
    let b3 = b2 * b
    let c2 = c * c
    let c3 = c2 * c
    let ab = a * b
    let ac = a * c
    let bc = b * c
    result.variance = 1.0 / 18.0 * ( a2 - ab + b2 - ac - bc + c2 )
    //        result.variance = 1.0 / 18.0 * (a * a - a * b + b * b - a * c - b * c + c * c)
    let s1 = 2.0 * a3
    let s2 = 3.0 * a2 * b
    let s3 = 3.0 * a * b2
    let s4 = 2.0 * b3
    let s5 = 3.0 * a3 * c
    let s6 = 12.0 * ab * c
    let s7 = 3.0 * b2 * c
    let s8 = 3.0 * a * c2
    let s9 = 3.0 * b * c2
    let s10 = 2.0 * c3
    let s11 = a2 - ab + b2 - ac - bc + c2
    let ss1 = (s1 - s2 - s3 + s4 - s5 + s6 - s7 - s8 - s9 + s10)
    result.skewness = (SQRTTWO * ss1) / (5.0 * pow(s11, 1.5))
    //        result.skewness = (SQRTTWO * ( 2.0 * a3 - 3.0 * a2 * b - 3.0 * a * b2 + 2.0 * b3 - 3.0 * a3 * c + 12.0 * a * b * c - 3.0 * b2 * c - 3.0 * a * c2 - 3.0 * b * c2 + 2.0 * c3)) / (5.0 * pow(a2 - a * b + b2 - a * c - b * c + c2, 1.5))
    return result
}

/// Returns the pdf of the Triangular distribution.
/// - Parameter x: x
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Parameter c: Mode
/// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
public func pdfTriangularDist(x: Double!, lowerBound a: Double!, upperBound b: Double!, mode c: Double!) throws -> Double {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= a) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if ((x < a) || (x > b)) {
        return 0.0
    }
    else if ((x == a) || ((x > a) && (x <= c))) {
        let s1 = (2.0 * ( x - a))
        let s2 = (a - b - c)
        return s1 / (a * s2 + b * c)
    }
    else {
        let s1 = (2.0 * (b - x))
        let s2 = (-a + b - c)
        return s1 / (b * s2 + a * c)
    }
}

/// Returns the cdf of the Triangular distribution.
/// - Parameter x: x
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Parameter c: Mode
/// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
public func cdfTriangularDist(x: Double!, lowerBound a: Double!, upperBound b: Double!, mode c: Double!) throws -> Double {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= a) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (x < a) {
        return 0.0
    }
    else if (x > b) {
        return 1.0
    }
    else if ((x > a) || (x == a)) && ((x < c) || (x == c)) {
        return pow(x - a, 2.0) / ((b - a) * (c - a))
    }
    else {
        return 1.0 - pow(b - x, 2.0) / ((b - a) * (b - c))
    }
}

/// Returns the quantile of the Triangular distribution.
/// - Parameter p: p
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Parameter c: Mode
/// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b || p < 0 || p > 0
public func quantileTriangularDist(p: Double!, lowerBound a: Double!, upperBound b: Double!, mode c: Double!) throws -> Double {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= a) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p == 0.0 {
        return a
    }
    let t1 = (-a + c) / (-a + b)
    if p <= t1 {
        let s1 = (-a + b)
        let s2 = (-a + c)
        let s3 = sqrt(s1 * s2 * p)
        return a + s3
    }
    else {
        let s1 = (-a + b)
        let s2 = (b - c)
        let s3 = (1.0 - p)
        return b - sqrt(s1 * s2 * s3)
    }
}

// MARK: TRIANGULAR with two params

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Triangular distribution.
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Throws: SSSwiftyStatsError if a >= b
public func paraTriangularDist(lowerBound a: Double!, upperBound b: Double!) throws -> SSContProbDistParams {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result = SSContProbDistParams()
    result.mean = (a + b) / 2.0
    result.variance = 1.0 / 24.0 * (b - a) * (b - a)
    result.kurtosis = 2.4
    result.skewness = 0.0
    return result
}

/// Returns the pdf of the Triangular distribution.
/// - Parameter x: x
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Throws: SSSwiftyStatsError if a >= b
public func pdfTriangularDist(x: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return try! pdfTriangularDist(x: x, lowerBound: a, upperBound: b, mode: (a + b) / 2.0)
}

/// Returns the cdf of the Triangular distribution.
/// - Parameter x: x
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Throws: SSSwiftyStatsError if a >= b
public func cdfTriangularDist(x: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return try! cdfTriangularDist(x: x, lowerBound: a, upperBound: b, mode: (a + b) / 2.0)
}

/// Returns the quantile of the Triangular distribution.
/// - Parameter p: p
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Throws: SSSwiftyStatsError if a >= b || p < 0 || p > 0
public func quantileTriangularDist(p: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return try! quantileTriangularDist(p: p, lowerBound: a, upperBound: b, mode: (a + b) / 2.0)
}

