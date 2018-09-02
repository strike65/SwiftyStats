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
public func paraBetaDist<FPT: SSFloatingPoint & Codable>(shapeA a:FPT, shapeB b: FPT) throws -> SSContProbDistParams<FPT> {
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    if (a <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = (a / (a + b))
    result.variance = (a * b) / (pow1(a + b, 2) * (a + b + 1))
    let s1:FPT = (2 * (b - a))
    let s2:FPT = (a + b + 1)
    let s3:FPT = sqrt(a) * sqrt(b)
    let s4:FPT = (2 + a + b)
    result.skewness = (s1 * sqrt(s2)) / (s3 * s4)
    let k1:FPT = (a + b + 1)
    let k2:FPT = pow1(a, 2) * (b + 2)
    let k3:FPT = pow1(b, 2) * (a + 2)
    let k4:FPT = 2 * a * b
    let k5:FPT = a + b + 2
    let k6:FPT = (a + b + 3)
    let kk1:FPT = (3 * k1 * ( k2 + k3 - k4 ))
    let kk2:FPT = (a * b * k5 * k6)
    result.kurtosis = kk1 / kk2
    return result
}


/// Returns the pdf of the Beta distribution
/// - Parameter x: x
/// - Parameter a: Shape parameter a
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if a and/or b <= 0
public func pdfBetaDist<FPT: SSFloatingPoint & Codable>(x: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
    if (a <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0) {
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
    let result = pow1(x, a - 1) * pow1(1 - x, b - 1) / betaFunction(a: a, b: b)
    return result
}

/// Returns the pdf of the Beta distribution
/// - Parameter x: x
/// - Parameter a: Shape parameter a
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if a and/or b <= 0
public func cdfBetaDist<FPT: SSFloatingPoint & Codable>(x: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
    if (a <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (x <= 0) {
        return 0
    }
    else if (x >= 1) {
        return 1
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
public func quantileBetaDist<FPT: SSFloatingPoint & Codable>(p: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
    if (a <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if abs(p - 1) < FPT.ulpOfOne {
        return 1
    }
    else if p.isZero {
        return 0
    }

//    if abs(p - 1.0) < 1E-12 {
//        return 1.0
//    }
//    else if p.isZero {
//        return 0.0
//    }
    var bVal: FPT
    var maxB: FPT
    var minB: FPT
    var it: Int = 0
    maxB = 1
    minB = 0
    bVal = makeFP(1.0 / 2.0 )
    var pVal: FPT
    while (maxB - minB) > FPT.ulpOfOne {
        if it > 500 {
            break
        }
        do {
            pVal = try cdfBetaDist(x: bVal, shapeA: a, shapeB: b)
        }
        catch {
            return FPT.nan
        }
        if  pVal > p {
            maxB = bVal
        }
        else {
            minB = bVal
        }
        bVal = (maxB + minB) / 2
        it = it + 1
    }
    return bVal
}


