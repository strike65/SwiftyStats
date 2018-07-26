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


// MARK: Beta

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Beta distribution.
/// - Parameter a: Shape parameter a
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if a and/or b <= 0
public func paraBetaDist(shapeA a:Double!, shapeB b: Double!) throws -> SSContProbDistParams {
    var result = SSContProbDistParams()
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = (a / (a + b))
    result.variance = (a * b) / (pow(a + b, 2.0) * (a + b + 1.0))
    let s1:Double = (2.0 * (b - a))
    let s2:Double = (a + b + 1.0)
    let s3:Double = sqrt(a) * sqrt(b)
    let s4:Double = (2 + a + b)
    result.skewness = (s1 * sqrt(s2)) / (s3 * s4)
    let k1 = (a + b + 1.0)
    let k2 = pow(a, 2.0) * (b + 2)
    let k3 = pow(b, 2.0) * (a + 2.0)
    let k4 = 2.0 * a * b
    let k5 = a + b + 2.0
    let k6 = (a + b + 3.0)
    let kk1 = (3.0 * k1 * ( k2 + k3 - k4 ))
    let kk2 = (a * b * k5 * k6)
    result.kurtosis = kk1 / kk2
    return result
}


/// Returns the pdf of the Beta distribution
/// - Parameter x: x
/// - Parameter a: Shape parameter a
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if a and/or b <= 0
public func pdfBetaDist(x: Double!, shapeA a: Double!, shapeB b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
//    if (x < 0) {
//        return 0.0
//    }
//    if(x >= 1.0) {
//        return 0.0
//    }
    let result = pow(x, a - 1.0) * pow(1.0 - x, b - 1.0) / betaFunction(a: a, b: b)
    return result
}

/// Returns the pdf of the Beta distribution
/// - Parameter x: x
/// - Parameter a: Shape parameter a
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if a and/or b <= 0
public func cdfBetaDist(x: Double!, shapeA a: Double!, shapeB b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (x <= 0) {
        return 0.0
    }
    else if (x >= 1.0) {
        return 1.0
    }
    else {
        let result = betaNormalized(x: x, a: a, b: b)
        return result
    }
}

/// Returns the quantile of the Beta distribution
/// - Parameter p: p
/// - Parameter a: Shape parameter a
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if a and/or b <= 0 and/or p < 0 and/or p > 1
public func quantileBetaDist(p: Double!, shapeA a: Double!, shapeB b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0 || p > 1.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if fabs(p - 1.0) < 1E-12 {
        return 1.0
    }
    else if p.isZero {
        return 0.0
    }
    var bVal: Double
    var maxB: Double
    var minB: Double
    var it: Int = 0
    maxB = 1.0
    minB = 0.0
    bVal = 0.5
    var pVal: Double
    while (maxB - minB) > 1E-12 {
        if it > 500 {
            break
        }
        do {
            pVal = try cdfBetaDist(x: bVal, shapeA: a, shapeB: b)
        }
        catch {
            return Double.nan
        }
        if  pVal > p {
            maxB = bVal
        }
        else {
            minB = bVal
        }
        bVal = (maxB + minB) / 2.0
        it = it + 1
    }
    return bVal
}


