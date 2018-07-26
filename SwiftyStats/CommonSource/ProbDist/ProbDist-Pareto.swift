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


// MARK: Pareto

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Pareto distribution.
/// - Parameter a: minimum
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
public func paraParetoDist(minimum a: Double!, shape b: Double!) throws -> SSContProbDistParams {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("minimum parameter a is expected to be > 0", log: log_stat, type: .error)
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
    var result = SSContProbDistParams()
    if b > 1.0 {
        result.mean = (a * b) / (b - 1.0)
    }
    else {
        result.mean = Double.nan
    }
    if b > 2.0 {
        let v1 = (a * a * b )
        let v2 = (b - 2.0)
        let v3 = (b - 1.0)
        let v4 = (b - 1.0)
        result.variance = v1 / ( v2 * v3 * v4 )
    }
    else {
        result.variance = Double.nan
    }
    if b > 4.0 {
        let b2 = b * b
        let b3 = (-15.0 + 9.0 * b)
        let temp = (-12.0 + b2 * b3 ) / ((-4.0 + b) * (-3.0 + b) * b)
        result.kurtosis = temp
        //            result.kurtosis = (3.0 * (b - 2.0) * (2.0 + b + 3.0 * b * b)) / ((b - 4.0) * (b - 3.0) * b)
    }
    else {
        result.kurtosis = Double.nan
    }
    if b > 3.0 {
        let s1 = sqrt((-2.0 + b) / b)
        let s2 = (1.0 + b)
        let s3 = (b - 3.0)
        result.skewness = (2.0 * s1 * s2) / s3
    }
    else {
        result.skewness = Double.nan
    }
    return result
}

/// Returns the pdf of the Pareto distribution.
/// - Parameter x: x
/// - Parameter a: minimum
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
public func pdfParetoDist(x: Double!, minimum a: Double!, shape b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("minimum parameter a is expected to be > 0", log: log_stat, type: .error)
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
    if x < a {
        return 0.0
    }
    let a1 = pow(a, b)
    let a2 = a1 * b
    let result = a2 * pow(x, -1.0 - b)
    return result
}

/// Returns the cdf of the Pareto distribution.
/// - Parameter x: x
/// - Parameter a: minimum
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
public func cdfParetoDist(x: Double!, minimum a: Double!, shape b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("minimum parameter a is expected to be > 0", log: log_stat, type: .error)
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
    if x <= a {
        return 0.0
    }
    else {
        return 1.0 - pow(a / x, b)
    }
}


/// Returns the quantile of the Pareto distribution.
/// - Parameter p: p
/// - Parameter a: minimum
/// - Parameter b: Shape parameter b
/// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
public func quantileParetoDist(p: Double!, minimum a: Double!, shape b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("minimum parameter a is expected to be > 0", log: log_stat, type: .error)
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
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p.isZero {
        return a
    }
    else if p == 1.0 {
        return Double.infinity
    }
    else {
        return a * pow(1.0 - p, -1.0 / b)
    }
}

