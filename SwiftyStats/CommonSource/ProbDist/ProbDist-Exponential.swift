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

// MARK: Exponential Dist

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Exponential distribution.
/// - Parameter l: Lambda
/// - Throws: SSSwiftyStatsError if l <= 0
public func paraExponentialDist(lambda l: Double!) throws -> SSContProbDistParams {
    if (l <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter lambda is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result = SSContProbDistParams()
    result.mean = 1.0 / l
    result.variance = 1.0 / (l * l)
    result.kurtosis = 9.0
    result.skewness = 2.0
    return result
}

/// Returns the pdf of the Exponential distribution.
/// - Parameter x: x
/// - Parameter l: Lambda
/// - Throws: SSSwiftyStatsError if l <= 0
public func pdfExponentialDist(x: Double!, lambda l: Double!) throws -> Double {
    if (l <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter lambda is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < 0.0 {
        return 0.0
    }
    else if x == 1.0 {
        return l
    }
    else {
        return l * exp(-l * x)
    }
}

/// Returns the cdf of the Exponential distribution.
/// - Parameter x: x
/// - Parameter l: Lambda
/// - Throws: SSSwiftyStatsError if l <= 0
public func cdfExponentialDist(x: Double!, lambda l: Double!) throws -> Double {
    if (l <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter lambda is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x <= 0.0 {
        return 0.0
    }
    else {
        return 1.0 - exp(-l * x)
    }
}

/// Returns the quantile of the Exponential distribution.
/// - Parameter p: p
/// - Parameter l: Lambda
/// - Throws: SSSwiftyStatsError if l <= 0 || p < 0 || p > 1
public func quantileExponentialDist(p: Double!, lambda l: Double!) throws -> Double {
    if (l <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter lambda is expected to be > 0", log: log_stat, type: .error)
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
        return 0.0
    }
    else if p == 1.0 {
        return Double.infinity
    }
    else {
        return -log1p(1.0 - p - 1.0) / l
    }
}

