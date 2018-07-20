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


// MARK: Laplace
/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Laplace distribution.
/// - Parameter mean: mean
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func paraLaplaceDist(mean: Double!, scale b: Double!) throws -> SSContProbDistParams {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result = SSContProbDistParams()
    result.mean = mean
    result.variance = 2.0 * pow(b, 2.0)
    result.kurtosis = 6.0
    result.skewness = 0.0
    return result
}


/// Returns the pdf of the Laplace distribution.
/// - Parameter x: x
/// - Parameter mean: mean
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func pdfLaplaceDist(x: Double!, mean: Double!, scale b: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result = 1.0 / (2.0 * b) * exp(-fabs(x - mean) / b)
    return result
}

/// Returns the cdf of the Laplace distribution.
/// - Parameter x: x
/// - Parameter mean: mean
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func cdfLaplaceDist(x: Double!, mean: Double!, scale b: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let xm = x - mean
    let result = 0.5 * (1.0 + xm.sgn * (1.0 - exp(-fabs(xm) / b)))
    return result
}

/// Returns the quantile of the Laplace distribution.
/// - Parameter p: p
/// - Parameter mean: mean
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0 || p < 0 || p > 1
public func quantileLaplaceDist(p: Double!, mean: Double!, scale b: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0.0 || p > 1.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 or <= 1.0 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result: Double
    if p.isZero {
        return -Double.infinity
    }
    else if fabs(p - 1.0) < 1E-15 {
        return Double.infinity
    }
    else if (p <= 0.5) {
        result = mean + b * log1p(2.0 * p - 1.0)
    }
    else {
        result = mean - b * log1p(2.0 * (1.0 - p) - 1.0)
    }
    return result
}
