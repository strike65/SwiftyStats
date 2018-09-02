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
public func paraRayleighDist<FPT: SSFloatingPoint & Codable>(scale s: FPT) throws -> SSContProbDistParams<FPT>  {
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>.init()
    if s <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    result.mean = FPT.sqrtpihalf * s
    result.variance = (2 - FPT.pi / 2) * s * s
    result.skewness = ((-3 + FPT.pi) * FPT.sqrtpihalf) / pow1(2 - FPT.pi / 2, makeFP(3.0 / 2.0 ))
    result.kurtosis = (32 - 3 * FPT.pisquared) / pow1(4 - FPT.pi, 2)
    return result
}


/// Returns the pdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func pdfRayleighDist<FPT: SSFloatingPoint & Codable>(x: FPT, scale s: FPT) throws -> FPT {
    if s <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: FPT = 0
    if x > 0 {
        result = (x * exp1(-(x * x) / (2 * s * s))) / (s * s)
    }
    return result
}

/// Returns the cdf of the Chi^2 distribution.
/// - Parameter chi: Chi
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func cdfRayleighDist<FPT: SSFloatingPoint & Codable>(x: FPT, scale s: FPT) throws -> FPT  {
    if s <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: FPT = 0
    if x > 0 {
        result = 1 - exp1(-(x * x) / (2 * s * s))
    }
    return result
}


/// Returns the p-quantile of the Chi^2 distribution.
/// - Parameter p: p
/// - Parameter df: Degrees of freedom
/// - Throws: SSSwiftyStatsError if df <= 0
public func quantileRayleighDist<FPT: SSFloatingPoint & Codable>(p: FPT, scale s: FPT) throws -> FPT {
    if s <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < FPT.leastNonzeroMagnitude {
        return 0
    }
    if (1 - p) < FPT.leastNonzeroMagnitude {
        return FPT.infinity
    }
    return s * (-log1(pow1(1 - p, 2))).squareRoot()
}
