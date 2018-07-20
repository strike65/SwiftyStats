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

// MARK: UNIFORM

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Uniform distribution.
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Throws: SSSwiftyStatsError if a >= b
public func paraUniformDist(lowerBound a: Double!, upperBound b: Double!) throws -> SSContProbDistParams {
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
    result.variance = 1.0 / 12.0 * (b - a) * (b - a)
    result.kurtosis = 1.8
    result.skewness = 0.0
    return result
}

/// Returns the pdf of the Uniform distribution.
/// - Parameter x: x
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Throws: SSSwiftyStatsError if a >= b
public func pdfUniformDist(x: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < a || x > b {
        return 0.0
    }
    else {
        return 1.0 / (b - a)
    }
}

/// Returns the cdf of the Uniform distribution.
/// - Parameter x: x
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Throws: SSSwiftyStatsError if a >= b
public func cdfUniformDist(x: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
    if (a >= b) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < a {
        return 0.0
    }
    else if x > b {
        return 1.0
    }
    else {
        return (x - a) / (b - a)
    }
}

/// Returns the cdf of the Uniform distribution.
/// - Parameter x: x
/// - Parameter a: Lower bound
/// - Parameter b: Upper bound
/// - Throws: SSSwiftyStatsError if a >= b
public func quantileUniformDist(p: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
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
    return a + (b - a) * p
}

