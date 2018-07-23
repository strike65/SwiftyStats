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
public func paraChiSquareDist(degreesOfFreedom df: Double!) throws -> SSContProbDistParams {
    var result = SSContProbDistParams()
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = df
    result.variance = 2.0 * df
    result.skewness = sqrt(8.0 / df)
    result.kurtosis = 3.0 + 12.0 / df
    return result
}


/// Returns the pdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func pdfChiSquareDist(chi: Double!, degreesOfFreedom df: Double!) throws -> Double {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: Double = 0.0
    if chi >= 0.0 {
        let a: Double
        let b: Double
        let c: Double
        let d: Double
        a = -df / 2.0 * LOG2
        b = -chi / 2.0
        c = (-1.0 + df / 2.0) * log(chi)
        d = lgamma(df / 2.0)
        result = exp(a + b + c - d)
    }
    else {
        result = 0.0
    }
    return result
}

/// Returns the cdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func cdfChiSquareDist(chi: Double!, degreesOfFreedom df: Double!) throws -> Double {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if chi <= 0 {
        return 0.0
    }
    var conv: Bool = false
    let cdf1: Double = gammaNormalizedP(x: 0.5 * chi, a: 0.5 * df, converged: &conv)
    if cdf1 < 0.0 {
        return 0.0
    }
    else if ((cdf1 > 1.0) || cdf1.isNaN) {
        return 1.0
    }
    else {
        return cdf1
    }
}


/// Returns the p-quantile of the Chi^2 distribution.
/// - Parameter p: p
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func quantileChiSquareDist(p: Double!, degreesOfFreedom df: Double!) throws -> Double {
    if df <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
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
    let eps = 1.0E-12
    var minChi: Double = 0.0
    var maxChi: Double = 9999.0
    var result: Double = 0.0
    var chiVal: Double = df / sqrt(p)
    var test: Double
    while (maxChi - minChi) > eps {
        do {
            test = try cdfChiSquareDist(chi: chiVal, degreesOfFreedom: df)
        }
        catch {
            return Double.nan
        }
        if test > p {
            maxChi = chiVal
        }
        else {
            minChi = chiVal
        }
        chiVal = (maxChi + minChi) / 2.0
    }
    result = chiVal
    return result
}

