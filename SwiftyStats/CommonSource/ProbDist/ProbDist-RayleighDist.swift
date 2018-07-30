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


// MARK: Chi Square

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Chi^2 distribution.
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func paraRayleighDist(scale s: Double!) throws -> SSContProbDistParams {
    var result = SSContProbDistParams()
    if s <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = SQRTPIHALF * s
    result.variance = (2.0 - PIHALF) * s * s
    result.skewness = ((-3 + Double.pi) * SQRTPIHALF) / pow(2 - PIHALF, 1.5)
    result.kurtosis = (32 - 3 * PISQUARED) / pow(4 - Double.pi, 2.0)
    return result
}


/// Returns the pdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func pdfRayleighDist(x: Double!, scale s: Double!) throws -> Double {
    if s <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: Double = 0.0
    if x > 0.0 {
        result = (x * exp(-(x * x) / (2.0 * s * s))) / (s * s)
    }
    return result
}

/// Returns the cdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func cdfRayleighDist(x: Double!, scale s: Double!) throws -> Double {
    if s <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: Double = 0.0
    if x > 0.0 {
        result = 1.0 - exp(-(x * x) / (2.0 * s * s))
    }
    return result
}


/// Returns the p-quantile of the Chi^2 distribution.
/// - Parameter p: p
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func quantileRayleighDist(p: Double!, scale s: Double!) throws -> Double {
    if s <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0.0 || p > 1.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < Double.leastNonzeroMagnitude {
        return 0.0
    }
    if (1.0 - p) < Double.leastNonzeroMagnitude {
        return Double.infinity
    }
    return s * sqrt(-log(pow(1.0 - p, 2.0)))
}
