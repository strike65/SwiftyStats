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

// MARK: Weibull

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Weibull distribution.
/// - Parameter a: Location parameter
/// - Parameter b: Scale parameter
/// - Parameter c: Shape parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func paraWeibullDist<FPT: SSFloatingPoint & Codable>(location loc: FPT, scale: FPT, shape: FPT) throws -> SSContProbDistParams<FPT> {
    if (scale <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (shape <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    result.mean = loc + scale * tgamma1(1 + (1 / shape))
    result.variance = pow1(scale, 2) * (tgamma1(1 + 2 / shape) - pow1(tgamma1(1 + 1 / shape), 2))
    var a:FPT = -3 * pow1(tgamma1(1 + 1 / shape), 4)
    var b:FPT = 6 * pow1(tgamma1(1 + 1 / shape), 2) * tgamma1(1 + 2 / shape)
    var c: FPT = -4 * tgamma1(1 + 1 / shape) * tgamma1(1 + 3 / shape)
    var d: FPT = tgamma1(1 + 4 / shape)
    let e: FPT = tgamma1(1 + 2 / shape) - pow1(tgamma1(1 + 1 / shape), 2)
    result.kurtosis = (a + b + c + d) / pow1(e, 2)
    
    a = 2 * pow1(tgamma1(1 + 1 / shape), 3)
    b = -3 * tgamma1(1 + 1 / shape) * tgamma1(1 + 2 / shape)
    c = tgamma1(1 + 3 / shape)
    d = tgamma1(1 + 2 / shape) - pow1(tgamma1(1 + 1 / shape), 2)
    
    result.skewness = (a + b + c) / pow1(d, makeFP(1.5))
    return result
}

/// Returns the pdf of the Weibull distribution.
/// - Parameter x: x
/// - Parameter a: Location parameter
/// - Parameter b: Scale parameter
/// - Parameter c: Shape parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func pdfWeibullDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < a {
        return 0
    }
    let result = c / b * pow1((x - a) / b, c - 1) * exp1(-pow1((x - a) / b, c))
    return result
}

/// Returns the cdf of the Weibull distribution.
/// - Parameter x: x
/// - Parameter a: Location parameter
/// - Parameter b: Scale parameter
/// - Parameter c: Shape parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func cdfWeibullDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < a {
        return 0
    }
    let result = 1 - exp1(-pow1((x - a) / b, c))
    return result
}

/// Returns the quantile of the Weibull distribution.
/// - Parameter p: p
/// - Parameter a: Location parameter
/// - Parameter b: Scale parameter
/// - Parameter c: Shape parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 1
public func quantileWeibullDist<FPT: SSFloatingPoint & Codable>(p: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
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
    if p == 0 {
        return a
    }
    if p == 1 {
        return FPT.infinity
    }
    let result = a + b * pow1(-log1p1((1 - p) - 1), 1 / c)
    return result
}

