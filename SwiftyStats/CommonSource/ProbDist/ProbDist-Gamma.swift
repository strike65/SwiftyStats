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


// MARK: Gamma

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Gamma distribution.
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func paraGammaDist(shape a: Double!, scale b: Double!) throws -> SSContProbDistParams {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result = SSContProbDistParams()
    result.mean = a * b
    result.variance = a * b * b
    result.kurtosis = 3.0 + 6.0 / a
    result.skewness = 2.0 / sqrt(a)
    return result
}


/// Returns the pdf of the Gamma distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func pdfGammaDist(x: Double!, shape a: Double!, scale b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x <= 0.0 {
        return 0.0
    }
    else {
        let a1 = -a * log(b)
        let a2 = -x / b
        let a3 = -1.0 + a
        let a4 = a1 + a2 + a3 * log(x) - lgamma(a)
        let result = exp(a4)
        return result
        //            return exp(-a * log(b) + (-x / b) + (-1.0 + a) * log(x) - lgamma(a))
    }
}

/// Returns the cdf of the Gamma distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func cdfGammaDist(x: Double!, shape a: Double!, scale b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < 0.0 {
        return 0.0
    }
    var cv: Bool = false
    let result = gammaNormalizedP(x: x / b, a: a, converged: &cv)
    if cv {
        return result
    }
    else {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("unable to retrieve a result", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .maxNumberOfIterationReached, file: #file, line: #line, function: #function)
    }
}

/// Returns the quantile of the Gamma distribution.
/// - Parameter p: p
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 1
public func quantileGammaDist(p: Double!, shape a: Double!, scale b: Double!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
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
    if p == 1.0 {
        return Double.infinity
    }
    var gVal: Double = 0.0
    var maxG: Double = 0.0
    var minG: Double = 0.0
    maxG = a * b + 4000.0
    minG = 0.0
    gVal = a * b
    var test: Double
    var i = 1
    while((maxG - minG) > 1.0E-14) {
        test = try! cdfGammaDist(x: gVal, shape: a, scale: b)
        if test > p {
            maxG = gVal
        }
        else {
            minG = gVal
        }
        gVal = (maxG + minG) * 0.5
        i = i + 1
        if i >= 7500 {
            break
        }
    }
    if((a * b) > 10000) {
        let t1: Double = gVal * 1E07
        let ri: UInt64 = UInt64(t1)
        let rd: Double = Double(ri) / 1E07
        return rd
    }
    else {
        return gVal
    }
}

