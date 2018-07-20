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

// MARK: Logistic
/// Returns the Logit for a given p
/// - Parameter p: p
/// - Throws: SSSwiftyStatsError if p <= 0 || p >= 1
public func logit(p: Double!) throws -> Double {
    if p <= 0.0 || p >= 1.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 or <= 1.0 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return log1p(p / (1.0 - p))
}

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Logistic distribution.
/// - Parameter mean: mean
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func paraLogisticDist(mean: Double!, scale b: Double!) throws -> SSContProbDistParams {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result = SSContProbDistParams()
    result.mean = mean
    result.variance = pow(b, 2.0) * pow(Double.pi, 2.0) / 3.0
    result.kurtosis = 4.2
    result.skewness = 0.0
    return result
}

/// Returns the pdf of the Logistic distribution.
/// - Parameter x: x
/// - Parameter mean: mean
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func pdfLogisticDist(x: Double!, mean: Double!, scale b: Double!) throws -> Double {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result = exp(-(x - mean) / b) / (b * pow(1.0 + exp(-(x - mean) / b), 2.0))
    return result
}

/// Returns the cdf of the Logistic distribution.
/// - Parameter x: x
/// - Parameter mean: mean
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func cdfLogisticDist(x: Double!, mean: Double!, scale b: Double!) throws -> Double {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result = 0.5 * (1.0 + tanh(0.5 * (x - mean) / b))
    return result
}

/// Returns the quantile of the Logistic distribution.
/// - Parameter p: p
/// - Parameter mean: mean
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0 || p < 0 || p > 1
public func quantileLogisticDist(p: Double!, mean: Double!, scale b: Double!) throws -> Double {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0 ", log: log_stat, type: .error)
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
    let result: Double
    if p.isZero {
        return -Double.infinity
    }
    else if p == 1.0 {
        return Double.infinity
    }
    else {
        result = mean - b * log(-1.0 + 1.0 / p)
        return result
    }
}
