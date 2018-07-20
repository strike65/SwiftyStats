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

// MARK: Log Normal

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Log Normal distribution.
/// - Parameter mean: mean
/// - Parameter variance: variance
/// - Throws: SSSwiftyStatsError if v <= 0
public func paraLogNormalDist(mean: Double!, variance v: Double!) throws -> SSContProbDistParams {
    var result = SSContProbDistParams()
    if v <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("variance is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let delta: Double = exp(v)
    result.mean = exp(mean + v / 2.0)
    result.variance = exp(2.0 * mean) * delta * (delta - 1.0)
    result.skewness = (delta + 2.0) * sqrt(delta - 1.0)
    result.kurtosis = pow(delta, 4.0) + 2.0 * pow(delta, 3.0) + 3.0 * pow(delta, 2.0) - 3.0
    return result
}

/// Returns the cdf of the Logarithmic Normal distribution
/// - Parameter x: x
/// - Parameter mean: mean
/// - Parameter variance: variance
/// - Throws: SSSwiftyStatsError if v <= 0
public func pdfLogNormalDist(x: Double!, mean: Double!, variance v: Double!) throws -> Double {
    if v <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("variance is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x <= 0 {
        return 0.0
    }
    else {
        let r = 1.0 / (sqrt(v) * x * sqrt(2.0 * Double.pi)) * exp(-1.0 * pow(log(x) - mean, 2.0) / (2.0 * v))
        return r
    }
}

/// Returns the pdf of the Logarithmic Normal distribution
/// - Parameter x: x
/// - Parameter mean: mean
/// - Parameter variance: variance
/// - Throws: SSSwiftyStatsError if v <= 0
public func cdfLogNormal(x: Double!, mean: Double!, variance v: Double!) throws -> Double {
    if v <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("variance is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x <= 0 {
        return 0.0
    }
    let r = cdfStandardNormalDist(u: (log(x) - mean) / sqrt(v))
    return r
}


/// Returns the pdf of the Logarithmic Normal distribution
/// - Parameter p: p
/// - Parameter mean: mean
/// - Parameter variance: variance
/// - Throws: SSSwiftyStatsError if v <= 0 and/or p < 0 and/or p > 1
public func quantileLogNormal(p: Double, mean: Double!, variance v: Double!) throws -> Double {
    if v <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("variance is expected to be > 0", log: log_stat, type: .error)
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
    if fabs(p - 1.0) <= 1e-16 {
        return Double.infinity
    }
    else if p.isZero {
        return 0.0
    }
    do {
        let u = try quantileStandardNormalDist(p: p)
        return exp( mean + u * sqrt(v))
    }
    catch {
        return Double.nan
    }
}

