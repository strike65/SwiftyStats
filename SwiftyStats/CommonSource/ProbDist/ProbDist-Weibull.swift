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
public func paraWeibullDist(location loc: Double!, scale: Double!, shape: Double!) throws -> SSContProbDistParams {
    if (scale <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (shape <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result = SSContProbDistParams()
    result.mean = loc + scale * (1.0 + (1.0 / shape)).gammaValue
    result.variance = pow(scale, 2.0) * ((1 + 2.0 / shape).gammaValue - pow((1.0 + shape.inverse).gammaValue, 2.0))
    var a:Double = -3.0 * pow((1 + shape.inverse).gammaValue, 4.0)
    var b:Double = 6.0 * pow((1 + shape.inverse).gammaValue, 2.0) * (1.0 + 2.0 / shape).gammaValue
    var c: Double = -4.0 * (1.0 + shape.inverse).gammaValue * (1.0 + 3.0 / shape).gammaValue
    var d: Double = (1.0 + 4.0 / shape).gammaValue
    let e: Double = (1.0 + 2.0 / shape).gammaValue - pow((1.0 + shape.inverse).gammaValue, 2.0)
    result.kurtosis = (a + b + c + d) / pow(e, 2.0)
    
    a = 2.0 * pow((1.0 + shape.inverse).gammaValue, 3.0)
    b = -3.0 * (1.0 + shape.inverse).gammaValue * (1.0 + 2.0 / shape).gammaValue
    c = (1.0 + 3.0 / shape).gammaValue
    d = (1.0 + 2.0 / shape).gammaValue - pow((1.0 + shape.inverse).gammaValue, 2.0)
    
    result.skewness = (a + b + c) / pow(d, 1.5)
    return result
}

/// Returns the pdf of the Weibull distribution.
/// - Parameter x: x
/// - Parameter a: Location parameter
/// - Parameter b: Scale parameter
/// - Parameter c: Shape parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func pdfWeibullDist(x: Double!, location a: Double!, scale b: Double!, shape c: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < a {
        return 0.0
    }
    let result = c / b * pow((x - a) / b, c - 1.0) * exp(-pow((x - a) / b, c))
    return result
}

/// Returns the cdf of the Weibull distribution.
/// - Parameter x: x
/// - Parameter a: Location parameter
/// - Parameter b: Scale parameter
/// - Parameter c: Shape parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func cdfWeibullDist(x: Double!, location a: Double!, scale b: Double!, shape c: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < a {
        return 0.0
    }
    let result = 1.0 - exp(-pow((x - a) / b, c))
    return result
}

/// Returns the quantile of the Weibull distribution.
/// - Parameter p: p
/// - Parameter a: Location parameter
/// - Parameter b: Scale parameter
/// - Parameter c: Shape parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 1
public func quantileWeibullDist(p: Double!, location a: Double!, scale b: Double!, shape c: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (c <= 0.0) {
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
    if p == 0.0 {
        return a
    }
    if p == 1.0 {
        return Double.infinity
    }
    let result = a + b * pow(-log1p((1.0 - p) - 1.0), 1.0 / c)
    return result
}

